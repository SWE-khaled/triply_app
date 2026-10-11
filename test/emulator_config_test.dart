import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/emulator_config.dart';

/// Unit tests for the emulator-mode safety gate. Pure string validation —
/// no Firebase, no network, so these run on the VM. They prove that
/// production can never be selected through this path.
void main() {
  const good = {
    'projectId': 'demo-localtest',
    'firestore': '127.0.0.1:8090',
    'auth': '127.0.0.1:9099',
    'functionsHost': '127.0.0.1',
  };
  const goodPort = 5001;

  EmulatorConfig valid() => EmulatorConfig.validate(
    projectId: good['projectId']!,
    firestore: good['firestore']!,
    auth: good['auth']!,
    functionsHost: good['functionsHost']!,
    functionsPort: goodPort,
  );

  group('EmulatorConfig.validate', () {
    test('accepts a well-formed demo configuration', () {
      final config = valid();
      expect(config.projectId, 'demo-localtest');
      expect(config.firestoreHost, '127.0.0.1');
      expect(config.firestorePort, 8090);
      expect(config.authHost, '127.0.0.1');
      expect(config.authPort, 9099);
      expect(config.functionsHost, '127.0.0.1');
      expect(config.functionsPort, 5001);
    });

    test('accepts Android-emulator loopback hosts', () {
      final config = EmulatorConfig.validate(
        projectId: 'demo-x',
        firestore: '10.0.2.2:8090',
        auth: '10.0.2.2:9099',
        functionsHost: '10.0.2.2',
        functionsPort: 5001,
      );
      expect(config.firestoreHost, '10.0.2.2');
    });

    test('rejects the production project id', () {
      expect(
        () => EmulatorConfig.validate(
          projectId: 'triply-f9b82',
          firestore: good['firestore']!,
          auth: good['auth']!,
          functionsHost: good['functionsHost']!,
          functionsPort: goodPort,
        ),
        throwsA(
          predicate((e) => e is StateError && e.message.contains('demo-')),
        ),
      );
    });

    test('rejects empty and non-demo project ids', () {
      // Note: surrounding whitespace is trimmed before the check, so only
      // genuinely non-demo ids are rejected here.
      for (final bad in ['', 'prod', 'triply-f9b82', 'DEMO-x']) {
        expect(
          () => EmulatorConfig.validate(
            projectId: bad,
            firestore: good['firestore']!,
            auth: good['auth']!,
            functionsHost: good['functionsHost']!,
            functionsPort: goodPort,
          ),
          throwsStateError,
          reason: 'project "$bad"',
        );
      }
    });

    test('rejects malformed endpoints and bad ports', () {
      for (final bad in [
        '',
        'localhost',
        'host:',
        ':8090',
        'host:0',
        'host:99999',
        'host:abc',
      ]) {
        expect(
          () => EmulatorConfig.validate(
            projectId: good['projectId']!,
            firestore: bad,
            auth: good['auth']!,
            functionsHost: good['functionsHost']!,
            functionsPort: goodPort,
          ),
          throwsStateError,
          reason: 'endpoint "$bad"',
        );
      }
      expect(
        () => EmulatorConfig.validate(
          projectId: good['projectId']!,
          firestore: good['firestore']!,
          auth: good['auth']!,
          functionsHost: good['functionsHost']!,
          functionsPort: 0,
        ),
        throwsStateError,
      );
      expect(
        () => EmulatorConfig.validate(
          projectId: good['projectId']!,
          firestore: good['firestore']!,
          auth: good['auth']!,
          functionsHost: '',
          functionsPort: goodPort,
        ),
        throwsStateError,
      );
    });

    test('rejects Google production hosts on every service', () {
      const prodHosts = [
        'firestore.googleapis.com:443',
        'identitytoolkit.googleapis.com:443',
        'us-central1-triply-f9b82.cloudfunctions.net:443',
      ];
      for (final host in prodHosts) {
        expect(
          () => EmulatorConfig.validate(
            projectId: good['projectId']!,
            firestore: host,
            auth: good['auth']!,
            functionsHost: good['functionsHost']!,
            functionsPort: goodPort,
          ),
          throwsStateError,
          reason: 'firestore "$host"',
        );
        expect(
          () => EmulatorConfig.validate(
            projectId: good['projectId']!,
            firestore: good['firestore']!,
            auth: host,
            functionsHost: good['functionsHost']!,
            functionsPort: goodPort,
          ),
          throwsStateError,
          reason: 'auth "$host"',
        );
      }
      expect(
        () => EmulatorConfig.validate(
          projectId: good['projectId']!,
          firestore: good['firestore']!,
          auth: good['auth']!,
          functionsHost: 'us-central1-triply-f9b82.cloudfunctions.net',
          functionsPort: goodPort,
        ),
        throwsStateError,
      );
    });

    test('parseEndpoint splits host and port', () {
      expect(EmulatorConfig.parseEndpoint('127.0.0.1:8090', 'X'), (
        host: '127.0.0.1',
        port: 8090,
      ));
    });
  });
}
