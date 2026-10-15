import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class ConsumptionDynamicsCard extends StatelessWidget {
  const ConsumptionDynamicsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ['Бер', 'Кві', 'Тра', 'Чер', 'Лип', 'Сер', 'Вер'];
    final heights = [12.0, 10.0, 14.0, 11.0, 13.0, 12.0, 18.0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusXl,
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Динаміка споживання',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 36.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (index) {
              final isCurrent = index == months.length - 1;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32.0,
                    height: heights[index],
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : const Color(0xFFD6EAE6),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    months[index],
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
