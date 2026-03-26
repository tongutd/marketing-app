import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  /// 🔥 FIX หลักของ error ทั้งหมด
  factory ProjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt,
    };
  }
}