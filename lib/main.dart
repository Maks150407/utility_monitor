import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/readings/add_reading_screen.dart';
import 'services/analytics_service.dart';
import 'services/crash_reporting_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Налаштування перехоплення помилок для Crashlytics / моніторингу стабільності
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    CrashReportingService.instance.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    CrashReportingService.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Безпечна ініціалізація Firebase та сервісів
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase.initializeApp() warning: $e');
    CrashReportingService.instance.recordError(
      e,
      stack,
      reason: 'Firebase initialization (running in safe mode)',
    );
  }

  AnalyticsService.instance.initialize();
  AuthRepository.instance.initialize();

  runApp(const UtilityMonitorApp());
}

class UtilityMonitorApp extends StatelessWidget {
  const UtilityMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final observer = AnalyticsService.instance.observer;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Монітор комунальних витрат',
      navigatorObservers: [
        if (observer != null) observer,
      ],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const MainShellScreen(initialIndex: 0),
        '/readings': (context) => const MainShellScreen(initialIndex: 1),
        '/profile': (context) => const MainShellScreen(initialIndex: 2),
        '/add_reading': (context) => const AddReadingScreen(),
      },
    );
  }
}
