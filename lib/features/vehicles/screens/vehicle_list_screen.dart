import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';
import '../../auth/providers/auth_provider.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes véhicules'),
        leading: IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.vehicleAdd),
        child: const Icon(Icons.add),
      ),
      body: vehiclesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.directions_car_outlined,
              message: 'Aucun véhicule.\nAjoutez votre premier véhicule !',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, i) =>
                _VehicleCard(vehicle: vehicles[i]),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final VehicleModel vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            vehicle.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(vehicle.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${vehicle.brand} ${vehicle.model} · ${vehicle.year}\n'
          'Immat: ${vehicle.registrationNumber} · '
          '${vehicle.currentMileage.toStringAsFixed(0)} km',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenu(context, ref, value),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer',
                    style: TextStyle(color: AppTheme.error))),
          ],
        ),
        onTap: () => context.go('/vehicles/${vehicle.id}'),
      ),
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String value) {
    if (value == 'edit') {
      context.go('/vehicles/edit/${vehicle.id}');
    } else if (value == 'delete') {
      _confirmDelete(context, ref);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le véhicule'),
        content: Text('Voulez-vous vraiment supprimer "${vehicle.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              final uid = ref.read(currentUidProvider);
              await ref
                  .read(vehicleServiceProvider)
                  .deleteVehicle(uid, vehicle.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Véhicule supprimé')),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
