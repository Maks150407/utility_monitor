import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/readings/add_reading_screen.dart';

void main() {
  runApp(const UtilityMonitorApp());
}

class UtilityMonitorApp extends StatelessWidget {
  const UtilityMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Монітор комунальних витрат',
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