import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

final vehicleServiceProvider =
    Provider<VehicleService>((ref) => VehicleService());

final vehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(vehicleServiceProvider).getVehicles(uid);
});

final vehicleByIdProvider =
    FutureProvider.family<VehicleModel?, String>((ref, vehicleId) async {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(vehicleServiceProvider).getVehicle(uid, vehicleId);
});
