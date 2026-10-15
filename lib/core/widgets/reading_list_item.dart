import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/meter_reading.dart';
import '../../models/utility_type.dart';

class ReadingListItem extends StatelessWidget {
  final MeterReading reading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ReadingListItem({
    super.key,
    required this.reading,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: reading.type.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              reading.type.icon,
              color: reading.type.color,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 16.0),
          // Title and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${reading.type.displayName} — ${reading.formattedValue} ${reading.type.unit}',
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      reading.formattedDate,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: reading.type.backgroundColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '${reading.type.defaultTariff} ₴/${reading.type.unit}',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: reading.type.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons if enabled
          if (showActions) ...[
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20.0,
                color: AppColors.textSecondary,
              ),
              onPressed: onDelete,
              tooltip: 'Видалити',
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 20.0,
                color: AppColors.textSecondary,
              ),
              onPressed: onEdit,
              tooltip: 'Редагувати',
            ),
          ],
        ],
      ),
    );
  }
}
