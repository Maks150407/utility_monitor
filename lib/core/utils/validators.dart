/// Утиліти валідації полів форм відповідно до вимог лабораторної роботи №4
class Validators {
  Validators._();

  /// Валідація обов'язкового поля
  static String? required(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName є обов\'язковим для заповнення';
    }
    return null;
  }

  /// Валідація імені користувача (мінімум 2 символи, літери)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть ім\'я та прізвище';
    }
    if (value.trim().length < 2) {
      return 'Ім\'я повинно містити щонайменше 2 символи';
    }
    return null;
  }

  /// Валідація адреси електронної пошти (RFC 5322 regex)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть адресу електронної пошти';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Введіть коректний email (наприклад: name@domain.com)';
    }
    return null;
  }

  /// Валідація пароля (мінімум 6 символів)
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < minLength) {
      return 'Пароль має містити не менше $minLength символів';
    }
    return null;
  }

  /// Валідація підтвердження пароля
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Підтвердіть пароль';
    }
    if (value != originalPassword) {
      return 'Паролі не співпадають';
    }
    return null;
  }

  /// Валідація номера телефону
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Необов'язкове поле
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{10,18}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Введіть коректний номер телефону (наприклад: +380 67 123 45 67)';
    }
    return null;
  }

  /// Валідація числового показника лічильника
  static String? meterReading(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть показник лічильника';
    }
    final normalized = value.trim().replaceAll(',', '.');
    final number = double.tryParse(normalized);
    if (number == null) {
      return 'Введіть коректне числове значення';
    }
    if (number < 0) {
      return 'Показник лічильника не може бути від\'ємним';
    }
    return null;
  }

  /// Валідація HTTPS URL-посилання (для фото профілю)
  static String? httpsUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть посилання на зображення';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.scheme != 'https') {
      return 'Посилання повинно починатися з https://';
    }
    return null;
  }
}
