import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';
import '../main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Максим Меленевич');
  final _emailController = TextEditingController(text: 'maks@example.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  final _confirmPasswordController = TextEditingController(text: 'Password123!');
  bool _isLoading = false;
  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'RegisterScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Uri.base.queryParameters['validate'] == 'true') {
        _formKey.currentState?.validate();
      } else if (Uri.base.queryParameters['filled'] == 'true') {
        _nameController.text = 'Максим Меленевич';
        _emailController.text = 'maksym.melenevych@nulp.ua';
        _passwordController.text = 'SecurePass2026!';
        _confirmPasswordController.text = 'SecurePass2026!';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _serverErrorMessage = null);

    // Перевірка валідності всіх полів форми
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthRepository.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Акаунт успішно створено! Вхід виконано.'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (context) => const MainShellScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      setState(() {
        _serverErrorMessage = msg.isNotEmpty && msg != 'Error'
            ? msg
            : 'Помилка реєстрації. Перевірте введені дані.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_serverErrorMessage!),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stylized logo with meter dial
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8EFEA),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.speed,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Створення акаунта',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Заповніть форму, щоб почати',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Банер повідомлення про помилку від сервера
                  if (_serverErrorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.error.withAlpha(120)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _serverErrorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Name field з валідацією
                  CustomTextField(
                    label: 'Ім\'я та прізвище',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),

                  // Email field з валідацією
                  CustomTextField(
                    label: 'Електронна пошта',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // Password field з валідацією
                  CustomTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field з валідацією
                  CustomTextField(
                    label: 'Підтвердження пароля',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => Validators.confirmPassword(
                      val,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Register button
                  PrimaryButton(
                    text: 'Зареєструватися',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),

                  // Back to login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Вже маєте акаунт? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Увійти',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
