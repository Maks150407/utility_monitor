import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/crash_reporting_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late UserProfile _user;
  bool _isSaving = false;

  // Набір готових HTTPS-аватарів відповідно до вимоги завдання 4
  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=250&q=80',
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'ProfileScreen');
    _user = AuthRepository.instance.currentProfile;
    _nameController = TextEditingController(text: _user.fullName);
    _phoneController = TextEditingController(text: _user.phone);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialog = Uri.base.queryParameters['dialog'];
      if (dialog == 'avatar') {
        _showAvatarPickerDialog();
      } else if (dialog == 'password') {
        _showChangePasswordDialog();
      } else if (dialog == 'crashlytics') {
        _handleTestCrashlytics();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await AuthRepository.instance.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _user = AuthRepository.instance.currentProfile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Профіль успішно оновлено!'),
            ],
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка оновлення профілю: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Діалог вибору аватара (готові HTTPS-посилання або власне посилання з прев'ю)
  void _showAvatarPickerDialog() {
    String? selectedUrl = _user.photoUrl;
    final customUrlController = TextEditingController(text: _user.photoUrl ?? '');
    final avatarFormKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusXl),
              title: const Row(
                children: [
                  Icon(Icons.photo_library, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Вибір фото профілю', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  child: Form(
                    key: avatarFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Оберіть готовий аватар із колекції:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _presetAvatars.map((url) {
                            final isSelected = selectedUrl == url;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedUrl = url;
                                  customUrlController.text = url;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    width: 3.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'Або введіть власне HTTPS-посилання:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: customUrlController,
                          decoration: InputDecoration(
                            hintText: 'https://example.com/avatar.jpg',
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                            prefixIcon: const Icon(Icons.link, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: Validators.httpsUrl,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedUrl = val.trim();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (selectedUrl != null && selectedUrl!.startsWith('https://')) ...[
                          Center(
                            child: Column(
                              children: [
                                const Text('Попередній перегляд:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFFD8EFEA),
                                  backgroundImage: NetworkImage(selectedUrl!),
                                  onBackgroundImageError: (_, __) {},
                                  child: null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Скасувати', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (customUrlController.text.trim().isNotEmpty && !avatarFormKey.currentState!.validate()) {
                      return;
                    }
                    final finalUrl = selectedUrl?.trim();
                    if (finalUrl != null && finalUrl.isNotEmpty) {
                      await AuthRepository.instance.updateProfile(photoUrl: finalUrl);
                      setState(() {
                        _user = AuthRepository.instance.currentProfile;
                      });
                    }
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Зберегти аватар'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Діалог зміни пароля з Form-валідацією
  void _showChangePasswordDialog() {
    final passwordFormKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isChanging = false;
    String? dialogError;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusXl),
              title: const Text(
                'Зміна пароля',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Form(
                    key: passwordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dialogError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              dialogError!,
                              style: const TextStyle(fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ],
                        CustomTextField(
                          label: 'Поточний пароль',
                          controller: currentPasswordController,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (val) => Validators.required(val, fieldName: 'Поточний пароль'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Новий пароль',
                          controller: newPasswordController,
                          prefixIcon: Icons.lock_reset,
                          isPassword: true,
                          validator: (val) {
                            final baseCheck = Validators.password(val);
                            if (baseCheck != null) return baseCheck;
                            if (val == currentPasswordController.text) {
                              return 'Новий пароль повинен відрізнятися від старого';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Підтвердження нового пароля',
                          controller: confirmPasswordController,
                          prefixIcon: Icons.lock_reset,
                          isPassword: true,
                          validator: (val) => Validators.confirmPassword(
                            val,
                            newPasswordController.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              actions: [
                TextButton(
                  onPressed: isChanging ? null : () => Navigator.of(context).pop(),
                  child: const Text('Скасувати', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
                  ),
                  onPressed: isChanging
                      ? null
                      : () async {
                          if (!passwordFormKey.currentState!.validate()) {
                            return;
                          }
                          setDialogState(() {
                            isChanging = true;
                            dialogError = null;
                          });

                          try {
                            await AuthRepository.instance.updatePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Пароль успішно змінено!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isChanging = false;
                              dialogError = e.toString().replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  child: isChanging
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Зберегти пароль'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Генерація тестової помилки для Crashlytics (Вимога завдання 2)
  Future<void> _handleTestCrashlytics() async {
    final report = await CrashReportingService.instance.generateTestError(fatal: false);

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bug_report, color: AppColors.error, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Firebase Crashlytics / Error Reporter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Тестовий звіт про нефатальну помилку сформовано та надіслано до служби моніторингу стабільності:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Звіт ID: ${report.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Причина: ${report.reason}', style: const TextStyle(fontSize: 12, color: AppColors.error)),
                    const SizedBox(height: 4),
                    Text('Час фіксації: ${report.formattedTime}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Класифікація: ${report.isFatal ? "Фатальна (Fatal)" : "Нефатальна (Non-fatal)"}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Зрозуміло'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusXl),
          title: const Text('Вихід з акаунта'),
          content: const Text('Ви дійсно бажаєте вийти зі свого облікового запису?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await AuthRepository.instance.signOut();
                if (!mounted) return;
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('Вийти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _user.photoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with camera action button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD8EFEA),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(
                                photoUrl,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.person, color: AppColors.primary, size: 52),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.person, color: AppColors.primary, size: 52),
                              ),
                      ),
                    ),
                    InkWell(
                      onTap: _showAvatarPickerDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full name and email
                Text(
                  _user.fullName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Form fields з валідацією
                CustomTextField(
                  label: 'Ім\'я та прізвище',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Телефон',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 24),

                // Save button
                PrimaryButton(
                  text: 'Зберегти зміни',
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 36),

                // Security & Diagnostics section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Безпека та діагностика',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Змінити пароль',
                        icon: Icons.key_outlined,
                        onPressed: _showChangePasswordDialog,
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Тест Crashlytics (Генерація помилки)',
                        borderColor: AppColors.electricity,
                        textColor: AppColors.electricity,
                        icon: Icons.bug_report_outlined,
                        onPressed: _handleTestCrashlytics,
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Вийти з акаунта',
                        borderColor: AppColors.error,
                        textColor: AppColors.error,
                        icon: Icons.logout,
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
