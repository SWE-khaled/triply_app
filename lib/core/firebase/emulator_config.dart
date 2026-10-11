/// Explicit local-emulator configuration for manual testing.
///
/// Production Firebase (`triply-f9b82` via `DefaultFirebaseOptions`) stays
/// the default for normal builds. Emulator mode is opt-in through
/// `lib/main_emulator.dart` + `--dart-define` values only — never by
/// editing production configuration.
///
/// Safety contract (all enforced by [EmulatorConfig.validate]):
/// - the project id MUST start with `demo-` (the production id and any
///   non-demo id are refused before Firebase initializes);
/// - endpoint hosts must be explicit and must not belong to Google
///   production endpoints (`googleapis.com`, `firebaseio.com`, ...);
/// - ports must be numeric TCP ports;
/// - anything invalid throws a [StateError] with a clear message, and the
///   app shows a blocking error screen instead of starting (fail-safe:
///   no silent fallback to production exists anywhere in this path).
/// No secrets or credentials live here — hosts, ports and the demo
/// project id are not sensitive.
class EmulatorConfig {
  final String projectId;
  final String firestoreHost;
  final int firestorePort;
  final String authHost;
  final int authPort;
  final String functionsHost;
  final int functionsPort;

  const EmulatorConfig({
    required this.projectId,
    required this.firestoreHost,
    required this.firestorePort,
    required this.authHost,
    required this.authPort,
    required this.functionsHost,
    required this.functionsPort,
  });

  /// Parses `host:port` (host may itself contain colons only in bracketed
  /// IPv6 form, which is stripped). Throws [StateError] when malformed.
  static ({String host, int port}) parseEndpoint(String value, String name) {
    final trimmed = value.trim();
    final sep = trimmed.lastIndexOf(':');
    if (sep <= 0 || sep == trimmed.length - 1) {
      throw StateError(
        'Triply emulator mode: $name must look like "host:port" '
        '(got "$value"). Pass it via --dart-define.',
      );
    }
    var host = trimmed.substring(0, sep).trim();
    if (host.startsWith('[') && host.endsWith(']')) {
      host = host.substring(1, host.length - 1);
    }
    final port = int.tryParse(trimmed.substring(sep + 1).trim());
    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      throw StateError(
        'Triply emulator mode: $name must look like "host:port" '
        '(got "$value"). Pass it via --dart-define.',
      );
    }
    final lower = host.toLowerCase();
    for (final banned in [
      'googleapis.com',
      'firebaseio.com',
      'firebaseapp.com',
      'cloudfunctions.net',
    ]) {
      if (lower == banned || lower.endsWith('.$banned')) {
        throw StateError(
          'Triply emulator mode: $name must point at a LOCAL emulator, '
          'not "$host". Refusing to start.',
        );
      }
    }
    return (host: host, port: port);
  }

  /// Validates raw `--dart-define` inputs. Throws [StateError] on anything
  /// that could resolve to production (or is simply unusable).
  static EmulatorConfig validate({
    required String projectId,
    required String firestore,
    required String auth,
    required String functionsHost,
    required int functionsPort,
  }) {
    final project = projectId.trim();
    if (!project.startsWith('demo-')) {
      throw StateError(
        'Triply emulator mode: project id must start with "demo-" '
        '(got "$projectId"). Production Firebase is never used here.',
      );
    }
    final fs = parseEndpoint(firestore, 'TRIPLY_EMULATOR_HOST');
    final au = parseEndpoint(auth, 'TRIPLY_EMULATOR_AUTH_HOST');
    final fnHost = functionsHost.trim();
    if (fnHost.isEmpty) {
      throw StateError(
        'Triply emulator mode: TRIPLY_EMULATOR_FUNCTIONS_HOST is empty. '
        'Pass it via --dart-define.',
      );
    }
    final fnLower = fnHost.toLowerCase();
    for (final banned in [
      'googleapis.com',
      'firebaseio.com',
      'firebaseapp.com',
      'cloudfunctions.net',
    ]) {
      if (fnLower == banned || fnLower.endsWith('.$banned')) {
        throw StateError(
          'Triply emulator mode: functions host must be a LOCAL emulator, '
          'not "$fnHost". Refusing to start.',
        );
      }
    }
    if (functionsPort < 1 || functionsPort > 65535) {
      throw StateError(
        'Triply emulator mode: TRIPLY_EMULATOR_FUNCTIONS_PORT must be a '
        'TCP port (got $functionsPort). Pass it via --dart-define.',
      );
    }
    return EmulatorConfig(
      projectId: project,
      firestoreHost: fs.host,
      firestorePort: fs.port,
      authHost: au.host,
      authPort: au.port,
      functionsHost: fnHost,
      functionsPort: functionsPort,
    );
  }
}
