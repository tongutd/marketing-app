import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_admin_dashboard/pm/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];

  StreamSubscription? _sub;
  String? _projectId;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> byStatus(String status) =>
      _tasks.where((t) => t.status == status).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  void startListen(String projectId) {
    if (_projectId == projectId) return;

    _projectId = projectId;
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .orderBy('order')
        .snapshots()
        .listen((s) {
      _tasks
        ..clear()
        ..addAll(
          s.docs.map((d) => TaskModel.fromFirestore(d, projectId)),
        );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}