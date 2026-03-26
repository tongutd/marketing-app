import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectService {
  static final _db = FirebaseFirestore.instance;

  /// 📡 Stream Project List
  static Stream<List<ProjectModel>> streamProjects() {
    return _db
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// ➕ Get Project
  static Future<ProjectModel?> getProject(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  /// ➕ Create Project
  static Future<void> createProject({
    required String name,
    String? description,
  }) async {
    await _db.collection('projects').add({
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    }); 
  }

  static Future<Map<String, String>> getProjectNames(
    Set<String> projectIds,
  ) async {
    if (projectIds.isEmpty) return {};

    final snap = await FirebaseFirestore.instance
        .collection('projects')
        .where(FieldPath.documentId, whereIn: projectIds.toList())
        .get();

    return {
      for (final doc in snap.docs)
        doc.id: (doc.data()['name'] ?? doc.id),
    };
  }

  static Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .update({
      'name': name,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}