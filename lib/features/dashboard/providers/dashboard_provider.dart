import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../fuel/providers/fuel_provider.dart';
import '../../maintenance/providers/maintenance_provider.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../vehicles/providers/vehicle_provider.dart';
import '../models/dashboard_stats_model.dart';

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesProvider);
  final fuelAsync = ref.watch(allFuelEntriesProvider);
  final maintenanceAsync = ref.watch(allMaintenancesProvider);

  // Propagate loading/error states
  if (vehiclesAsync.isLoading || fuelAsync.isLoading || maintenanceAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (vehiclesAsync.hasError) return AsyncValue.error(vehiclesAsync.error!, StackTrace.empty);
  if (fuelAsync.hasError) return AsyncValue.error(fuelAsync.error!, StackTrace.empty);
  if (maintenanceAsync.hasError) return AsyncValue.error(maintenanceAsync.error!, StackTrace.empty);

  final vehicles = vehiclesAsync.valueOrNull ?? [];
  final fuelEntries = fuelAsync.valueOrNull ?? [];
  final maintenances = maintenanceAsync.valueOrNull ?? [];

  final now = DateTime.now();
  final startOfMonth = AppDateUtils.startOfMonth(now);
  final endOfMonth = AppDateUtils.endOfMonth(now);

  // Mois courant
  final monthFuel = fuelEntries.where((e) =>
      !e.date.isBefore(startOfMonth) && !e.date.isAfter(endOfMonth));
  final monthMaint = maintenances.where((m) =>
      !m.date.isBefore(startOfMonth) && !m.date.isAfter(endOfMonth));

  final monthFuelAmount =
      monthFuel.fold(0.0, (sum, e) => sum + e.totalAmount);
  final monthFuelLiters =
      monthFuel.fold(0.0, (sum, e) => sum + e.liters);
  final monthMaintenanceCost =
      monthMaint.fold(0.0, (sum, m) => sum + m.cost);

  // 6 derniers mois
  final months = AppDateUtils.lastSixMonths();
  final last6 = months.map((month) {
    final mFuel = fuelEntries.where((e) => AppDateUtils.isSameMonth(e.date, month));
    final mMaint = maintenances.where((m) => AppDateUtils.isSameMonth(m.date, month));
    return MonthlyStats(
      month: month,
      fuelAmount: mFuel.fold(0.0, (s, e) => s + e.totalAmount),
      maintenanceCost: mMaint.fold(0.0, (s, m) => s + m.cost),
      fuelLiters: mFuel.fold(0.0, (s, e) => s + e.liters),
    );
  }).toList();

  // Stats par véhicule
  final vehicleStats = vehicles.map((v) {
    final vFuel = fuelEntries.where((e) => e.vehicleId == v.id);
    final vMaint = maintenances.where((m) => m.vehicleId == v.id);
    return VehicleStats(
      vehicleId: v.id,
      vehicleName: v.name,
      totalFuelLiters: vFuel.fold(0.0, (s, e) => s + e.liters),
      totalFuelAmount: vFuel.fold(0.0, (s, e) => s + e.totalAmount),
      totalMaintenanceCost: vMaint.fold(0.0, (s, m) => s + m.cost),
    );
  }).toList();

  return AsyncValue.data(DashboardStats(
    vehicleCount: vehicles.length,
    monthFuelAmount: monthFuelAmount,
    monthMaintenanceCost: monthMaintenanceCost,
    monthFuelLiters: monthFuelLiters,
    last6Months: last6,
    vehicleStats: vehicleStats,
  ));
});

// 5 dernières opérations (fuel + maintenance mélangées, triées par date)
class RecentOperation {
  final DateTime date;
  final String title;
  final String subtitle;
  final bool isFuel;

  const RecentOperation({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.isFuel,
  });
}

final recentOperationsProvider = Provider<List<RecentOperation>>((ref) {
  final fuelEntries = ref.watch(allFuelEntriesProvider).valueOrNull ?? [];
  final maintenances = ref.watch(allMaintenancesProvider).valueOrNull ?? [];

  final ops = <RecentOperation>[];

  for (final e in fuelEntries) {
    ops.add(RecentOperation(
      date: e.date,
      title: 'Plein carburant',
      subtitle: '${e.liters.toStringAsFixed(1)} L · ${e.totalAmount.toStringAsFixed(2)} MAD',
      isFuel: true,
    ));
  }
  for (final m in maintenances) {
    ops.add(RecentOperation(
      date: m.date,
      title: m.categoryName,
      subtitle: '${m.cost.toStringAsFixed(2)} MAD · ${m.description.isNotEmpty ? m.description : "—"}',
      isFuel: false,
    ));
  }

  ops.sort((a, b) => b.date.compareTo(a.date));
  return ops.take(5).toList();
});
