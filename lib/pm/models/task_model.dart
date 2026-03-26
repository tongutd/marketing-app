import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TaskModel {
  final String id;
  final String projectId;

  final String title;
  final dynamic description; // String | Quill Delta (Map)

  final String status;
  final int order;

  final String? assigneeId;
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.order,
    this.assigneeId,
    this.dueDate,
  });

  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String projectId,
  ) {
    final data = doc.data() ?? {};

    return TaskModel(
      id: doc.id,
      projectId: projectId,
      title: data['title'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'todo',
      order: (data['order'] ?? 0) as int,
      assigneeId: data['assigneeId'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  // ✅ แปลง Quill Delta → Plain Text แบบปลอดภัย
  String get plainDescription {
    if (description == null) return '';

    try {
      final data = description is String
          ? jsonDecode(description)
          : description;

      if (data is Map && data['ops'] is List) {
        final buffer = StringBuffer();

        for (final op in data['ops']) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }

        return buffer.toString().trim();
      }

      return description.toString();
    } catch (_) {
      return description.toString();
    }
  }
}