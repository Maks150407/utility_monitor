import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';

/// Сервіс для взаємодії з Firebase Analytics.
/// Забезпечує реєстрацію подій життєвого циклу користувача, навігації
/// та бізнес-операцій (додавання показників, зміна профілю).
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  final List<Map<String, dynamic>> _recentEvents = [];
  List<Map<String, dynamic>> get recentEvents => List.unmodifiable(_recentEvents);

  /// Ініціалізація аналітики
  void initialize() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      developer.log('Firebase Analytics успішно ініціалізовано', name: 'AnalyticsService');
    } catch (e, stack) {
      developer.log('Помилка ініціалізації Firebase Analytics: $e', name: 'AnalyticsService', error: e, stackTrace: stack);
    }
  }

  FirebaseAnalyticsObserver? get observer => _observer;

  /// Фіксація довільної події з параметрами
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final eventRecord = {
      'name': name,
      'parameters': parameters ?? {},
      'timestamp': timestamp,
    };
    _recentEvents.insert(0, eventRecord);
    if (_recentEvents.length > 50) {
      _recentEvents.removeLast();
    }

    developer.log('Подія аналітики [$name]: $parameters', name: 'AnalyticsService');

    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      developer.log('Не вдалося надіслати подію до Firebase Analytics: $e', name: 'AnalyticsService');
    }
  }

  /// Фіксація входу користувача
  Future<void> logLogin({String loginMethod = 'email_password'}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': loginMethod},
    );
  }

  /// Фіксація реєстрації користувача
  Future<void> logSignUp({String signUpMethod = 'email_password'}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': signUpMethod},
    );
  }

  /// Фіксація перегляду екрана
  Future<void> logScreenView({required String screenName}) async {
    await logEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
    );
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  /// Фіксація операції додавання показника лічильника
  Future<void> logReadingAdded({
    required String utilityType,
    required double value,
  }) async {
    await logEvent(
      name: 'meter_reading_added',
      parameters: {
        'utility_type': utilityType,
        'reading_value': value,
      },
    );
  }

  /// Фіксація видалення показника
  Future<void> logReadingDeleted({required String id}) async {
    await logEvent(
      name: 'meter_reading_deleted',
      parameters: {'reading_id': id},
    );
  }

  /// Фіксація зміни аватара
  Future<void> logAvatarChanged({required String source}) async {
    await logEvent(
      name: 'avatar_updated',
      parameters: {'source_type': source},
    );
  }

  /// Фіксація зміни пароля
  Future<void> logPasswordChanged() async {
    await logEvent(name: 'password_updated');
  }

  /// Фіксація запиту на відновлення пароля
  Future<void> logPasswordResetRequested({required String email}) async {
    await logEvent(
      name: 'password_reset_requested',
      parameters: {'email_domain': email.split('@').last},
    );
  }
}
