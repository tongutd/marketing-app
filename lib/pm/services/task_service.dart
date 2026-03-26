import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  /// ===============================
  /// Kanban (per project)
  /// ===============================
  static Stream<List<TaskModel>> streamTasks(String projectId) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .orderBy('order')
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => TaskModel.fromFirestore(d, projectId))
              .toList(),
        );
  }

  /// ===============================
  /// My Tasks (cross projects)
  /// ===============================
  static Stream<List<TaskModel>> streamMyTasks({
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collectionGroup('tasks')
        .where('assigneeId', isEqualTo: userId)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) {
            final projectId = doc.reference.parent.parent!.id;
            return TaskModel.fromFirestore(doc, projectId);
          }).toList(),
        );
  }

  /// ===============================
  /// Update task fields
  /// ===============================
  static Future<void> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> data,
  }) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  /// ===============================
  /// Reorder
  /// ===============================
  static Future<void> reorderTasks({
    required String projectId,
    required List<TaskModel> tasks,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var i = 0; i < tasks.length; i++) {
      batch.update(
        FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .doc(tasks[i].id),
        {'order': i},
      );
    }

    await batch.commit();
  }

  /// ===============================
  /// Move status
  /// ===============================
  static Future<void> moveTaskToStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'status': status});
  }
    // ==========================================================
  // ✅ ADD THIS METHOD (สำหรับ Task Side Panel)
  // ==========================================================
  static Stream<TaskModel> streamTask({
    required String projectId,
    required String taskId,
  }) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .snapshots()
        .map(
          (doc) => TaskModel.fromFirestore(doc, projectId),
        );
  }
}