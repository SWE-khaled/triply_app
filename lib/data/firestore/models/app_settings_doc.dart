import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `appSettings/{settingId}` document.
///
/// Only OPERATIONAL settings live here (things that change business
/// behavior). Visual theme constants stay in Flutter. Only admin may write.
/// Known keys (see Admin Settings screen):
/// - `serviceFeeRate` (double, e.g. 0.05)
/// - `privateServiceFeeRate` (double)
/// - `currency` (String, e.g. EGP)
/// - `maintenanceMode` (bool)
/// - `minAppVersion` (String)
class AppSettingsDoc {
  final String id;
  final dynamic value;
  final String updatedBy;
  final DateTime? updatedAt;

  const AppSettingsDoc({
    required this.id,
    required this.value,
    this.updatedBy = '',
    this.updatedAt,
  });

  factory AppSettingsDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return AppSettingsDoc(
      id: doc.id,
      value: d['value'],
      updatedBy: FirestoreConverters.toStr(d['updatedBy']),
      updatedAt: FirestoreConverters.toDateTime(d['updatedAt']),
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      'value': value,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Typed accessor for the operational settings the app actually reads.
/// Firestore is the source; hardcoded defaults keep the app working offline.
class OperationalSettings {
  final double serviceFeeRate;
  final double privateServiceFeeRate;
  final String currency;
  final bool maintenanceMode;
  final String minAppVersion;

  const OperationalSettings({
    this.serviceFeeRate = 0.05,
    this.privateServiceFeeRate = 0.05,
    this.currency = 'EGP',
    this.maintenanceMode = false,
    this.minAppVersion = '1.0.0',
  });

  factory OperationalSettings.fromDocs(List<AppSettingsDoc> docs) {
    dynamic val(String id) => docs
        .where((d) => d.id == id)
        .map((d) => d.value)
        .firstOrNull;
    return OperationalSettings(
      serviceFeeRate: FirestoreConverters.toDouble(
        val('serviceFeeRate'),
        0.05,
      ),
      privateServiceFeeRate: FirestoreConverters.toDouble(
        val('privateServiceFeeRate'),
        0.05,
      ),
      currency: FirestoreConverters.toStr(val('currency'), 'EGP'),
      maintenanceMode: FirestoreConverters.toBool(val('maintenanceMode')),
      minAppVersion: FirestoreConverters.toStr(val('minAppVersion'), '1.0.0'),
    );
  }
}
