import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_paths.dart';
import '../models/app_settings_doc.dart';

/// `appSettings/{settingId}` reads. Only admin (Functions/console) writes;
/// clients get a typed snapshot with offline-safe defaults.
class AppSettingsDatasource {
  FirebaseFirestore? _dbInit;
  AppSettingsDatasource([FirebaseFirestore? db]) : _dbInit = db;

  // Lazy: constructing the datasource must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  FirebaseFirestore get _db => _dbInit ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.appSettings);

  Future<List<AppSettingsDoc>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map(AppSettingsDoc.fromFirestore).toList();
  }

  Future<OperationalSettings> getOperational() async {
    try {
      return OperationalSettings.fromDocs(await getAll());
    } catch (_) {
      return const OperationalSettings();
    }
  }

  Stream<OperationalSettings> streamOperational() {
    return _col.snapshots().map(
      (s) => OperationalSettings.fromDocs(
        s.docs.map(AppSettingsDoc.fromFirestore).toList(),
      ),
    );
  }

  /// Admin-only write (rules: `appSettings` write is admin-only; clients
  /// get permission-denied). Stores the raw value with audit metadata.
  Future<void> setValue(
    String id,
    dynamic value, {
    String updatedBy = '',
  }) async {
    await _col.doc(id).set({
      'value': value,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
