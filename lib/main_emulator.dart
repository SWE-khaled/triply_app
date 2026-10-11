import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:triply/core/firebase/emulator_config.dart';
import 'package:triply/main.dart' as app;

/// Explicit LOCAL-EMULATOR entry point for manual testing.
///
/// Production (`lib/main.dart` + `DefaultFirebaseOptions`) is untouched and
/// stays the default. Run THIS target only for isolated testing:
///
/// ```sh
/// flutter run -d chrome --target lib/main_emulator.dart \
///   --dart-define=TRIPLY_EMULATOR_PROJECT=demo-localtest \
///   --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090 \
///   --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099 \
///   --dart-define=TRIPLY_EMULATOR_FUNCTIONS_HOST=127.0.0.1 \
///   --dart-define=TRIPLY_EMULATOR_FUNCTIONS_PORT=5001
/// ```
///
/// What it does, in order (before any Firebase service is used):
/// 1. validates the demo configuration ([EmulatorConfig.validate] refuses
///    production ids/hosts with a clear error);
/// 2. initializes the DEFAULT Firebase app with the demo project id, so
///    every existing `FirebaseAuth/Firestore/Functions.instance` call site
///    (the whole app uses default-app singletons) hits the emulators;
/// 3. points Auth, Firestore (no persistence: no cross-run cache
///    confusion) and Functions at their emulator endpoints;
/// 4. loads `.env` (best-effort, as production does) and runs the real app.
///
/// There is NO fallback to production: misconfiguration shows a blocking
/// error screen instead of starting, and an unreachable emulator surfaces
/// as ordinary (already-handled) loading/error states in each screen.
///
/// Known emulator-mode limits (not Firebase, unchanged by this file):
/// Google sign-in (real OAuth), Paymob checkout (external sandbox, fails
/// closed without keys), and Cloudinary uploads (external dev account).
const _project = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: '',
);
const _firestore = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '',
);
const _auth = String.fromEnvironment(
  'TRIPLY_EMULATOR_AUTH_HOST',
  defaultValue: '',
);
const _functionsHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_FUNCTIONS_HOST',
  defaultValue: '',
);
const _functionsPort = int.fromEnvironment(
  'TRIPLY_EMULATOR_FUNCTIONS_PORT',
  defaultValue: -1,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final EmulatorConfig config;
  try {
    config = EmulatorConfig.validate(
      projectId: _project,
      firestore: _firestore,
      auth: _auth,
      functionsHost: _functionsHost,
      functionsPort: _functionsPort,
    );
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'emulator-only',
        appId: '1:1:web:emulator',
        messagingSenderId: '0',
        projectId: config.projectId,
      ),
    );
    await FirebaseAuth.instance.useAuthEmulator(
      config.authHost,
      config.authPort,
    );
    FirebaseFirestore.instance.settings = Settings(
      host: '${config.firestoreHost}:${config.firestorePort}',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    FirebaseFunctions.instance.useFunctionsEmulator(
      config.functionsHost,
      config.functionsPort,
    );
  } catch (e) {
    // Observable marker (log-only, no secrets): proves the block path.
    debugPrint('Triply emulator mode: BLOCKED ($e)');
    runApp(_ConfigErrorApp(message: e.toString()));
    return;
  }
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  // Observable marker (log-only: demo project id and hosts are not
  // sensitive): proves the app booted against the demo configuration.
  debugPrint(
    'Triply emulator mode: app started on ${config.projectId} '
    '(fs=${config.firestoreHost}:${config.firestorePort})',
  );
  runApp(const app.MyApp());
}

/// Blocking startup error: explains the misconfiguration instead of
/// starting the app against an unknown backend.
class _ConfigErrorApp extends StatelessWidget {
  final String message;
  const _ConfigErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emulator mode is not configured.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                const Text(
                  'The app was NOT started, and production Firebase was '
                  'NOT contacted. Relaunch with the --dart-define values '
                  'from lib/main_emulator.dart.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
