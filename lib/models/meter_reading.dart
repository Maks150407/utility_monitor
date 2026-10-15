import 'utility_type.dart';

class MeterReading {
  final String id;
  final UtilityType type;
  final double value;
  final DateTime date;
  final String? comment;

  const MeterReading({
    required this.id,
    required this.type,
    required this.value,
    required this.date,
    this.comment,
  });

  String get formattedValue {
    if (value == value.roundToDouble()) {
      // Format with spaces for thousands like 5 410
      final intVal = value.toInt();
      final str = intVal.toString();
      if (str.length > 3) {
        return '${str.substring(0, str.length - 3)} ${str.substring(str.length - 3)}';
      }
      return str;
    }
    return value.toStringAsFixed(1);
  }

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  static List<MeterReading> getInitialMockData() {
    return [
      MeterReading(
        id: '1',
        type: UtilityType.water,
        value: 245,
        date: DateTime(2026, 9, 18),
      ),
      MeterReading(
        id: '2',
        type: UtilityType.electricity,
        value: 5410,
        date: DateTime(2026, 9, 15),
      ),
      MeterReading(
        id: '3',
        type: UtilityType.gas,
        value: 812,
        date: DateTime(2026, 9, 10),
      ),
      MeterReading(
        id: '4',
        type: UtilityType.water,
        value: 238,
        date: DateTime(2026, 8, 18),
      ),
      MeterReading(
        id: '5',
        type: UtilityType.electricity,
        value: 5210,
        date: DateTime(2026, 8, 15),
      ),
      MeterReading(
        id: '6',
        type: UtilityType.gas,
        value: 780,
        date: DateTime(2026, 8, 10),
      ),
      MeterReading(
        id: '7',
        type: UtilityType.water,
        value: 308,
        date: DateTime(2026, 8, 11),
      ),
      MeterReading(
        id: '8',
        type: UtilityType.electricity,
        value: 3210,
        date: DateTime(2026, 8, 13),
      ),
      MeterReading(
        id: '9',
        type: UtilityType.gas,
        value: 640,
        date: DateTime(2026, 8, 12),
      ),
      MeterReading(
        id: '10',
        type: UtilityType.water,
        value: 310,
        date: DateTime(2026, 8, 14),
      ),
    ];
  }
}
