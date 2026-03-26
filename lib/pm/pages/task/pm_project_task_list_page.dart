import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/edit_task_dialog.dart';

class PMProjectTaskListPage extends StatelessWidget {
  final String projectId;

  const PMProjectTaskListPage({
    super.key,
    required this.projectId, String? focusTaskId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: TaskService.streamTasks(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Task load error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks in this project',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final task = tasks[index];
            final dueInfo = _DueInfo.fromTask(task);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => EditTaskDialog(
                    projectId: projectId,
                    task: task,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: dueInfo.borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// STATUS STRIP
                    Container(
                      width: 6,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _statusColor(task.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// MAIN INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              /// Assignee
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.assigneeId != null ? 'Assigned' : 'Unassigned',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: task.assigneeId == null
                                      ? Colors.grey
                                      : Colors.grey.shade800,
                                ),
                              ),

                              const SizedBox(width: 16),

                              /// Due date
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: dueInfo.textColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dueInfo.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dueInfo.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// STATUS CHIP
                    _StatusChip(task.status),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ===========================================================
/// STATUS CHIP
/// ===========================================================
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// ===========================================================
/// DUE DATE LOGIC
/// ===========================================================
class _DueInfo {
  final String label;
  final Color textColor;
  final Color borderColor;

  _DueInfo({
    required this.label,
    required this.textColor,
    required this.borderColor,
  });

  factory _DueInfo.fromTask(TaskModel task) {
    if (task.dueDate == null) {
      return _DueInfo(
        label: 'No due date',
        textColor: Colors.grey,
        borderColor: Colors.grey.shade300,
      );
    }

    final now = DateTime.now();
    final due = task.dueDate!;
    final diff = due.difference(now).inDays;

    if (diff < 0 && task.status != 'done') {
      return _DueInfo(
        label: 'Overdue (${diff.abs()}d)',
        textColor: Colors.red,
        borderColor: Colors.red,
      );
    }

    if (diff <= 3) {
      return _DueInfo(
        label: 'Due in $diff d',
        textColor: Colors.orange,
        borderColor: Colors.orange,
      );
    }

    return _DueInfo(
      label: 'Due ${due.day}/${due.month}/${due.year}',
      textColor: Colors.grey.shade700,
      borderColor: Colors.grey.shade300,
    );
  }
}

/// ===========================================================
/// HELPERS
/// ===========================================================
Color _statusColor(String status) {
  switch (status) {
    case 'doing':
      return Colors.orange;
    case 'done':
      return Colors.green;
    default:
      return Colors.grey;
  }
}