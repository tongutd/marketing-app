import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

typedef ReorderCallback = void Function(List<TaskModel> updated);
typedef TaskCallback = void Function(TaskModel task);

class KanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final String projectId;
  final List<TaskModel> tasks;
  final String? highlightTaskId;

  final ReorderCallback onReorder;
  final TaskCallback onTapTask;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.projectId,
    required this.tasks,
    this.highlightTaskId,
    required this.onReorder,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Expanded(
      child: DragTarget<TaskModel>(
        onWillAccept: (task) {
          if (task == null) return false;
          if (task.status == status) return false;
          return _isAdmin() || task.assigneeId == uid;
        },
        onAccept: (task) async {
          await TaskService.moveTaskToStatus(
            projectId: projectId,
            taskId: task.id,
            status: status,
          );
        },
        builder: (_, __, ___) => _buildColumn(context),
      ),
    );
  }

  Widget _buildColumn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Header(title: title, count: tasks.length),
          const SizedBox(height: 12),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final updated = [...tasks];
                final item = updated.removeAt(oldIndex);
                updated.insert(newIndex, item);
                onReorder(updated);
              },
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Container(
                  key: ValueKey(task.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => onTapTask(task),
                    child: _TaskCard(
                      task: task,
                      highlight: task.id == highlightTaskId,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isAdmin() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return email.endsWith('@admin');
  }
}

/// =======================================================
/// COLUMN HEADER (🔥 ที่หายไป)
// =======================================================
class _Header extends StatelessWidget {
  final String title;
  final int count;

  const _Header({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 10,
          backgroundColor: Colors.grey.shade400,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// =======================================================
/// TASK CARD
/// =======================================================
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool highlight;

  const _TaskCard({
    required this.task,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? const Color(0xFF36B37E)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      child: Text(
        task.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}