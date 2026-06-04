import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/maintenance_category_model.dart';
import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';

final maintenanceServiceProvider =
    Provider<MaintenanceService>((ref) => MaintenanceService());

final categoriesProvider =
    StreamProvider<List<MaintenanceCategoryModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(maintenanceServiceProvider).getCategories(uid);
});

final maintenancesProvider =
    StreamProvider.family<List<MaintenanceModel>, String>((ref, vehicleId) {
  final uid = ref.watch(currentUidProvider);
  return ref
      .watch(maintenanceServiceProvider)
      .getMaintenances(uid, vehicleId);
});

final allMaintenancesProvider =
    StreamProvider<List<MaintenanceModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(maintenanceServiceProvider).getAllMaintenances(uid);
});

// Filtre date par véhicule
final maintenanceDateFilterProvider =
    StateProvider.family<DateTime?, String>((ref, vehicleId) => null);

final filteredMaintenancesProvider =
    Provider.family<List<MaintenanceModel>, String>((ref, vehicleId) {
  final items =
      ref.watch(maintenancesProvider(vehicleId)).valueOrNull ?? [];
  final filter = ref.watch(maintenanceDateFilterProvider(vehicleId));
  if (filter == null) return items;
  return items.where((m) => !m.date.isBefore(filter)).toList();
});
