// One-off backfill: writes `users.displayName` for existing users from
// their existing name fields (`fullName` or `name`).
//
// Run once, only after printing how many documents it would touch AND
// getting Khaled's yes. Ignore the 3 legacy bookings.
//
// Usage (dry run — just prints the count):
//   dart run tool/backfill_display_name.dart
//
// Usage (perform the backfill — Khaled's yes required first):
//   dart run tool/backfill_display_name.dart --apply
// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

void _log(String message) {
  print(message);
}

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final db = FirebaseFirestore.instance;

  final snapshot = await db.collection('users').get();
  int wouldTouch = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final hasDisplayName =
        (data['displayName'] as String?)?.isNotEmpty ?? false;
    final fullName = (data['fullName'] as String?)?.trim() ?? '';
    final name = (data['name'] as String?)?.trim() ?? '';
    if (!hasDisplayName && (fullName.isNotEmpty || name.isNotEmpty)) {
      wouldTouch++;
    }
  }

  _log('Users without displayName but with a name field: $wouldTouch');
  if (!apply) {
    _log('Dry run only. Re-run with --apply to perform the backfill.');
    _log("Khaled's yes is required before applying.");
    return;
  }

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final hasDisplayName =
        (data['displayName'] as String?)?.isNotEmpty ?? false;
    if (hasDisplayName) continue;
    final fullName = (data['fullName'] as String?)?.trim() ?? '';
    final name = (data['name'] as String?)?.trim() ?? '';
    final displayName = fullName.isNotEmpty ? fullName : name;
    if (displayName.isEmpty) continue;
    await db.collection('users').doc(doc.id).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
  }

  _log('Backfill complete: $wouldTouch users updated.');
}
