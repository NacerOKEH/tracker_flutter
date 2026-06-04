class MonthlyStats {
  final DateTime month;
  final double fuelAmount;
  final double maintenanceCost;
  final double fuelLiters;

  const MonthlyStats({
    required this.month,
    required this.fuelAmount,
    required this.maintenanceCost,
    required this.fuelLiters,
  });

  double get totalAmount => fuelAmount + maintenanceCost;
}

class VehicleStats {
  final String vehicleId;
  final String vehicleName;
  final double totalFuelLiters;
  final double totalFuelAmount;
  final double totalMaintenanceCost;

  const VehicleStats({
    required this.vehicleId,
    required this.vehicleName,
    required this.totalFuelLiters,
    required this.totalFuelAmount,
    required this.totalMaintenanceCost,
  });
}

class DashboardStats {
  final int vehicleCount;
  final double monthFuelAmount;
  final double monthMaintenanceCost;
  final double monthFuelLiters;
  final List<MonthlyStats> last6Months;
  final List<VehicleStats> vehicleStats;

  const DashboardStats({
    required this.vehicleCount,
    required this.monthFuelAmount,
    required this.monthMaintenanceCost,
    required this.monthFuelLiters,
    required this.last6Months,
    required this.vehicleStats,
  });

  double get monthTotal => monthFuelAmount + monthMaintenanceCost;

  // Pourcentages calculés sur les vraies données
  double get fuelPercent =>
      monthTotal == 0 ? 0 : (monthFuelAmount / monthTotal * 100);
  double get maintenancePercent =>
      monthTotal == 0 ? 0 : (monthMaintenanceCost / monthTotal * 100);
}
