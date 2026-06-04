import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/maintenance_category_model.dart';
import '../providers/maintenance_provider.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories de maintenance')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmptyStateWidget(
                  icon: Icons.category_outlined,
                  message: 'Aucune catégorie.\nAjoutez-en une ou initialisez les catégories par défaut.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Initialiser catégories par défaut'),
                  onPressed: () async {
                    final uid = ref.read(currentUidProvider);
                    await ref
                        .read(maintenanceServiceProvider)
                        .seedDefaultCategories(uid);
                  },
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (ctx, i) =>
                _CategoryCard(category: categories[i]),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration:
                  const InputDecoration(labelText: 'Description (facultatif)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final uid = ref.read(currentUidProvider);
              final now = DateTime.now();
              await ref.read(maintenanceServiceProvider).addCategory(
                    uid,
                    MaintenanceCategoryModel(
                      id: '',
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final MaintenanceCategoryModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.build_outlined, color: Colors.white, size: 20),
        ),
        title: Text(category.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: category.description.isNotEmpty
            ? Text(category.description)
            : null,
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
        title: const Text('Supprimer la catégorie ?'),
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
                  .deleteCategory(uid, category.id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
