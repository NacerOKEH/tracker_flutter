import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceCategoryModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceCategoryModel.fromJson(
      Map<String, dynamic> json, String id) {
    return MaintenanceCategoryModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
