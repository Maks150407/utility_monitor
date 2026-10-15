import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../../models/utility_type.dart';

class UtilitySummaryCard extends StatelessWidget {
  final UtilityType type;
  final String consumptionText;
  final String? costText;
  final String? tariffText;
  final VoidCallback? onTap;

  const UtilitySummaryCard({
    super.key,
    required this.type,
    required this.consumptionText,
    this.costText,
    this.tariffText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.radiusLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.radiusLg,
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: AppStyles.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 32.0,
                color: type.color,
              ),
              const SizedBox(height: 10.0),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                consumptionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (costText != null) ...[
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: type.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    costText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: type.color,
                    ),
                  ),
                ),
              ],
              if (tariffText != null) ...[
                const SizedBox(height: 6.0),
                Text(
                  tariffText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.0,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
