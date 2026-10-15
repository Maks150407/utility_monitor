import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../models/meter_reading.dart';
import '../../models/utility_type.dart';

class AddReadingScreen extends StatefulWidget {
  final MeterReading? readingToEdit;

  const AddReadingScreen({
    super.key,
    this.readingToEdit,
  });

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  late UtilityType _selectedType;
  late final TextEditingController _valueController;
  late final TextEditingController _dateController;
  late final TextEditingController _commentController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final edit = widget.readingToEdit;
    _selectedType = edit?.type ?? UtilityType.water;
    _valueController = TextEditingController(
      text: edit != null ? edit.value.toString() : '257',
    );
    _selectedDate = edit?.date ?? DateTime.now();
    _dateController = TextEditingController(
      text: _formatDate(_selectedDate),
    );
    _commentController = TextEditingController(
      text: edit?.comment ?? 'Напр., заміна лічильника',
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day.$month.$year';
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _save() {
    final val = double.tryParse(_valueController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final reading = MeterReading(
      id: widget.readingToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      value: val,
      date: _selectedDate,
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
    );
    Navigator.of(context).pop(reading);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.readingToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          isEditing ? 'Редагувати показник' : 'Новий показник',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type dropdown
                const Text(
                  'Тип послуги',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.radiusLg,
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: AppStyles.softShadow,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UtilityType>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                      items: UtilityType.values.map((type) {
                        return DropdownMenuItem<UtilityType>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon, color: type.color, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                type.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Meter reading value
                CustomTextField(
                  label: 'Показник лічильника (${_selectedType.unit})',
                  controller: _valueController,
                  prefixIcon: Icons.speed,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),

                // Reading date
                CustomTextField(
                  label: 'Дата показника',
                  controller: _dateController,
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),

                // Comment
                CustomTextField(
                  label: 'Коментар (необов\'язково)',
                  controller: _commentController,
                  maxLines: 2,
                ),
                const SizedBox(height: 36),

                // Action buttons: Cancel and Save
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Скасувати',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Зберегти',
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
