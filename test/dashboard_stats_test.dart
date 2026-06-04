import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/features/dashboard/models/dashboard_stats_model.dart';
import 'package:tracker_flutter/core/utils/date_utils.dart';

void main() {
  group('DashboardStats', () {
    test('fuelPercent calculé sur vraies données', () {
      final stats = DashboardStats(
        vehicleCount: 2,
        monthFuelAmount: 700,
        monthMaintenanceCost: 300,
        monthFuelLiters: 60,
        last6Months: [],
        vehicleStats: [],
      );

      expect(stats.fuelPercent, closeTo(70.0, 0.01));
      expect(stats.maintenancePercent, closeTo(30.0, 0.01));
    });

    test('fuelPercent est 0 si aucune dépense', () {
      final stats = DashboardStats(
        vehicleCount: 0,
        monthFuelAmount: 0,
        monthMaintenanceCost: 0,
        monthFuelLiters: 0,
        last6Months: [],
        vehicleStats: [],
      );

      expect(stats.fuelPercent, equals(0.0));
      expect(stats.maintenancePercent, equals(0.0));
    });

    test('monthTotal = fuel + maintenance', () {
      final stats = DashboardStats(
        vehicleCount: 1,
        monthFuelAmount: 500,
        monthMaintenanceCost: 200,
        monthFuelLiters: 40,
        last6Months: [],
        vehicleStats: [],
      );

      expect(stats.monthTotal, equals(700.0));
    });
  });

  group('AppDateUtils', () {
    test('lastSixMonths retourne 6 éléments', () {
      final months = AppDateUtils.lastSixMonths();
      expect(months.length, equals(6));
    });

    test('isSameMonth détecte correctement', () {
      final a = DateTime(2024, 3, 15);
      final b = DateTime(2024, 3, 1);
      final c = DateTime(2024, 4, 1);

      expect(AppDateUtils.isSameMonth(a, b), isTrue);
      expect(AppDateUtils.isSameMonth(a, c), isFalse);
    });
  });
}
