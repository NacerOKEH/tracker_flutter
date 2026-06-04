import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_flutter/features/maintenance/models/maintenance_category_model.dart';
import 'package:tracker_flutter/features/maintenance/models/maintenance_model.dart';
import 'package:tracker_flutter/features/maintenance/services/maintenance_service.dart';
import 'package:tracker_flutter/core/constants/app_constants.dart';

void main() {
  group('MaintenanceService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MaintenanceService service;
    const uid = 'test_uid';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = MaintenanceService(firestore: fakeFirestore);
    });

    test('addCategory ajoute une catégorie', () async {
      final now = DateTime.now();
      await service.addCategory(
        uid,
        MaintenanceCategoryModel(
          id: '',
          name: 'Vidange',
          description: 'Changement huile',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final cats = await service.getCategories(uid).first;
      expect(cats.length, equals(1));
      expect(cats.first.name, equals('Vidange'));
    });

    test('seedDefaultCategories crée les catégories par défaut', () async {
      await service.seedDefaultCategories(uid);
      final cats = await service.getCategories(uid).first;
      expect(cats.length, equals(AppConstants.defaultCategories.length));
    });

    test('seedDefaultCategories ne duplique pas si déjà initialisé', () async {
      await service.seedDefaultCategories(uid);
      await service.seedDefaultCategories(uid);
      final cats = await service.getCategories(uid).first;
      expect(cats.length, equals(AppConstants.defaultCategories.length));
    });

    test('addMaintenance ajoute une maintenance', () async {
      final now = DateTime.now();
      await service.addMaintenance(
        uid,
        MaintenanceModel(
          id: '',
          vehicleId: 'v1',
          categoryId: 'c1',
          categoryName: 'Vidange',
          date: now,
          cost: 250,
          mileage: 50000,
          description: 'Vidange complète',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final list = await service.getMaintenances(uid, 'v1').first;
      expect(list.length, equals(1));
      expect(list.first.categoryName, equals('Vidange'));
      expect(list.first.cost, equals(250));
    });

    test('deleteMaintenance supprime une maintenance', () async {
      final now = DateTime.now();
      await service.addMaintenance(
        uid,
        MaintenanceModel(
          id: '',
          vehicleId: 'v1',
          categoryId: 'c1',
          categoryName: 'Pneus',
          date: now,
          cost: 800,
          mileage: 60000,
          description: '',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final list = await service.getMaintenances(uid, 'v1').first;
      await service.deleteMaintenance(uid, list.first.id);

      final afterDelete = await service.getMaintenances(uid, 'v1').first;
      expect(afterDelete, isEmpty);
    });
  });
}
