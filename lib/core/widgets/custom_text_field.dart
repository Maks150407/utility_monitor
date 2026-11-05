import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Стилізоване текстове поле з підтримкою Form-валідації,
/// динамічного приховування пароля, іконок та підсвічування помилок.
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
    this.autovalidateMode,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller?.text ?? '',
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> fieldState) {
        final bool hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppStyles.radiusLg,
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.border,
                  width: hasError ? 1.5 : 1.2,
                ),
                boxShadow: AppStyles.softShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: hasError ? AppColors.error : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          size: 20.0,
                          color: hasError ? AppColors.error : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12.0),
                      ],
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          obscureText: widget.isPassword ? _obscureText : false,
                          keyboardType: widget.keyboardType,
                          readOnly: widget.readOnly,
                          onTap: widget.onTap,
                          maxLines: widget.isPassword ? 1 : widget.maxLines,
                          onChanged: (value) {
                            fieldState.didChange(value);
                            widget.onChanged?.call(value);
                          },
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                            hintText: widget.hintText,
                            hintStyle: const TextStyle(
                              fontSize: 15.0,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                      if (widget.isPassword)
                        IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20.0,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      else if (widget.suffixIcon != null)
                        widget.suffixIcon!,
                    ],
                  ),
                ],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 14.0,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        fieldState.errorText ?? '',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
