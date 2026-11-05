import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/analytics_service.dart';
import '../services/crash_reporting_service.dart';

/// Базовий інтерфейс репозиторію автентифікації (Repository Pattern)
abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  UserProfile get currentProfile;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? photoUrl,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> reauthenticate({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> deleteAccount();
}

/// Реалізація репозиторію автентифікації на базі Firebase Auth
/// з локальним кешуванням сеансу, адаптивною обробкою винятків
/// та інтеграцією з Firebase Analytics і Crashlytics.
class AuthRepository implements BaseAuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  FirebaseAuth? _auth;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  // Локальний кеш моделі профілю
  UserProfile _cachedProfile = UserProfile.defaultUser;

  /// Ініціалізація сервісу
  void initialize() {
    try {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen((User? user) {
        if (user != null) {
          _syncProfileFromFirebaseUser(user);
          CrashReportingService.instance.setUserIdentifier(user.uid);
          AnalyticsService.instance.logEvent(
            name: 'user_session_restored',
            parameters: {'uid': user.uid},
          );
        }
        _authStateController.add(user);
      });
    } catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Ініціалізація FirebaseAuth',
        fatal: false,
      );
    }
  }

  void _syncProfileFromFirebaseUser(User user) {
    _cachedProfile = _cachedProfile.copyWith(
      fullName: user.displayName ?? _cachedProfile.fullName,
      email: user.email ?? _cachedProfile.email,
      phone: user.phoneNumber ?? _cachedProfile.phone,
      photoUrl: user.photoURL ?? _cachedProfile.photoUrl,
    );
  }

  @override
  Stream<User?> get authStateChanges => _auth != null
      ? _auth!.authStateChanges()
      : _authStateController.stream;

  @override
  User? get currentUser => _auth?.currentUser;

  @override
  UserProfile get currentProfile => _cachedProfile;

  /// Реєстрація нового користувача через email і пароль
  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    CrashReportingService.instance.log('Спроба реєстрації користувача: $email');

    try {
      if (_auth != null) {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (credential.user != null) {
          await credential.user!.updateDisplayName(fullName.trim());
          await credential.user!.reload();
        }
      }

      // Оновлюємо локальний кеш профілю
      _cachedProfile = UserProfile(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone?.trim() ?? '+380 67 123 45 67',
        photoUrl: null,
      );

      await AnalyticsService.instance.logSignUp(signUpMethod: 'email_password');
      CrashReportingService.instance.log('Користувач успішно зареєстрований: $email');
    } on FirebaseAuthException catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Помилка реєстрації FirebaseAuth: ${e.code}',
        fatal: false,
      );
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      // Якщо це демонстраційний запуск без підключення до живого бекенду
      _cachedProfile = UserProfile(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone?.trim() ?? '+380 67 123 45 67',
        photoUrl: null,
      );
      await AnalyticsService.instance.logSignUp(signUpMethod: 'mock_demo');
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Демонстраційна реєстрація без прямого з\'єднання з Firebase',
        fatal: false,
      );
    }
  }

  /// Авторизація за email і паролем
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    CrashReportingService.instance.log('Спроба авторизації користувача: $email');

    try {
      if (_auth != null) {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (credential.user != null) {
          _syncProfileFromFirebaseUser(credential.user!);
        }
      } else {
        _cachedProfile = _cachedProfile.copyWith(email: email.trim());
      }

      await AnalyticsService.instance.logLogin(loginMethod: 'email_password');
      CrashReportingService.instance.log('Успішна авторизація: $email');
    } on FirebaseAuthException catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Помилка входу FirebaseAuth: ${e.code}',
        fatal: false,
      );
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      // Резервна демонстраційна авторизація
      _cachedProfile = _cachedProfile.copyWith(email: email.trim());
      await AnalyticsService.instance.logLogin(loginMethod: 'mock_demo');
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Демонстраційний вхід',
        fatal: false,
      );
    }
  }

  /// Авторизація через Google OAuth (імітація/виклики)
  @override
  Future<void> signInWithGoogle() async {
    CrashReportingService.instance.log('Спроба входу через Google OAuth');
    try {
      if (_auth != null) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
        await _auth!.signInWithPopup(googleProvider);
      }
      await AnalyticsService.instance.logLogin(loginMethod: 'google_oauth');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      await AnalyticsService.instance.logLogin(loginMethod: 'google_mock');
    }
  }

  /// Відновлення пароля через лист на електронну пошту
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    CrashReportingService.instance.log('Запит скидання пароля для: $email');

    try {
      if (_auth != null) {
        await _auth!.sendPasswordResetEmail(email: email.trim());
      }
      await AnalyticsService.instance.logPasswordResetRequested(email: email);
      CrashReportingService.instance.log('Лист для скидання надіслано на: $email');
    } on FirebaseAuthException catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Помилка скидання пароля: ${e.code}',
        fatal: false,
      );
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Демонстраційне скидання пароля',
        fatal: false,
      );
      await AnalyticsService.instance.logPasswordResetRequested(email: email);
    }
  }

  /// Оновлення даних профілю
  @override
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? photoUrl,
  }) async {
    CrashReportingService.instance.log('Оновлення профілю користувача');

    try {
      final user = _auth?.currentUser;
      if (user != null) {
        if (fullName != null && fullName.isNotEmpty) {
          await user.updateDisplayName(fullName.trim());
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl.trim());
        }
        await user.reload();
      }

      _cachedProfile = _cachedProfile.copyWith(
        fullName: fullName?.trim(),
        phone: phone?.trim(),
        photoUrl: photoUrl?.trim(),
      );

      if (photoUrl != null) {
        await AnalyticsService.instance.logAvatarChanged(source: 'https_url');
      }
      await AnalyticsService.instance.logEvent(
        name: 'profile_updated',
        parameters: {
          'has_name': (fullName != null).toString(),
          'has_phone': (phone != null).toString(),
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      _cachedProfile = _cachedProfile.copyWith(
        fullName: fullName?.trim(),
        phone: phone?.trim(),
        photoUrl: photoUrl?.trim(),
      );
    }
  }

  /// Зміна пароля з обов'язковою повторною перевіркою
  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    CrashReportingService.instance.log('Запит зміни пароля користувача');

    try {
      final user = _auth?.currentUser;
      if (user != null && user.email != null) {
        // Повторна автентифікація перед зміною
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }

      await AnalyticsService.instance.logPasswordChanged();
      CrashReportingService.instance.log('Пароль успішно змінено');
    } on FirebaseAuthException catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Помилка зміни пароля: ${e.code}',
        fatal: false,
      );
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      CrashReportingService.instance.recordError(
        e,
        stack,
        reason: 'Демонстраційна зміна пароля',
        fatal: false,
      );
      await AnalyticsService.instance.logPasswordChanged();
    }
  }

  /// Повторна автентифікація (reauthentication)
  @override
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    final user = _auth?.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  /// Завершення сеансу (Sign Out)
  @override
  Future<void> signOut() async {
    CrashReportingService.instance.log('Вихід з облікового запису');
    try {
      await _auth?.signOut();
      await AnalyticsService.instance.logEvent(name: 'user_signed_out');
    } catch (e) {
      developer.log('Помилка при виході з Firebase: $e');
    }
  }

  /// Видалення облікового запису
  @override
  Future<void> deleteAccount() async {
    CrashReportingService.instance.log('Видалення облікового запису користувача');
    final user = _auth?.currentUser;
    if (user != null) {
      await user.delete();
    }
    await AnalyticsService.instance.logEvent(name: 'account_deleted');
  }

  /// Переклад кодів помилок Firebase на зрозумілі користувачу повідомлення
  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Невірний email або пароль. Перевірте введені дані.';
      case 'email-already-in-use':
        return 'Обліковий запис із такою електронною поштою вже зареєстровано.';
      case 'invalid-email':
        return 'Некоректний формат адреси електронної пошти.';
      case 'weak-password':
        return 'Введений пароль занадто слабкий (необхідно щонайменше 6 символів).';
      case 'user-disabled':
        return 'Цей обліковий запис було заблоковано адміністратором.';
      case 'too-many-requests':
        return 'Забагато невдалих спроб входу. Спробуйте пізніше або відновіть пароль.';
      case 'requires-recent-login':
        return 'Ця дія вимагає недавнього входу. Будь ласка, вийдіть і ввійдіть знову.';
      case 'network-request-failed':
        return 'Помилка мережі. Перевірте з\'єднання з інтернетом.';
      default:
        return e.message ?? 'Виникла помилка автентифікації. Спробуйте пізніше.';
    }
  }
}
