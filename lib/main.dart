import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initializeCrashlytics();
  await _initializeAnalytics();

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const MyApp());
}

Future<void> _initializeAnalytics() async {
  // Enable debug mode in development to see events in DebugView
  // if (kDebugMode) {
  if (true) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    // Enable debug mode to see events in the Firebase console's DebugView
    await FirebaseAnalytics.instance.setConsent(
      adStorageConsentGranted: true,
      analyticsStorageConsentGranted: true,
    );
  }

  debugPrint('Firebase Analytics initialized successfully');
}

Future<void> _initializeCrashlytics() async {
  // Skip Crashlytics initialization on web platform as it's not supported
  if (kIsWeb) {
    debugPrint(
      'Crashlytics não é suportado na plataforma web. Pulando inicialização.',
    );
    return;
  }

  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set custom keys for better debugging
  await FirebaseCrashlytics.instance.setCustomKey(
    'app_mode',
    kDebugMode ? 'debug' : 'release',
  );
  await FirebaseCrashlytics.instance.setCustomKey(
    'platform',
    defaultTargetPlatform.toString(),
  );

  // Enable Crashlytics data collection
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Log a test exception to verify the setup
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.log(
      'Inicialização do Crashlytics concluída',
    );
    debugPrint('Exceção de teste registrada para verificar a configuração do Crashlytics');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthenticationProvider(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Chat App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF773DFA),
                surfaceTint: const Color(0xFF1A172A),
                surface: const Color(0xFFF2F2F2),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            routerConfig: createRouter(context),
          );
        },
      ),
    );
  }
}
