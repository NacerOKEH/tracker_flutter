import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../models/maintenance_category_model.dart';
import '../models/maintenance_model.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore;

  MaintenanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _catCol(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.maintenanceCategoriesCollection);

  CollectionReference<Map<String, dynamic>> _mainCol(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.maintenancesCollection);

  // --- Categories ---

  Stream<List<MaintenanceCategoryModel>> getCategories(String uid) {
    return _catCol(uid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                MaintenanceCategoryModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCategory(
      String uid, MaintenanceCategoryModel category) async {
    await _catCol(uid).add(category.toJson());
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _catCol(uid).doc(categoryId).delete();
  }

  // Crée les catégories par défaut si la liste est vide
  Future<void> seedDefaultCategories(String uid) async {
    final existing = await _catCol(uid).limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final now = DateTime.now();
    final batch = _firestore.batch();
    for (final name in AppConstants.defaultCategories) {
      final ref = _catCol(uid).doc();
      batch.set(ref, MaintenanceCategoryModel(
        id: '',
        name: name,
        description: '',
        createdAt: now,
        updatedAt: now,
      ).toJson());
    }
    await batch.commit();
  }

  // --- Maintenances ---

  Stream<List<MaintenanceModel>> getMaintenances(
      String uid, String vehicleId) {
    return _mainCol(uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MaintenanceModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MaintenanceModel>> getAllMaintenances(String uid) {
    return _mainCol(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MaintenanceModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMaintenance(String uid, MaintenanceModel maintenance) async {
    await _mainCol(uid).add(maintenance.toJson());
  }

  Future<void> deleteMaintenance(String uid, String maintenanceId) async {
    await _mainCol(uid).doc(maintenanceId).delete();
  }
}
