// Phase C1 — live rules check for the Spark-only chat feature.
//
// Signs in as the two dedicated test accounts through the Firebase Auth REST
// API (credentials come ONLY from environment variables) and calls the
// Firestore REST API with the returned ID token, so the deployed security
// rules are really evaluated (the Admin SDK is never used for a check — it
// bypasses rules).
//
// Required environment variables (never printed):
//   CHAT_TEST_TOURIST_EMAIL / CHAT_TEST_TOURIST_PASSWORD
//   CHAT_TEST_GUIDE_EMAIL   / CHAT_TEST_GUIDE_PASSWORD
// Optional (enable extra checks when present):
//   CHAT_TEST_THIRD_EMAIL   / CHAT_TEST_THIRD_PASSWORD   (non-participant)
//   CHAT_TEST_ADMIN_EMAIL   / CHAT_TEST_ADMIN_PASSWORD   (admin)
//
// Run:  dart run tool/chat_rules_check.dart
//
// No secrets are printed: only document ids, status and PASS/FAIL.

import 'dart:convert';
import 'dart:io';

// Public web config, already committed in lib/firebase_options.dart.
const String _projectId = 'triply-f9b82';
const String _webApiKey = 'AIzaSyBSqfGq2OZsZwM9OSgkUYsoVuYltzzeOmc';

const String _authBase =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';
const String _fsBase =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

/// Marker for a Firestore server-timestamp transform. It must be emitted as a
/// commit `updateTransforms` entry (`setToServerValue: REQUEST_TIME`), never as
/// a Value: a Value with `timestampValue: null` has no type discriminator and
/// Firestore rejects it with "Cannot convert firestore.v1.Value with type
/// unset."
class ServerTimestamp {
  const ServerTimestamp();
}

/// An explicit RFC3339 timestamp value (Firestore `timestampValue`).
class TimestampValue {
  const TimestampValue(this.value);
  final String value;
}

const ServerTimestamp serverTs = ServerTimestamp();

Map<String, dynamic> _toValue(dynamic v) {
  if (v is TimestampValue) return {'timestampValue': v.value};
  if (v is ServerTimestamp) {
    throw StateError('ServerTimestamp must be sent as a write transform');
  }
  if (v is bool) return {'booleanValue': v};
  if (v is int) return {'integerValue': v.toString()};
  if (v is double) return {'doubleValue': v};
  if (v is String) return {'stringValue': v};
  if (v is List) {
    return {
      'arrayValue': {'values': v.map(_toValue).toList()},
    };
  }
  if (v is Map<String, dynamic>) {
    return {
      'mapValue': {'fields': _toFields(v)},
    };
  }
  throw StateError('unsupported value type: ${v.runtimeType}');
}

Map<String, dynamic> _toFields(Map<String, dynamic> map) => {
  for (final e in map.entries) e.key: _toValue(e.value),
};

/// One type discriminator per supplied field, with no field values. A server
/// timestamp is reported as a transform because it has no Value of its own.
String _valueShape(dynamic v) {
  if (v is ServerTimestamp) return 'timestamp-transform';
  if (v is TimestampValue) return 'timestampValue';
  if (v is bool) return 'booleanValue';
  if (v is int) return 'integerValue';
  if (v is double) return 'doubleValue';
  if (v is String) return 'stringValue';
  if (v is List) return 'arrayValue';
  if (v is Map<String, dynamic>) return 'mapValue';
  return 'unsupported:${v.runtimeType}';
}

String _fieldShape(Map<String, dynamic> fields) =>
    fields.entries.map((e) => '${e.key}=${_valueShape(e.value)}').join(',');

class _Resp {
  _Resp(
    this.status,
    this.body, {
    this.path,
    this.fieldShape,
    this.createRequest = false,
  });
  final int status;
  final dynamic body;

  /// Sanitized request path for diagnostics (never includes the auth key).
  final String? path;

  /// Field-name -> type-discriminator summary; contains no field values.
  final String? fieldShape;

  /// True when this was a create (commit with `currentDocument.exists=false`).
  final bool createRequest;

  bool get ok => status >= 200 && status < 300;

  /// A create that hit an existing document. createDocument answered 409;
  /// commit() reports a failed `exists=false` precondition as
  /// FAILED_PRECONDITION with an "already exists" message.
  bool get alreadyExists =>
      status == 409 ||
      errorText.toUpperCase().contains('ALREADY_EXISTS') ||
      errorText.toLowerCase().contains('already exists') ||
      (createRequest &&
          status == 400 &&
          firestoreCode == 'FAILED_PRECONDITION');

  String get errorText {
    final e = body is Map ? body['error'] : null;
    if (e is Map) return (e['message'] ?? '').toString();
    return '';
  }

  /// Firestore's machine-readable status, e.g. PERMISSION_DENIED or
  /// INVALID_ARGUMENT. Only a strict upper-case code is surfaced.
  String? get firestoreCode {
    final e = body is Map ? body['error'] : null;
    final s = e is Map ? e['status'] : null;
    if (s is String && RegExp(r'^[A-Z_]+$').hasMatch(s)) return s;
    return null;
  }

  /// True only for an actual security-rules denial. Any other 403 (bad
  /// credentials, disabled API, IAM) is not a rules decision.
  bool get permissionDenied =>
      status == 403 && firestoreCode == 'PERMISSION_DENIED';

  /// Sanitized diagnostic: path, status, Firestore code and field/type shape.
  /// Never contains values, tokens, emails, passwords or profile contents.
  String get diagnostic {
    final parts = <String>[
      if (path != null) 'path=$path',
      'http=$status',
      'code=${firestoreCode ?? 'none'}',
      if (fieldShape != null) 'fields={$fieldShape}',
    ];
    return parts.join(' ');
  }
}

Future<_Resp> _request(
  String method,
  String url, {
  String? idToken,
  Map<String, dynamic>? json,
  String? diagnosticPath,
  Map<String, dynamic>? shapeFields,
  bool createRequest = false,
}) async {
  final client = HttpClient();
  try {
    final req = await client
        .openUrl(method, Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('User-Agent', 'triply-chat-rules-check/1.0');
    if (idToken != null) req.headers.set('Authorization', 'Bearer $idToken');
    if (json != null) req.write(jsonEncode(json));
    final res = await req.close().timeout(const Duration(seconds: 30));
    final raw = await res.transform(utf8.decoder).join();
    dynamic decoded;
    try {
      decoded = raw.isEmpty ? null : jsonDecode(raw);
    } catch (_) {
      decoded = raw;
    }
    return _Resp(
      res.statusCode,
      decoded,
      path: diagnosticPath,
      fieldShape: shapeFields == null ? null : _fieldShape(shapeFields),
      createRequest: createRequest,
    );
  } finally {
    client.close(force: true);
  }
}

/// Result of one Auth REST sign-in. Diagnostic fields are sanitized: only the
/// HTTP status, the machine-readable Auth error code, and presence flags are
/// ever printed — never the email, password, key, token or uid.
class _SignIn {
  _SignIn({
    this.idToken,
    this.httpStatus,
    this.errorCode,
    this.errorKind,
    String? localId,
  }) : _localId = (localId != null && localId.trim().isNotEmpty)
           ? localId.trim()
           : null;

  final String? idToken;
  final int? httpStatus;
  final String? errorCode;
  final String? errorKind;

  /// Auth's `localId` is the account uid. It is kept private and is never
  /// printed; only its presence may appear in [diagnostic].
  final String? _localId;

  /// Validated uid from the successful Auth response.
  String? get localId => _localId;

  bool get ok => idToken != null && _localId != null;

  String get diagnostic {
    final parts = <String>[
      'http=${httpStatus?.toString() ?? 'none'}',
      if (errorCode != null) 'error=$errorCode',
      if (errorKind != null) 'transport=$errorKind',
      if (idToken != null)
        'localId=${_localId != null ? 'present' : 'missing'}',
    ];
    return parts.join(' ');
  }
}

/// Firebase Auth puts a machine code such as INVALID_LOGIN_CREDENTIALS in
/// `error.message`. Keep only that token shape so arbitrary server text never
/// reaches the console.
String? _authErrorCode(dynamic body) {
  final e = body is Map ? body['error'] : null;
  final m = e is Map ? e['message'] : null;
  if (m is! String || m.trim().isEmpty) return null;
  final code = m.trim().split(RegExp(r'[\s:]')).first;
  return RegExp(r'^[A-Za-z0-9_]+$').hasMatch(code) ? code : 'UNRECOGNIZED';
}

Future<_SignIn> _signIn(String email, String password) async {
  try {
    final r = await _request(
      'POST',
      '$_authBase?key=$_webApiKey',
      json: {'email': email, 'password': password, 'returnSecureToken': true},
    );
    final m = r.body is Map ? r.body as Map : const {};
    final idToken = r.ok && m['idToken'] is String
        ? m['idToken'] as String
        : null;
    final localId = r.ok && m['localId'] is String
        ? m['localId'] as String
        : null;
    return _SignIn(
      idToken: idToken,
      httpStatus: r.status,
      localId: localId,
      errorCode: idToken == null ? _authErrorCode(r.body) : null,
    );
  } catch (e) {
    // Exception messages can embed request data; report only the type.
    return _SignIn(httpStatus: null, errorKind: e.runtimeType.toString());
  }
}

Future<Map<String, dynamic>?> _fsGet(String path, String idToken) async {
  final r = await _request(
    'GET',
    '$_fsBase/$path',
    idToken: idToken,
    diagnosticPath: path,
  );
  if (!r.ok) {
    print('  [request-error] GET ${r.diagnostic}');
    return null;
  }
  return (r.body as Map)['fields'] as Map<String, dynamic>?;
}

/// Writes one document through `documents:commit`.
///
/// Server timestamps cannot be expressed as a Firestore `Value`; they are
/// applied by `updateTransforms` so they resolve to the commit's request time
/// (which is what the rules compare against). Transformed fields are kept out
/// of `update.fields` and out of `updateMask` so no untyped Value is sent.
Future<_Resp> _fsCommit(
  String path,
  Map<String, dynamic> fields,
  String idToken, {
  required bool create,
  List<String>? mask,
}) {
  final plain = <String, dynamic>{
    for (final e in fields.entries)
      if (e.value is! ServerTimestamp) e.key: e.value,
  };
  final transforms = <Map<String, dynamic>>[
    for (final e in fields.entries)
      if (e.value is ServerTimestamp)
        {'fieldPath': e.key, 'setToServerValue': 'REQUEST_TIME'},
  ];
  final write = <String, dynamic>{
    'update': {
      'name': 'projects/$_projectId/databases/(default)/documents/$path',
      'fields': _toFields(plain),
    },
    if (!create && mask != null)
      'updateMask': {
        'fieldPaths': [
          for (final f in mask)
            if (fields[f] is! ServerTimestamp) f,
        ],
      },
    if (transforms.isNotEmpty) 'updateTransforms': transforms,
    if (create) 'currentDocument': {'exists': false},
  };
  return _request(
    'POST',
    '$_fsBase:commit',
    idToken: idToken,
    json: {
      'writes': [write],
    },
    diagnosticPath: path,
    shapeFields: fields,
    createRequest: create,
  );
}

Future<_Resp> _fsCreate(
  String path,
  Map<String, dynamic> fields,
  String idToken,
) {
  return _fsCommit(path, fields, idToken, create: true);
}

Future<_Resp> _fsPatch(
  String path,
  Map<String, dynamic> fields,
  String idToken, {
  required List<String> mask,
}) {
  return _fsCommit(path, fields, idToken, create: false, mask: mask);
}

Future<_Resp> _fsDelete(String path, String idToken) {
  return _request(
    'DELETE',
    '$_fsBase/$path',
    idToken: idToken,
    diagnosticPath: path,
  );
}

class _Check {
  _Check(this.name, this.expectedAllowed);
  final String name;
  final bool expectedAllowed;
  bool actualAllowed = false;
  bool tested = true;

  /// The request failed before/without a security-rules decision (e.g. 400
  /// INVALID_ARGUMENT, 401, 404, 500). It must never count as a denial.
  bool isError = false;
  String detail = '';

  bool get pass => tested && !isError && expectedAllowed == actualAllowed;
}

/// A check whose prerequisite was not met (e.g. the chat or message create
/// failed). It is never a PASS: no rule for the intended predicate ran.
_Check _skipped(String name, bool expectedAllowed, String why) =>
    _Check(name, expectedAllowed)
      ..tested = false
      ..detail = why;

void _record(_Check c, _Resp r) {
  if (r.alreadyExists) {
    // Not a rules decision: the document already existed, so no create was
    // evaluated. Never let this pass a negative check by accident.
    c.tested = false;
    c.detail =
        'HTTP ${r.status}: ALREADY_EXISTS — the document already '
        'exists, so this create was not tested; delete it and re-run';
    return;
  }
  if (r.ok) {
    c.actualAllowed = true;
    c.detail = 'HTTP ${r.status}';
    return;
  }
  if (r.permissionDenied) {
    c.actualAllowed = false;
    c.detail = 'HTTP ${r.status} PERMISSION_DENIED';
  } else {
    c.isError = true;
    c.detail = 'HTTP ${r.status} ${r.firestoreCode ?? 'UNEXPECTED'}';
    print('  [request-error] ${c.name}: ${r.diagnostic}');
    return;
  }
  // A genuine denial on a check that expected success is a FAIL, but still
  // worth a sanitized diagnostic (e.g. a missing report prerequisite).
  if (c.expectedAllowed) {
    print('  [unexpected-denial] ${c.name}: ${r.diagnostic}');
  }
}

/// D25 canonical chat id: the two participant uids sorted lexicographically,
/// joined by '_'. Mirrors `chatCanonicalId()` in firestore.rules. The Firebase
/// Auth uids used by this app are ASCII, so Dart's `compareTo` and the rules'
/// string comparison order the two ids identically.
String _canonicalChatId(String a, String b) =>
    a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

String _tsValue(Map<String, dynamic>? fields, String key) {
  final f = fields?[key];
  if (f is Map) return (f['timestampValue'] ?? '').toString();
  return '';
}

/// Offline guard for the bug that produced
/// "Cannot convert firestore.v1.Value with type unset.": every encoded field
/// must carry exactly one non-null `*Value` discriminator, and no extra field
/// may be added. A server timestamp must never reach `_toValue`.
String? _encodingProblem() {
  final sample = <String, dynamic>{
    'boolean': true,
    'integer': 1,
    'double': 1.5,
    'string': 'x',
    'array': <dynamic>['x', 1, true],
    'map': <String, dynamic>{'nested': 'x'},
    'timestamp': TimestampValue('2020-01-01T00:00:00Z'),
  };
  final encoded = _toFields(sample);
  if (encoded.length != sample.length ||
      encoded.keys.toSet().difference(sample.keys.toSet()).isNotEmpty) {
    return 'encoder added or dropped a field';
  }
  for (final e in encoded.entries) {
    final v = e.value;
    if (v is! Map || v.length != 1) {
      return 'field ${e.key} does not have exactly one discriminator';
    }
    final discriminator = v.entries.single;
    if (!discriminator.key.endsWith('Value')) {
      return 'field ${e.key} uses a non-Value discriminator';
    }
    if (discriminator.value == null) {
      return 'field ${e.key} has a null ${discriminator.key}';
    }
  }
  try {
    _toValue(serverTs);
    return 'server timestamp was encoded as a Value';
  } on StateError {
    // Expected: server timestamps only travel in updateTransforms.
  }
  return null;
}

Future<void> main() async {
  final encodingProblem = _encodingProblem();
  if (encodingProblem != null) {
    print(
      'chat_rules_check: request encoder self-test failed: '
      '$encodingProblem',
    );
    print('No live checks were run.');
    exit(1);
  }

  final env = Platform.environment;
  final required = <String, String?>{
    'CHAT_TEST_TOURIST_EMAIL': env['CHAT_TEST_TOURIST_EMAIL'],
    'CHAT_TEST_TOURIST_PASSWORD': env['CHAT_TEST_TOURIST_PASSWORD'],
    'CHAT_TEST_GUIDE_EMAIL': env['CHAT_TEST_GUIDE_EMAIL'],
    'CHAT_TEST_GUIDE_PASSWORD': env['CHAT_TEST_GUIDE_PASSWORD'],
  };
  final missing = required.entries
      .where((e) => e.value == null || e.value!.trim().isEmpty)
      .map((e) => e.key)
      .toList();
  if (missing.isNotEmpty) {
    print('chat_rules_check: test account credentials are not configured.');
    print('Missing environment variables: ${missing.join(', ')}');
    print('Set them (tourist + guide) and re-run. No live checks were run.');
    exit(0);
  }

  print('chat_rules_check: project=$_projectId');
  final tourist = await _signIn(
    required['CHAT_TEST_TOURIST_EMAIL']!,
    required['CHAT_TEST_TOURIST_PASSWORD']!,
  );
  final guide = await _signIn(
    required['CHAT_TEST_GUIDE_EMAIL']!,
    required['CHAT_TEST_GUIDE_PASSWORD']!,
  );
  print('chat_rules_check: tourist sign-in ${tourist.diagnostic}');
  print('chat_rules_check: guide sign-in ${guide.diagnostic}');
  if (!tourist.ok || !guide.ok) {
    print(
      'chat_rules_check: sign-in failed or the Auth response had no usable '
      'localId (tourist=${tourist.ok}, guide=${guide.ok}). No checks run.',
    );
    exit(1);
  }

  final touristToken = tourist.idToken!;
  final guideToken = guide.idToken!;
  final tUid = tourist.localId!;
  final gUid = guide.localId!;
  print('chat_rules_check: both test accounts resolved a uid.');
  if (tUid == gUid) {
    print(
      'chat_rules_check: the two test accounts resolved to the same uid. '
      'No checks were run.',
    );
    exit(1);
  }

  // Self-test both lexical orders. A live account pair only has one order, so
  // this proves the checker handles the other one and that the expectation
  // matches the rules before any live call is made.
  if (_canonicalChatId('aaa', 'zzz') != 'aaa_zzz' ||
      _canonicalChatId('zzz', 'aaa') != 'aaa_zzz') {
    print(
      'chat_rules_check: canonical chat id self-test failed. No live '
      'checks were run.',
    );
    exit(1);
  }

  final chatId = _canonicalChatId(tUid, gUid);
  final touristFirstId = '${tUid}_$gUid';
  final otherOrderingId = touristFirstId == chatId
      ? '${gUid}_$tUid'
      : touristFirstId;
  print(
    'chat_rules_check: canonical chat id=$chatId '
    '(non-canonical order: $otherOrderingId)',
  );

  final chatPath = 'chats/$chatId';
  final otherOrderingPath = 'chats/$otherOrderingId';
  final msgId = 'c1check_msg';
  final msgPath = '$chatPath/messages/$msgId';

  final checks = <_Check>[];
  final created = <String>[];

  Map<String, dynamic> chatFields() => {
    'touristId': tUid,
    'guideId': gUid,
    'participants': [tUid, gUid],
    'profiles': {
      tUid: {'displayName': 'Test Tourist', 'avatarUrl': ''},
      gUid: {'displayName': 'Test Guide', 'avatarUrl': ''},
    },
    'unreadCount': {tUid: 0, gUid: 0},
    'createdAt': serverTs,
  };

  // 2. guide tries to create a chat with a tourist (denied). This runs before
  // the tourist's create so the canonical id does not exist yet: the request
  // is denied by the role rule, not by an ALREADY_EXISTS collision.
  {
    final c = _Check('guide creates a chat (denied)', false);
    final r = await _fsCreate(chatPath, {
      'touristId': gUid,
      'guideId': tUid,
      'participants': [gUid, tUid],
      'profiles': {
        gUid: {'displayName': 'x', 'avatarUrl': ''},
        tUid: {'displayName': 'x', 'avatarUrl': ''},
      },
      'unreadCount': {gUid: 0, tUid: 0},
      'createdAt': serverTs,
    }, guideToken);
    _record(c, r);
    if (r.ok || r.alreadyExists) created.add(chatPath);
    checks.add(c);
  }

  // 1. tourist creates the chat at the canonical id (allowed) — bare chat.
  var chatReady = false;
  {
    final c = _Check('tourist creates the canonical chat', true);
    final r = await _fsCreate(chatPath, chatFields(), touristToken);
    _record(c, r);
    chatReady = r.ok;
    if (r.ok) created.add(chatPath);
    checks.add(c);
  }

  // 1b. the same tourist uses the reversed id (denied): only the sorted id is
  // accepted, so the pair cannot end up with two chats.
  {
    final c = _Check('tourist creates chat at reversed id (denied)', false);
    final r = await _fsCreate(otherOrderingPath, chatFields(), touristToken);
    _record(c, r);
    if (r.ok || r.alreadyExists) created.add(otherOrderingPath);
    checks.add(c);
  }

  // 3. tourist creates a chat with a non-guide uid (denied).
  {
    final fakeGuide = 'not-a-guide-${DateTime.now().millisecondsSinceEpoch}';
    final fakeGuidePath = 'chats/${_canonicalChatId(tUid, fakeGuide)}';
    final c = _Check('tourist creates chat with non-guide (denied)', false);
    final r = await _fsCreate(fakeGuidePath, {
      'touristId': tUid,
      'guideId': fakeGuide,
      'participants': [tUid, fakeGuide],
      'profiles': {
        tUid: {'displayName': 'x', 'avatarUrl': ''},
        fakeGuide: {'displayName': 'x', 'avatarUrl': ''},
      },
      'unreadCount': {tUid: 0, fakeGuide: 0},
      'createdAt': serverTs,
    }, touristToken);
    _record(c, r);
    if (r.ok || r.alreadyExists) created.add(fakeGuidePath);
    checks.add(c);
  }

  // 4. a third account cannot read the chat (denied).
  {
    final thirdEmail = env['CHAT_TEST_THIRD_EMAIL'];
    final thirdPass = env['CHAT_TEST_THIRD_PASSWORD'];
    if (thirdEmail != null &&
        thirdPass != null &&
        thirdEmail.isNotEmpty &&
        thirdPass.isNotEmpty) {
      final third = await _signIn(thirdEmail, thirdPass);
      if (third.ok) {
        final c = _Check('third account reads the chat (denied)', false);
        final r = await _request(
          'GET',
          '$_fsBase/$chatPath',
          idToken: third.idToken!,
          diagnosticPath: chatPath,
        );
        _record(c, r);
        checks.add(c);
      } else {
        checks.add(
          _Check('third account reads the chat (denied)', false)
            ..detail =
                'third account sign-in failed (${third.diagnostic}); '
                'not tested',
        );
      }
    } else {
      // No third account: prove a non-participant (unauthenticated) is denied.
      final c = _Check('unauthenticated reads the chat (denied)', false);
      final r = await _request(
        'GET',
        '$_fsBase/$chatPath',
        diagnosticPath: chatPath,
      );
      _record(c, r);
      checks.add(c);
      checks.add(
        _Check('third account reads the chat (denied)', false)
          ..detail = 'no third account provided; not tested',
      );
    }
  }

  // 5. either participant sends a message (allowed).
  String? msgCreatedAt;
  var messageReady = false;
  {
    final c = _Check('tourist sends a message', true);
    final r = await _fsCreate(msgPath, {
      'senderId': tUid,
      'text': 'hello from the rules check',
      'createdAt': serverTs,
    }, touristToken);
    _record(c, r);
    messageReady = r.ok;
    if (r.ok) {
      created.add(msgPath);
      final doc = await _fsGet(msgPath, touristToken);
      msgCreatedAt = _tsValue(doc, 'createdAt');
    }
    checks.add(c);
  }

  // 6. a message with createdAt not equal to request time (denied). A real
  // timestamp is sent (not a string) so the denial comes from the time
  // equality rule, not from a type mismatch.
  if (!chatReady) {
    checks.add(
      _skipped(
        'message createdAt != request time (denied)',
        false,
        'chat prerequisite missing; no rules decision was evaluated',
      ),
    );
  } else {
    final c = _Check('message createdAt != request time (denied)', false);
    final r = await _fsCreate('$chatPath/messages/c1check_bad', {
      'senderId': tUid,
      'text': 'backdated',
      'createdAt': TimestampValue('2020-01-01T00:00:00Z'),
    }, touristToken);
    _record(c, r);
    if (r.ok) created.add('$chatPath/messages/c1check_bad');
    checks.add(c);
  }

  // 7. text over 20000 characters (denied).
  if (!chatReady) {
    checks.add(
      _skipped(
        'message text over 20000 chars (denied)',
        false,
        'chat prerequisite missing; no rules decision was evaluated',
      ),
    );
  } else {
    final c = _Check('message text over 20000 chars (denied)', false);
    final r = await _fsCreate('$chatPath/messages/c1check_big', {
      'senderId': tUid,
      'text': 'a' * 20001,
      'createdAt': serverTs,
    }, touristToken);
    _record(c, r);
    if (r.ok) created.add('$chatPath/messages/c1check_big');
    checks.add(c);
  }

  // 8. edit by the sender (allowed) and by the other person (denied).
  if (!messageReady) {
    const why = 'message prerequisite missing; no message rule was evaluated';
    checks.add(_skipped('sender edits own message', true, why));
    checks.add(_skipped('other person edits the message (denied)', false, why));
  } else {
    final c1 = _Check('sender edits own message', true);
    final r1 = await _fsPatch(
      msgPath,
      {'text': 'edited by the sender', 'editedAt': serverTs},
      touristToken,
      mask: ['text', 'editedAt'],
    );
    _record(c1, r1);
    checks.add(c1);

    final c2 = _Check('other person edits the message (denied)', false);
    final r2 = await _fsPatch(
      msgPath,
      {'text': 'edited by the other', 'editedAt': serverTs},
      guideToken,
      mask: ['text', 'editedAt'],
    );
    _record(c2, r2);
    checks.add(c2);
  }

  // 10/11 need the real message document and its createdAt. Without them the
  // report rule's get() comparisons cannot be evaluated, so a 403 would not
  // prove anything about the copied text.
  final reportReady =
      messageReady && msgCreatedAt != null && msgCreatedAt.isNotEmpty;
  if (!reportReady) {
    const why =
        'message prerequisite missing (message create or read failed), so the '
        'report get() checks could not be evaluated; not tested';
    checks.add(_skipped('report with wrong copied text (denied)', false, why));
    checks.add(_skipped('report with the right copied text', true, why));
  } else {
    final messageTime = TimestampValue(msgCreatedAt);

    // 10. report with the copied text different from the real one (denied).
    {
      final c = _Check('report with wrong copied text (denied)', false);
      final r = await _fsCreate('reports/${gUid}_$msgId', {
        'reporterId': gUid,
        'reportedUserId': tUid,
        'chatId': chatId,
        'messageId': msgId,
        'text': 'this does not match the real message',
        'messageCreatedAt': messageTime,
        'reasonCode': 'spam',
        'note': '',
        'status': 'open',
      }, guideToken);
      _record(c, r);
      if (r.ok) created.add('reports/${gUid}_$msgId');
      checks.add(c);
    }

    // 11. report with the right text (allowed).
    {
      final c = _Check('report with the right copied text', true);
      final r = await _fsCreate('reports/${gUid}_$msgId', {
        'reporterId': gUid,
        'reportedUserId': tUid,
        'chatId': chatId,
        'messageId': msgId,
        'text': 'edited by the sender',
        'messageCreatedAt': messageTime,
        'reasonCode': 'spam',
        'note': 'test report',
        'status': 'open',
      }, guideToken);
      _record(c, r);
      if (r.ok) created.add('reports/${gUid}_$msgId');
      checks.add(c);
    }
  }

  // 12. updating another user's profiles entry or lastReadAt entry (denied).
  if (!chatReady) {
    const why = 'chat prerequisite missing; no update rule was evaluated';
    checks.add(
      _skipped('tourist updates guide profiles entry (denied)', false, why),
    );
    checks.add(
      _skipped('tourist updates guide lastReadAt (denied)', false, why),
    );
  } else {
    final c1 = _Check('tourist updates guide profiles entry (denied)', false);
    final r1 = await _fsPatch(
      chatPath,
      {
        'profiles': {
          tUid: {'displayName': 'Test Tourist', 'avatarUrl': ''},
          gUid: {'displayName': 'HACKED', 'avatarUrl': ''},
        },
      },
      touristToken,
      mask: ['profiles'],
    );
    _record(c1, r1);
    checks.add(c1);

    final c2 = _Check('tourist updates guide lastReadAt (denied)', false);
    final r2 = await _fsPatch(
      chatPath,
      {
        'unreadCount': {tUid: 0, gUid: 0},
        'lastReadAt': {gUid: TimestampValue('2020-01-01T00:00:00Z')},
      },
      touristToken,
      mask: ['unreadCount', 'lastReadAt'],
    );
    _record(c2, r2);
    checks.add(c2);
  }

  // 9. admin reading the chat (denied) — only if a test admin exists.
  {
    final adminEmail = env['CHAT_TEST_ADMIN_EMAIL'];
    final adminPass = env['CHAT_TEST_ADMIN_PASSWORD'];
    if (adminEmail != null &&
        adminPass != null &&
        adminEmail.isNotEmpty &&
        adminPass.isNotEmpty) {
      final admin = await _signIn(adminEmail, adminPass);
      if (admin.ok) {
        final c = _Check('admin reads the chat (denied)', false);
        final r = await _request(
          'GET',
          '$_fsBase/$chatPath',
          idToken: admin.idToken!,
          diagnosticPath: chatPath,
        );
        _record(c, r);
        checks.add(c);
      } else {
        checks.add(
          _Check('admin reads the chat (denied)', false)
            ..detail = 'admin sign-in failed (${admin.diagnostic}); not tested',
        );
      }
    } else {
      checks.add(
        _Check('admin reads the chat (denied)', false)
          ..detail = 'no admin account provided; not tested',
      );
    }
  }

  // ---- report ----
  print('');
  print('=== chat rules check results ===');
  var failures = 0;
  for (final c in checks) {
    final status = c.isError
        ? 'ERROR'
        : !c.tested ||
              c.detail.startsWith('no ') ||
              c.detail.contains('not tested') ||
              c.detail.contains('sign-in failed')
        ? 'SKIP'
        : (c.pass ? 'PASS' : 'FAIL');
    if (status == 'FAIL' || status == 'ERROR') failures++;
    final expect = c.expectedAllowed ? 'allowed' : 'denied';
    print(
      '[$status] ${c.name} (expected: $expect) — ${c.detail.isEmpty ? (c.actualAllowed ? "allowed" : "denied") : c.detail}',
    );
  }
  print('');
  print('failures: $failures');

  // ---- cleanup (client API only; the rules allow deleting own messages) ----
  print('');
  print('=== cleanup ===');
  final remaining = <String>[];
  // Delete the message the tourist created (sender may delete within 24h).
  if (messageReady) {
    final delMsg = await _fsDelete(msgPath, touristToken);
    print(
      'delete message $msgId: '
      '${delMsg.ok ? "ok" : "denied (will remain)"}',
    );
    if (!delMsg.ok) remaining.add(msgPath);
  } else {
    print('delete message $msgId: skipped (no message was created)');
  }
  // The chat and the report have no client delete; list them for Khaled.
  // Any chat document that unexpectedly succeeded is listed too, including
  // the reversed-id probe if the rules were misconfigured.
  for (final p in created) {
    if (p.startsWith('chats/') && !p.contains('/messages/')) {
      remaining.add(p);
    }
  }
  remaining.add(chatPath);
  remaining.add('reports/${gUid}_$msgId');
  if (remaining.isNotEmpty) {
    print(
      'The following documents cannot be deleted by the client (no client '
      'delete rule) and no Admin SDK credentials are in the environment.',
    );
    print('Delete them in the Firebase Console (project $_projectId):');
    for (final p in remaining.toSet()) {
      print('  - $p');
    }
  }

  exit(failures == 0 ? 0 : 2);
}
