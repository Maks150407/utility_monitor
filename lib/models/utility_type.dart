import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum UtilityType {
  water,
  electricity,
  gas,
}

extension UtilityTypeExtension on UtilityType {
  String get displayName {
    switch (this) {
      case UtilityType.water:
        return 'Вода';
      case UtilityType.electricity:
        return 'Світло';
      case UtilityType.gas:
        return 'Газ';
    }
  }

  String get unit {
    switch (this) {
      case UtilityType.water:
        return 'м³';
      case UtilityType.electricity:
        return 'кВт·год';
      case UtilityType.gas:
        return 'м³';
    }
  }

  IconData get icon {
    switch (this) {
      case UtilityType.water:
        return Icons.water_drop;
      case UtilityType.electricity:
        return Icons.bolt;
      case UtilityType.gas:
        return Icons.local_fire_department;
    }
  }

  Color get color {
    switch (this) {
      case UtilityType.water:
        return AppColors.water;
      case UtilityType.electricity:
        return AppColors.electricity;
      case UtilityType.gas:
        return AppColors.gas;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case UtilityType.water:
        return AppColors.waterBg;
      case UtilityType.electricity:
        return AppColors.electricityBg;
      case UtilityType.gas:
        return AppColors.gasBg;
    }
  }

  double get defaultTariff {
    switch (this) {
      case UtilityType.water:
        return 30.38; // ₴/м³
      case UtilityType.electricity:
        return 4.32; // ₴/кВт·год
      case UtilityType.gas:
        return 7.96; // ₴/м³
    }
  }
}
