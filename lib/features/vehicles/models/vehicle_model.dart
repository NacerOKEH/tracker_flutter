import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String registrationNumber;
  final int year;
  final double currentMileage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.registrationNumber,
    required this.year,
    required this.currentMileage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json, String id) {
    return VehicleModel(
      id: id,
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      registrationNumber: json['registrationNumber'] as String,
      year: json['year'] as int,
      currentMileage: (json['currentMileage'] as num).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'registrationNumber': registrationNumber,
      'year': year,
      'currentMileage': currentMileage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  VehicleModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? registrationNumber,
    int? year,
    double? currentMileage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
