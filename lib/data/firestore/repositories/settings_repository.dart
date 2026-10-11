import 'package:triply/data/firestore/datasources/app_settings_datasource.dart';
import 'package:triply/data/firestore/models/app_settings_doc.dart';

/// Operational settings (fee rates, currency, maintenance). Offline-safe:
/// Firestore first, hardcoded defaults on any failure.
class SettingsRepository {
  final AppSettingsDatasource _ds;
  SettingsRepository([AppSettingsDatasource? ds])
      : _ds = ds ?? AppSettingsDatasource();

  Future<OperationalSettings> operational() => _ds.getOperational();

  Stream<OperationalSettings> streamOperational() => _ds.streamOperational();
}
