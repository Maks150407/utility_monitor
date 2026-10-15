import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/reading_list_item.dart';
import '../../models/meter_reading.dart';
import '../../models/utility_type.dart';
import 'add_reading_screen.dart';

class ReadingsScreen extends StatefulWidget {
  final List<MeterReading> readings;
  final Function(MeterReading) onAddReading;
  final Function(MeterReading) onEditReading;
  final Function(String) onDeleteReading;

  const ReadingsScreen({
    super.key,
    required this.readings,
    required this.onAddReading,
    required this.onEditReading,
    required this.onDeleteReading,
  });

  @override
  State<ReadingsScreen> createState() => _ReadingsScreenState();
}

class _ReadingsScreenState extends State<ReadingsScreen> {
  String _searchQuery = '';

  void _openAddScreen() async {
    final result = await Navigator.of(context).push<MeterReading>(
      MaterialPageRoute(
        builder: (context) => const AddReadingScreen(),
      ),
    );
    if (result != null) {
      widget.onAddReading(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новий показник успішно додано!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _openEditScreen(MeterReading reading) async {
    final result = await Navigator.of(context).push<MeterReading>(
      MaterialPageRoute(
        builder: (context) => AddReadingScreen(readingToEdit: reading),
      ),
    );
    if (result != null) {
      widget.onEditReading(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Показник успішно оновлено!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _confirmDelete(MeterReading reading) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusXl),
          title: const Text('Видалення показника'),
          content: Text(
            'Ви дійсно бажаєте видалити запис: ${reading.type.displayName} (${reading.formattedValue} ${reading.type.unit}) за ${reading.formattedDate}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteReading(reading.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Запис видалено!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.readings.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.type.displayName.toLowerCase().contains(q) ||
          r.formattedDate.contains(q) ||
          r.formattedValue.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Search Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.radiusLg,
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: AppStyles.softShadow,
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Пошук за послугою (Вода, Світло, Газ) або датою...',
                      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.radiusXl,
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: AppStyles.softShadow,
                  ),
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Center(
                            child: Text(
                              'Показників не знайдено',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: AppColors.divider,
                          ),
                          itemBuilder: (context, index) {
                            final reading = filtered[index];
                            return ReadingListItem(
                              reading: reading,
                              showActions: true,
                              onEdit: () => _openEditScreen(reading),
                              onDelete: () => _confirmDelete(reading),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 80), // spacing for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
