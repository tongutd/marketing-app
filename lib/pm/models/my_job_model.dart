import 'package:cloud_firestore/cloud_firestore.dart';

class MyJobModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final DateTime workDate;
  final String mainUrl;
  final List<String> relatedLinks;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MyJobModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.workDate,
    required this.mainUrl,
    required this.relatedLinks,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MyJobModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return MyJobModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      workDate: (data['workDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mainUrl: data['mainUrl'] ?? '',
      relatedLinks: List<String>.from(data['relatedLinks'] ?? []),
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'description': description,
      'workDate': workDate,
      'mainUrl': mainUrl,
      'relatedLinks': relatedLinks,
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MyJobModel copyWith({
    String? uid,   // ⭐ เพิ่มบรรทัดนี้
    String? title,
    String? description,
    DateTime? workDate,
    String? mainUrl,
    List<String>? relatedLinks,
    bool? completed,
  }) {
    return MyJobModel(
      id: id,
      uid: uid ?? this.uid,   
      title: title ?? this.title,
      description: description ?? this.description,
      workDate: workDate ?? this.workDate,
      mainUrl: mainUrl ?? this.mainUrl,
      relatedLinks: relatedLinks ?? this.relatedLinks,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}