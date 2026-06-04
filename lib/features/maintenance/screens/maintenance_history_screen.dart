import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/maintenance_model.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceHistoryScreen extends ConsumerWidget {
  final String vehicleId;
  const MaintenanceHistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenancesAsync = ref.watch(maintenancesProvider(vehicleId));
    final filterDate = ref.watch(maintenanceDateFilterProvider(vehicleId));
    final filtered = ref.watch(filteredMaintenancesProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique maintenances'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: filterDate != null ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _pickFilter(context, ref),
          ),
          if (filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => ref
                  .read(maintenanceDateFilterProvider(vehicleId).notifier)
                  .state = null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.go('/vehicles/$vehicleId/maintenance/add'),
        child: const Icon(Icons.add),
      ),
      body: maintenancesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (_) {
          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.build_outlined,
              message: 'Aucune maintenance enregistrée.',
            );
          }

          final totalCost =
              filtered.fold(0.0, (sum, m) => sum + m.cost);

          return Column(
            children: [
              if (filterDate != null)
                Container(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list,
                          size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Text(
                        'Depuis le ${AppDateUtils.formatDate(filterDate)}',
                        style: const TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total maintenance',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32), fontSize: 12)),
                          Text(
                            '${totalCost.toStringAsFixed(2)} MAD',
                            style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _MaintenanceCard(maintenance: filtered[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickFilter(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref
          .read(maintenanceDateFilterProvider(vehicleId).notifier)
          .state = picked;
    }
  }
}

class _MaintenanceCard extends ConsumerWidget {
  final MaintenanceModel maintenance;
  const _MaintenanceCard({required this.maintenance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.build, color: Colors.white, size: 20),
        ),
        title: Text(maintenance.categoryName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(maintenance.date)} · '
          '${maintenance.cost.toStringAsFixed(2)} MAD · '
          '${maintenance.mileage.toStringAsFixed(0)} km'
          '${maintenance.description.isNotEmpty ? "\n${maintenance.description}" : ""}',
        ),
        isThreeLine: maintenance.description.isNotEmpty,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette maintenance ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              final uid = ref.read(currentUidProvider);
              await ref
                  .read(maintenanceServiceProvider)
                  .deleteMaintenance(uid, maintenance.id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
