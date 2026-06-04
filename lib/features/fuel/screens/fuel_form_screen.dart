import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/fuel_entry_model.dart';
import '../providers/fuel_provider.dart';

class FuelFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const FuelFormScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<FuelFormScreen> createState() => _FuelFormScreenState();
}

class _FuelFormScreenState extends ConsumerState<FuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _litersCtrl.dispose();
    _amountCtrl.dispose();
    _mileageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _computedPricePerLiter {
    final liters = double.tryParse(_litersCtrl.text) ?? 0;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (liters <= 0) return 0;
    return amount / liters;
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
    setState(() => _loading = true);
    final uid = ref.read(currentUidProvider);
    try {
      final entry = FuelEntryModel.create(
        vehicleId: widget.vehicleId,
        date: _selectedDate,
        liters: double.parse(_litersCtrl.text),
        totalAmount: double.parse(_amountCtrl.text),
        mileage: double.parse(_mileageCtrl.text),
        notes: _notesCtrl.text.trim(),
      );
      await ref.read(fuelServiceProvider).addFuelEntry(uid, entry);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un plein')),
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
                  child:
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litersCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Litres',
                  prefixIcon: Icon(Icons.local_gas_station_outlined),
                  suffixText: 'L',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Valeur invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant total',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'MAD',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Prix calculé automatiquement
              if (_computedPricePerLiter > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Prix/litre calculé : ${_computedPricePerLiter.toStringAsFixed(2)} MAD/L',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
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
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (facultatif)',
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
