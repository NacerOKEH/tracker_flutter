import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/maintenance_model.dart';
import '../providers/maintenance_provider.dart';

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const MaintenanceFormScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState
    extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _loading = false;

  @override
  void dispose() {
    _costCtrl.dispose();
    _mileageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }
    setState(() => _loading = true);
    final uid = ref.read(currentUidProvider);
    final now = DateTime.now();
    try {
      final maintenance = MaintenanceModel(
        id: '',
        vehicleId: widget.vehicleId,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        date: _selectedDate,
        cost: double.parse(_costCtrl.text),
        mileage: double.parse(_mileageCtrl.text),
        description: _descCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await ref
          .read(maintenanceServiceProvider)
          .addMaintenance(uid, maintenance);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une maintenance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              // Catégorie
              categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur catégories: $e'),
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final cat =
                        categories.firstWhere((c) => c.id == val);
                    setState(() {
                      _selectedCategoryId = val;
                      _selectedCategoryName = cat.name;
                    });
                  },
                  validator: (v) =>
                      v == null ? 'Catégorie requise' : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Coût',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'MAD',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Coût invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kilométrage',
                  prefixIcon: Icon(Icons.speed_outlined),
                  suffixText: 'km',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Kilométrage invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
