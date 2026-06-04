import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore;

  VehicleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.vehiclesCollection);

  Stream<List<VehicleModel>> getVehicles(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => VehicleModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<VehicleModel?> getVehicle(String uid, String vehicleId) async {
    final doc = await _col(uid).doc(vehicleId).get();
    if (!doc.exists) return null;
    return VehicleModel.fromJson(doc.data()!, doc.id);
  }

  Future<void> addVehicle(String uid, VehicleModel vehicle) async {
    await _col(uid).add(vehicle.toJson());
  }

  Future<void> updateVehicle(String uid, VehicleModel vehicle) async {
    final data = vehicle.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col(uid).doc(vehicle.id).update(data);
  }

  Future<void> deleteVehicle(String uid, String vehicleId) async {
    await _col(uid).doc(vehicleId).delete();
  }
}
