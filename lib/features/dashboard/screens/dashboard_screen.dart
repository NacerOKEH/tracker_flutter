import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_stats_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentOps = ref.watch(recentOperationsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car_outlined),
            onPressed: () => context.go(AppRoutes.vehicles),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.go(AppRoutes.categories),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (v) async {
              if (v == 'logout') {
                await ref.read(authServiceProvider).signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: AppTheme.error, size: 18),
                  SizedBox(width: 8),
                  Text('Se déconnecter',
                      style: TextStyle(color: AppTheme.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (stats) => _DashboardContent(stats: stats, recentOps: recentOps),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  final List<RecentOperation> recentOps;
  const _DashboardContent({required this.stats, required this.recentOps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month summary
          _SectionTitle(
              title: _greetingMonth()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Véhicules',
                  value: stats.vehicleCount.toString(),
                  icon: Icons.directions_car,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Dépenses mois',
                  value: '${stats.monthTotal.toStringAsFixed(0)} MAD',
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Gasoil mois',
                  value: '${stats.monthFuelAmount.toStringAsFixed(0)} MAD',
                  icon: Icons.local_gas_station_outlined,
                  color: const Color(0xFF0277BD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Maintenance mois',
                  value:
                      '${stats.monthMaintenanceCost.toStringAsFixed(0)} MAD',
                  icon: Icons.build_outlined,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'Litres gasoil ce mois',
            value: '${stats.monthFuelLiters.toStringAsFixed(1)} L',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF00838F),
          ),
          const SizedBox(height: 20),

          // Répartition gasoil/maintenance
          if (stats.monthTotal > 0) ...[
            const _SectionTitle(title: 'Répartition des dépenses'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PercentBar(
                      label: 'Gasoil',
                      percent: stats.fuelPercent,
                      color: const Color(0xFF0277BD),
                    ),
                    const SizedBox(height: 8),
                    _PercentBar(
                      label: 'Maintenance',
                      percent: stats.maintenancePercent,
                      color: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Bar chart 6 mois
          const _SectionTitle(title: '6 derniers mois'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 180,
                child: _MonthlyBarChart(months: stats.last6Months),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats par véhicule
          if (stats.vehicleStats.isNotEmpty) ...[
            const _SectionTitle(title: 'Par véhicule'),
            const SizedBox(height: 8),
            ...stats.vehicleStats
                .map((vs) => _VehicleStatCard(stats: vs)),
            const SizedBox(height: 20),
          ],

          // Dernières opérations
          const _SectionTitle(title: 'Dernières opérations'),
          const SizedBox(height: 8),
          if (recentOps.isEmpty)
            const Text('Aucune opération enregistrée.',
                style: TextStyle(color: Colors.grey))
          else
            ...recentOps.map((op) => _RecentOpCard(op: op)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _greetingMonth() {
    final now = DateTime.now();
    final h = now.hour;
    final greeting = h < 12
        ? 'Bonjour'
        : h < 18
            ? 'Bon après-midi'
            : 'Bonsoir';
    final month = AppDateUtils.formatMonth(now);
    return '$greeting — $month';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(value,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _PercentBar(
      {required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${percent.toStringAsFixed(1)}%',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStats> months;
  const _MonthlyBarChart({required this.months});

  @override
  Widget build(BuildContext context) {
    if (months.every((m) => m.totalAmount == 0)) {
      return const Center(
          child: Text('Pas encore de données', style: TextStyle(color: Colors.grey)));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= months.length) return const Text('');
                return Text(
                  AppDateUtils.formatShortMonth(months[i].month),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: months.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: m.fuelAmount,
                color: const Color(0xFF0277BD),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: m.maintenanceCost,
                color: const Color(0xFF2E7D32),
                width: 8,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _VehicleStatCard extends StatelessWidget {
  final VehicleStats stats;
  const _VehicleStatCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(stats.vehicleName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                _Chip(
                    label:
                        '${stats.totalFuelLiters.toStringAsFixed(1)} L',
                    color: const Color(0xFF0277BD)),
                _Chip(
                    label:
                        '${stats.totalFuelAmount.toStringAsFixed(0)} MAD gasoil',
                    color: const Color(0xFF0277BD)),
                _Chip(
                    label:
                        '${stats.totalMaintenanceCost.toStringAsFixed(0)} MAD maint.',
                    color: const Color(0xFF2E7D32)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _RecentOpCard extends StatelessWidget {
  final RecentOperation op;
  const _RecentOpCard({required this.op});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(
          op.isFuel ? Icons.local_gas_station : Icons.build,
          color: op.isFuel ? const Color(0xFF0277BD) : const Color(0xFF2E7D32),
        ),
        title: Text(op.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(op.subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          DateFormat('dd/MM').format(op.date),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ),
    );
  }
}
