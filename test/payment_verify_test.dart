import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:triply/data/firestore/datasources/payments_datasource.dart';
import 'package:triply/data/firestore/models/payment_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/checkout/cubit/checkout_cubit.dart';
import 'package:triply/features/tourist/checkout/model/booking_model.dart';
import 'package:triply/features/tourist/checkout/services/paymob_service.dart';
import 'package:triply/features/tourist/checkout/view/paymob_webview_screen.dart';

/// Focused Phase 8 unit tests: Paymob client orchestration (scripted HTTP,
/// no network), checkout workflow, redirect parsing, verify-payload
/// mapping, and pending-payment creation. No Firebase channels are touched
/// (fakes override them) and no real Paymob endpoint is contacted: the
/// fake client intercepts every request. These are UNIT tests, not live
/// sandbox tests.
class _FakeClient extends http.BaseClient {
  final List<http.Response> script;
  final List<Uri> urls = [];
  final List<Map<String, dynamic>> bodies = [];
  final Object? sendError;
  int calls = 0;

  _FakeClient(this.script, {this.sendError});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls++;
    if (sendError != null) throw sendError!;
    urls.add(request.url);
    if (request is http.Request && request.body.isNotEmpty) {
      bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
    }
    final res = script[(calls - 1) % script.length];
    return http.StreamedResponse(
      Stream.value(utf8.encode(res.body)),
      res.statusCode,
      headers: {'content-type': 'application/json'},
    );
  }
}

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

const _summary = CheckoutBookingSummary(
  guideId: 'g1',
  guideName: 'Omar',
  guideSpecialty: '',
  guideAvatarUrl: '',
  dateLabel: '2026-11-02',
  timeSlot: '',
  durationLabel: '4 hours',
  travelers: 2,
  meetingPoint: 'Gate',
  pricePerHour: 6000,
  currency: 'EGP',
  serviceFee: 600,
  total: 12600,
);

PaymobBillingData _billing() => const PaymobBillingData(
  firstName: 'Test',
  lastName: 'User',
  country: 'Egypt',
  street: 'Street',
);

class _FakePaymobService extends PaymobService {
  Future<({String paymentToken, int orderId})>? pending;
  ({String paymentToken, int orderId})? result;
  Object? error;
  int calls = 0;

  @override
  Future<({String paymentToken, int orderId})> createPaymentToken({
    required CheckoutBookingSummary summary,
    required PaymobBillingData billing,
  }) async {
    calls++;
    if (pending != null) return pending!;
    if (error != null) throw error!;
    return result!;
  }
}

class _FakePaymentsDatasource extends PaymentsDatasource {
  Map<String, dynamic>? lastDoc;
  String nextId = 'pay-1';

  @override
  Future<String> createPending(PaymentDoc doc) async {
    lastDoc = {
      'bookingId': doc.bookingId,
      'touristId': doc.touristId,
      'providerReference': doc.providerReference,
      'amount': doc.amount,
      'status': 'pending',
    };
    return nextId;
  }
}

void main() {
  group('PaymobService client', () {
    // Fail-closed config requires keys; test-only values prove the
    // `.env`-first path without touching real credentials.
    setUpAll(() {
      dotenv.loadFromString(
        envString: 'PAYMOB_API_KEY=test-key\n'
            'PAYMOB_INTEGRATION_ID=123\n'
            'PAYMOB_IFRAME_ID=456\n',
      );
    });

    test('auth -> order -> key sends server totals as minor units', () async {
      final client = _FakeClient([
        _json({'token': 'auth-t'}),
        _json({'id': 777}),
        _json({'token': 'pay-t'}),
      ]);
      final service = PaymobService(client: client);
      final result = await service.createPaymentToken(
        summary: _summary,
        billing: _billing(),
      );
      expect(result.paymentToken, 'pay-t');
      expect(result.orderId, 777);
      expect(client.calls, 3);
      expect(client.urls.map((u) => u.path).toList(), [
        '/api/auth/tokens',
        '/api/ecommerce/orders',
        '/api/acceptance/payment_keys',
      ]);
      // 12600 EGP -> 1,260,000 minor units on BOTH money calls.
      expect(client.bodies[1]['amount_cents'], '1260000');
      expect(client.bodies[2]['amount_cents'], 1260000);
      expect(client.bodies[2]['order_id'], 777);
      expect(client.bodies[2]['currency'], 'EGP');
    });

    test('auth failure never leaks the response body', () async {
      final client = _FakeClient([
        _json({'error': 'SECRET-BODY-XYZ'}, 500),
      ]);
      final service = PaymobService(client: client);
      await expectLater(
        service.createPaymentToken(summary: _summary, billing: _billing()),
        throwsA(
          predicate(
            (e) =>
                e is PaymobException && !e.message.contains('SECRET-BODY-XYZ'),
          ),
        ),
      );
    });

    test('missing configuration fails closed (no embedded secrets)',
        () async {
      dotenv.clean();
      try {
        final client = _FakeClient([_json({'token': 'x'})]);
        await expectLater(
          PaymobService(client: client)
              .createPaymentToken(summary: _summary, billing: _billing()),
          throwsA(
            predicate(
              (e) =>
                  e is PaymobException &&
                  e.message.contains('not configured'),
            ),
          ),
        );
        expect(client.calls, 0);
      } finally {
        dotenv.loadFromString(
          envString: 'PAYMOB_API_KEY=test-key\n'
              'PAYMOB_INTEGRATION_ID=123\n'
              'PAYMOB_IFRAME_ID=456\n',
        );
      }
    });

    test('network errors map to friendly messages', () async {      final offline = _FakeClient([
        _json({}),
      ], sendError: const SocketException('down'));
      await expectLater(
        PaymobService(
          client: offline,
        ).createPaymentToken(summary: _summary, billing: _billing()),
        throwsA(
          predicate(
            (e) =>
                e is PaymobException &&
                e.message.contains('No internet connection'),
          ),
        ),
      );
      final slow = _FakeClient([_json({})], sendError: TimeoutException('t'));
      await expectLater(
        PaymobService(
          client: slow,
        ).createPaymentToken(summary: _summary, billing: _billing()),
        throwsA(isA<PaymobException>()),
      );
    });
  });

  group('CheckoutCubit workflow', () {
    test('success stores token + order id and clears paying', () async {
      final service = _FakePaymobService()
        ..result = (paymentToken: 'tok', orderId: 42);
      final cubit = CheckoutCubit(summary: _summary, service: service);
      final token = await cubit.startPayment();
      expect(token, 'tok');
      expect(cubit.paymentToken, 'tok');
      expect(cubit.lastOrderId, 42);
      expect(cubit.isPaying, isFalse);
      expect(cubit.payError, isNull);
      await cubit.close();
    });

    test('concurrent start returns null; service called once', () async {
      final gate = Completer<({String paymentToken, int orderId})>();
      final service = _FakePaymobService()..pending = gate.future;
      final cubit = CheckoutCubit(summary: _summary, service: service);
      final first = cubit.startPayment();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.isPaying, isTrue);
      expect(await cubit.startPayment(), isNull);
      gate.complete((paymentToken: 'tok', orderId: 1));
      expect(await first, 'tok');
      expect(service.calls, 1);
      await cubit.close();
    });

    test('service failure surfaces payError without token', () async {
      final service = _FakePaymobService()
        ..error = const PaymobException('Order failed (HTTP 500).');
      final cubit = CheckoutCubit(summary: _summary, service: service);
      expect(await cubit.startPayment(), isNull);
      expect(cubit.paymentToken, isNull);
      expect(cubit.payError, contains('Order failed'));
      expect(cubit.lastOrderId, isNull);
      await cubit.close();
    });
  });

  group('WebView redirect parsing', () {
    test('only explicit success=true counts (untrusted signal)', () {
      expect(
        PaymobWebviewScreen.indicatesSuccess(
          'https://host/cb?success=true&order=1',
        ),
        isTrue,
      );
      expect(
        PaymobWebviewScreen.indicatesSuccess('https://host/cb?success=TRUE'),
        isTrue,
      );
      expect(
        PaymobWebviewScreen.indicatesSuccess('https://host/cb?success=false'),
        isFalse,
      );
      expect(
        PaymobWebviewScreen.indicatesSuccess('https://host/cb?order=1'),
        isFalse,
      );
      expect(PaymobWebviewScreen.indicatesSuccess('not a url %%'), isFalse);
      expect(PaymobWebviewScreen.indicatesSuccess(''), isFalse);
    });
  });

  group('verify payload mapping', () {
    test('only succeeded is a paid verdict', () {
      final ok = BookingsRepository.parseVerifyPayload({
        'status': 'succeeded',
        'paymentId': 'p1',
      });
      expect(ok.status, 'succeeded');
      expect(ok.reason, isNull);
      expect(ok.deduped, isFalse);

      final replay = BookingsRepository.parseVerifyPayload({
        'status': 'succeeded',
        '_deduped': true,
      });
      expect(replay.status, 'succeeded');
      expect(replay.deduped, isTrue);

      final pending = BookingsRepository.parseVerifyPayload({
        'status': 'pending',
        'reason': 'not-paid',
      });
      expect(pending.status, 'pending');
      expect(pending.reason, 'not-paid');
      expect(pending.deduped, isFalse);

      final empty = BookingsRepository.parseVerifyPayload({});
      expect(empty.status, 'pending');
      expect(empty.reason, isNull);
    });
  });

  group('pending payment creation', () {
    test('carries booking id, owner, amount, order ref as pending', () async {
      final ds = _FakePaymentsDatasource();
      final repo = BookingsRepository(payments: ds);
      final id = await repo.createPendingPayment(
        bookingId: 'b1',
        touristId: 'u1',
        amount: 12600,
        providerReference: '777',
      );
      expect(id, 'pay-1');
      expect(ds.lastDoc!['bookingId'], 'b1');
      expect(ds.lastDoc!['touristId'], 'u1');
      expect(ds.lastDoc!['amount'], 12600);
      expect(ds.lastDoc!['providerReference'], '777');
      expect(ds.lastDoc!['status'], 'pending');
    });
  });
}
