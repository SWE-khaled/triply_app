import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `payments/{paymentId}` document (1—1 with a booking).
///
/// Never stores PAN/CVV. Only provider references + amounts. `status` is
/// written by the trusted Paymob verification Function — clients may create
/// a `pending` record but may never mark it `succeeded` (rules enforce).
class PaymentDoc {
  final String id;
  final String bookingId;
  final String touristId;
  final String provider; // paymob
  final String providerReference; // Paymob order id
  final String paymentTokenRef; // payment-key id (not the secret token)
  final double amount;
  final String currency;
  final String status; // pending | succeeded | failed | refunded
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;

  const PaymentDoc({
    required this.id,
    required this.bookingId,
    required this.touristId,
    this.provider = 'paymob',
    this.providerReference = '',
    this.paymentTokenRef = '',
    this.amount = 0,
    this.currency = 'EGP',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
  });

  factory PaymentDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return PaymentDoc.fromMap(d, doc.id);
  }

  factory PaymentDoc.fromMap(Map<String, dynamic> d, String id) {
    return PaymentDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      bookingId: FirestoreConverters.toStr(d['bookingId']),
      touristId: FirestoreConverters.toStr(d['touristId']),
      provider: FirestoreConverters.toStr(d['provider'], 'paymob'),
      providerReference: FirestoreConverters.toStr(
        d['providerReference'] ?? d['orderId'],
      ),
      paymentTokenRef: FirestoreConverters.toStr(d['paymentTokenRef']),
      amount: FirestoreConverters.toDouble(
        d['amount'] ?? d['totalAmount'] ?? d['total'],
      ),
      currency: FirestoreConverters.toStr(d['currency'], 'EGP'),
      status: FirestoreConverters.toStr(d['status'], 'pending'),
      createdAt: FirestoreConverters.toDateTime(d['createdAt']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
      verifiedAt: FirestoreConverters.toDateTime(d['verifiedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'bookingId': bookingId,
      'provider': provider,
      'providerReference': providerReference,
      'paymentTokenRef': paymentTokenRef,
      'amount': amount,
      'currency': currency,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'touristId': touristId,
      'provider': provider,
      'providerReference': providerReference,
      'paymentTokenRef': paymentTokenRef,
      'amount': amount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'verifiedAt': verifiedAt,
    };
  }
}
