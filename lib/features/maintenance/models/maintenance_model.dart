import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel {
  final String id;
  final String vehicleId;
  final String categoryId;
  final String categoryName; // dénormalisé pour affichage
  final DateTime date;
  final double cost;
  final double mileage;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceModel({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.cost,
    required this.mileage,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json, String id) {
    return MaintenanceModel(
      id: id,
      vehicleId: json['vehicleId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      date: (json['date'] as Timestamp).toDate(),
      cost: (json['cost'] as num).toDouble(),
      mileage: (json['mileage'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'date': Timestamp.fromDate(date),
      'cost': cost,
      'mileage': mileage,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
