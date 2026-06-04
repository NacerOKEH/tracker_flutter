import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class VehicleFormScreen extends ConsumerStatefulWidget {
  final String? vehicleId;
  const VehicleFormScreen({super.key, this.vehicleId});

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _registrationCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  bool get isEditing => widget.vehicleId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _registrationCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  void _prefill(VehicleModel v) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = v.name;
    _brandCtrl.text = v.brand;
    _modelCtrl.text = v.model;
    _registrationCtrl.text = v.registrationNumber;
    _yearCtrl.text = v.year.toString();
    _mileageCtrl.text = v.currentMileage.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = ref.read(currentUidProvider);
    final now = DateTime.now();
    try {
      if (isEditing) {
        final existing = await ref
            .read(vehicleServiceProvider)
            .getVehicle(uid, widget.vehicleId!);
        final updated = existing!.copyWith(
          name: _nameCtrl.text.trim(),
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          registrationNumber: _registrationCtrl.text.trim(),
          year: int.parse(_yearCtrl.text),
          currentMileage: double.parse(_mileageCtrl.text),
          updatedAt: now,
        );
        await ref.read(vehicleServiceProvider).updateVehicle(uid, updated);
      } else {
        final vehicle = VehicleModel(
          id: '',
          name: _nameCtrl.text.trim(),
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          registrationNumber: _registrationCtrl.text.trim(),
          year: int.parse(_yearCtrl.text),
          currentMileage: double.parse(_mileageCtrl.text),
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(vehicleServiceProvider).addVehicle(uid, vehicle);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final vehicleAsync =
          ref.watch(vehicleByIdProvider(widget.vehicleId!));
      return vehicleAsync.when(
        loading: () => const Scaffold(body: LoadingWidget()),
        error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
        data: (vehicle) {
          if (vehicle != null) _prefill(vehicle);
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le véhicule' : 'Nouveau véhicule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameCtrl, 'Nom du véhicule', Icons.label_outline,
                  required: true),
              const SizedBox(height: 16),
              _field(_brandCtrl, 'Marque', Icons.business_outlined,
                  required: true),
              const SizedBox(height: 16),
              _field(_modelCtrl, 'Modèle', Icons.directions_car_outlined,
                  required: true),
              const SizedBox(height: 16),
              _field(_registrationCtrl, 'Immatriculation',
                  Icons.confirmation_number_outlined,
                  required: true),
              const SizedBox(height: 16),
              _field(_yearCtrl, 'Année', Icons.calendar_today_outlined,
                  required: true,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1900 || n > 2100) {
                      return 'Année invalide';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _field(_mileageCtrl, 'Kilométrage actuel (km)',
                  Icons.speed_outlined,
                  required: true,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (double.tryParse(v ?? '') == null) {
                      return 'Kilométrage invalide';
                    }
                    return null;
                  }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator ??
          (v) => (required && (v == null || v.isEmpty))
              ? '$label requis'
              : null,
    );
  }
}
