import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_entry_model.dart';

class FuelHistoryScreen extends ConsumerWidget {
  final String vehicleId;
  const FuelHistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesProvider(vehicleId));
    final filterDate = ref.watch(fuelDateFilterProvider(vehicleId));
    final filteredEntries = ref.watch(filteredFuelEntriesProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des pleins'),
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
                  .read(fuelDateFilterProvider(vehicleId).notifier)
                  .state = null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/vehicles/$vehicleId/fuel/add'),
        child: const Icon(Icons.add),
      ),
      body: entriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (_) {
          if (filterDate != null)
            _showFilterBanner(context, filterDate);
          if (filteredEntries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.local_gas_station_outlined,
              message: 'Aucun plein enregistré.',
            );
          }

          final totalLiters =
              filteredEntries.fold(0.0, (sum, e) => sum + e.liters);
          final totalAmount =
              filteredEntries.fold(0.0, (sum, e) => sum + e.totalAmount);

          return Column(
            children: [
              if (filterDate != null)
                Container(
                  color: AppTheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list,
                          size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Depuis le ${AppDateUtils.formatDate(filterDate)}',
                        style: const TextStyle(color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              // Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total litres',
                        value: '${totalLiters.toStringAsFixed(1)} L',
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total dépensé',
                        value:
                            '${totalAmount.toStringAsFixed(2)} MAD',
                        color: const Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEntries.length,
                  itemBuilder: (ctx, i) =>
                      _FuelEntryCard(entry: filteredEntries[i], ref: ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterBanner(BuildContext ctx, DateTime date) {}

  Future<void> _pickFilter(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(fuelDateFilterProvider(vehicleId).notifier).state = picked;
    }
  }
}

class _FuelEntryCard extends ConsumerWidget {
  final FuelEntryModel entry;
  final WidgetRef ref;
  const _FuelEntryCard({required this.entry, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.local_gas_station, color: Colors.white, size: 20),
        ),
        title: Text(
          DateFormat('dd/MM/yyyy').format(entry.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${entry.liters.toStringAsFixed(1)} L · ${entry.totalAmount.toStringAsFixed(2)} MAD\n'
          '${entry.pricePerLiter.toStringAsFixed(2)} MAD/L · ${entry.mileage.toStringAsFixed(0)} km'
          '${entry.notes.isNotEmpty ? "\n${entry.notes}" : ""}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: () => _confirmDelete(context, r),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce plein ?'),
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
                  .read(fuelServiceProvider)
                  .deleteFuelEntry(uid, entry.id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
