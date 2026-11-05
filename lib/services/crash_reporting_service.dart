import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Модель зареєстрованого звіту про збій чи нефатальну помилку
class CrashReport {
  final String id;
  final String message;
  final String? reason;
  final StackTrace? stackTrace;
  final bool isFatal;
  final DateTime timestamp;
  final Map<String, Object> customKeys;

  CrashReport({
    required this.id,
    required this.message,
    this.reason,
    this.stackTrace,
    required this.isFatal,
    required this.timestamp,
    required this.customKeys,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// Сервіс моніторингу стабільності та збирання звітів про помилки.
/// Реалізує архітектуру обробки помилок Firebase Crashlytics / Sentry:
/// - перехоплення FlutterError.onError
/// - перехоплення PlatformDispatcher.instance.onError
/// - реєстрація нефатальних (non-fatal) та фатальних (fatal) помилок
/// - ведення діагностичного логу (breadcrumb logs)
class CrashReportingService {
  CrashReportingService._();
  static final CrashReportingService instance = CrashReportingService._();

  final List<CrashReport> _reports = [];
  final List<String> _breadcrumbs = [];
  final Map<String, Object> _customKeys = {};
  String? _userIdentifier;

  List<CrashReport> get reports => List.unmodifiable(_reports);
  List<String> get breadcrumbs => List.unmodifiable(_breadcrumbs);
  Map<String, Object> get customKeys => Map.unmodifiable(_customKeys);
  String? get userIdentifier => _userIdentifier;

  /// Встановлення ідентифікатора користувача у звітах
  void setUserIdentifier(String identifier) {
    _userIdentifier = identifier;
    log('Встановлено ідентифікатор користувача: $identifier');
  }

  /// Додавання користувацького ключа контексту
  void setCustomKey(String key, Object value) {
    _customKeys[key] = value;
  }

  /// Додавання діагностичного повідомлення в журнал (log)
  void log(String message) {
    final entry = '[${DateTime.now().toIso8601String()}] $message';
    _breadcrumbs.insert(0, entry);
    if (_breadcrumbs.length > 100) {
      _breadcrumbs.removeLast();
    }
    developer.log(message, name: 'CrashReportingService');
  }

  /// Реєстрація помилки фреймворку Flutter
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    await recordError(
      details.exception,
      details.stack,
      reason: details.context?.toString() ?? 'Flutter framework error',
      fatal: fatal,
    );
  }

  /// Реєстрація помилки (аналог FirebaseCrashlytics.instance.recordError)
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    final report = CrashReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: exception.toString(),
      reason: reason?.toString(),
      stackTrace: stack,
      isFatal: fatal,
      timestamp: DateTime.now(),
      customKeys: Map.from(_customKeys),
    );

    _reports.insert(0, report);
    if (_reports.length > 50) {
      _reports.removeLast();
    }

    final severity = fatal ? 'CRITICAL/FATAL' : 'NON-FATAL';
    developer.log(
      '[$severity] Звіт про помилку зафіксовано: ${report.message}',
      name: 'CrashReportingService',
      error: exception,
      stackTrace: stack,
    );
  }

  /// Генерація тестової помилки для перевірки збирання звітів (Вимога завдання 2)
  Future<CrashReport> generateTestError({bool fatal = false}) async {
    log('Користувач ініціював тестову помилку перевірки стабільності');
    try {
      throw StateError(
        fatal
            ? 'Тестова фатальна помилка (Null pointer / Uncaught StateError у модулі комунальних витрат)'
            : 'Тестова нефатальна помилка обробника тарифів (Handled TariffCalculationException)',
      );
    } catch (e, stack) {
      await recordError(
        e,
        stack,
        reason: fatal
            ? 'Фатальний збій рендерингу (імітація)'
            : 'Нефатальна помилка розрахунку вартості за тарифом (імітація)',
        fatal: fatal,
      );
      return _reports.first;
    }
  }

  /// Очищення локального журналу помилок
  void clearReports() {
    _reports.clear();
    _breadcrumbs.clear();
  }
}
