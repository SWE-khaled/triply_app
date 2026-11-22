import 'package:cloud_firestore/cloud_firestore.dart';

/// Runs [handler] inside a Firestore transaction without letting a Dart-side
/// error race the plugin's own error/complete stream.
///
/// `cloud_firestore` completes its internal future as soon as native reports
/// the transaction result. If the handler throws *after* that (for example
/// because an awaited `tx.get` fails at the same moment native aborts), the
/// plugin tries to call `completeError` a second time and the app crashes with
/// `Bad state: Future already completed`.
///
/// Catching inside the handler avoids that second completion. All reads in
/// this app happen before any writes, so returning early on an error leaves an
/// empty transaction (no partial writes); the original error is then rethrown
/// to the caller from here. A native error still propagates from
/// [FirebaseFirestore.runTransaction] as usual.
Future<void> runSafeTransaction(
  FirebaseFirestore db,
  Future<void> Function(Transaction tx) handler,
) async {
  Object? handlerError;
  StackTrace? handlerStack;

  await db.runTransaction((tx) async {
    try {
      await handler(tx);
    } catch (error, stack) {
      handlerError = error;
      handlerStack = stack;
    }
  });

  final error = handlerError;
  if (error != null) {
    Error.throwWithStackTrace(error, handlerStack ?? StackTrace.empty);
  }
}
