import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../models/fuel_entry_model.dart';

class FuelService {
  final FirebaseFirestore _firestore;

  FuelService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.fuelEntriesCollection);

  Stream<List<FuelEntryModel>> getFuelEntries(String uid, String vehicleId) {
    return _col(uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FuelEntryModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<FuelEntryModel>> getAllFuelEntries(String uid) {
    return _col(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FuelEntryModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addFuelEntry(String uid, FuelEntryModel entry) async {
    await _col(uid).add(entry.toJson());
  }

  Future<void> deleteFuelEntry(String uid, String entryId) async {
    await _col(uid).doc(entryId).delete();
  }
}
