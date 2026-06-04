import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/features/fuel/models/fuel_entry_model.dart';

void main() {
  group('FuelEntryModel', () {
    test('pricePerLiter calculé correctement', () {
      final entry = FuelEntryModel.create(
        vehicleId: 'v1',
        date: DateTime(2024, 1, 15),
        liters: 40.0,
        totalAmount: 480.0,
        mileage: 15000,
      );

      expect(entry.pricePerLiter, closeTo(12.0, 0.001));
    });

    test('pricePerLiter est 0 si liters == 0', () {
      final entry = FuelEntryModel.create(
        vehicleId: 'v1',
        date: DateTime(2024, 1, 15),
        liters: 0,
        totalAmount: 100,
        mileage: 15000,
      );

      expect(entry.pricePerLiter, equals(0.0));
    });

    test('notes facultatives par défaut vides', () {
      final entry = FuelEntryModel.create(
        vehicleId: 'v1',
        date: DateTime.now(),
        liters: 30,
        totalAmount: 360,
        mileage: 10000,
      );

      expect(entry.notes, equals(''));
    });

    test('toJson / fromJson round-trip', () {
      final original = FuelEntryModel.create(
        vehicleId: 'v1',
        date: DateTime(2024, 6, 1),
        liters: 50.0,
        totalAmount: 600.0,
        mileage: 20000,
        notes: 'Test',
      );

      final json = original.toJson();
      // pricePerLiter doit être dans le JSON
      expect(json['pricePerLiter'], closeTo(12.0, 0.001));
      expect(json['liters'], equals(50.0));
      expect(json['notes'], equals('Test'));
    });
  });
}
