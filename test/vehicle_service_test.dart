import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/features/vehicles/models/vehicle_model.dart';
import 'package:tracker_flutter/features/vehicles/services/vehicle_service.dart';

void main() {
  group('VehicleService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late VehicleService service;
    const uid = 'test_uid';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = VehicleService(firestore: fakeFirestore);
    });

    VehicleModel _sampleVehicle() {
      final now = DateTime.now();
      return VehicleModel(
        id: '',
        name: 'Ma Voiture',
        brand: 'Dacia',
        model: 'Logan',
        registrationNumber: '12345-A-1',
        year: 2020,
        currentMileage: 50000,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('addVehicle ajoute un véhicule', () async {
      await service.addVehicle(uid, _sampleVehicle());

      final list = await service.getVehicles(uid).first;
      expect(list.length, equals(1));
      expect(list.first.name, equals('Ma Voiture'));
    });

    test('deleteVehicle supprime le véhicule', () async {
      await service.addVehicle(uid, _sampleVehicle());
      final list = await service.getVehicles(uid).first;
      final vehicleId = list.first.id;

      await service.deleteVehicle(uid, vehicleId);

      final afterDelete = await service.getVehicles(uid).first;
      expect(afterDelete, isEmpty);
    });

    test('updateVehicle modifie le véhicule', () async {
      await service.addVehicle(uid, _sampleVehicle());
      final list = await service.getVehicles(uid).first;
      final vehicle = list.first;

      final updated = vehicle.copyWith(name: 'Nouveau Nom', currentMileage: 60000);
      await service.updateVehicle(uid, updated);

      final result = await service.getVehicle(uid, vehicle.id);
      expect(result!.name, equals('Nouveau Nom'));
      expect(result.currentMileage, equals(60000));
    });

    test('isolation uid: un uid ne voit pas les données d\'un autre', () async {
      await service.addVehicle(uid, _sampleVehicle());
      await service.addVehicle('autre_uid', _sampleVehicle());

      final myVehicles = await service.getVehicles(uid).first;
      final otherVehicles = await service.getVehicles('autre_uid').first;

      expect(myVehicles.length, equals(1));
      expect(otherVehicles.length, equals(1));
      expect(myVehicles.first.id, isNot(equals(otherVehicles.first.id)));
    });

    test('getVehicles retourne liste vide si aucun véhicule', () async {
      final list = await service.getVehicles(uid).first;
      expect(list, isEmpty);
    });
  });
}
