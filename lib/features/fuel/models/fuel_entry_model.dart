import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntryModel {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double totalAmount;
  final double pricePerLiter;
  final double mileage;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelEntryModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.totalAmount,
    required this.pricePerLiter,
    required this.mileage,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // pricePerLiter = totalAmount / liters (calculé automatiquement)
  factory FuelEntryModel.create({
    required String vehicleId,
    required DateTime date,
    required double liters,
    required double totalAmount,
    required double mileage,
    String notes = '',
  }) {
    final now = DateTime.now();
    // Évite division par zéro
    final ppl = (liters > 0) ? totalAmount / liters : 0.0;
    return FuelEntryModel(
      id: '',
      vehicleId: vehicleId,
      date: date,
      liters: liters,
      totalAmount: totalAmount,
      pricePerLiter: ppl,
      mileage: mileage,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory FuelEntryModel.fromJson(Map<String, dynamic> json, String id) {
    return FuelEntryModel(
      id: id,
      vehicleId: json['vehicleId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      liters: (json['liters'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
      mileage: (json['mileage'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'date': Timestamp.fromDate(date),
      'liters': liters,
      'totalAmount': totalAmount,
      'pricePerLiter': pricePerLiter,
      'mileage': mileage,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
