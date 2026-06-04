import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/fuel_entry_model.dart';
import '../services/fuel_service.dart';

final fuelServiceProvider = Provider<FuelService>((ref) => FuelService());

// Entrées par véhicule
final fuelEntriesProvider =
    StreamProvider.family<List<FuelEntryModel>, String>((ref, vehicleId) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(fuelServiceProvider).getFuelEntries(uid, vehicleId);
});

// Toutes les entrées (pour dashboard)
final allFuelEntriesProvider = StreamProvider<List<FuelEntryModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(fuelServiceProvider).getAllFuelEntries(uid);
});

// Filtre par date (date de début choisie par l'utilisateur)
final fuelDateFilterProvider =
    StateProvider.family<DateTime?, String>((ref, vehicleId) => null);

final filteredFuelEntriesProvider =
    Provider.family<List<FuelEntryModel>, String>((ref, vehicleId) {
  final entries = ref.watch(fuelEntriesProvider(vehicleId)).valueOrNull ?? [];
  final filterDate = ref.watch(fuelDateFilterProvider(vehicleId));
  if (filterDate == null) return entries;
  return entries.where((e) => !e.date.isBefore(filterDate)).toList();
});
