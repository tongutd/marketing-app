import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/pm_breadcrumb.dart';
import '../../../providers/auth_provider.dart';

class PMMyTaskBoardPage extends StatefulWidget {
  const PMMyTaskBoardPage({super.key});

  @override
  State<PMMyTaskBoardPage> createState() => _PMMyTaskBoardPageState();
}

class _PMMyTaskBoardPageState extends State<PMMyTaskBoardPage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<TaskModel>>(
          stream: TaskService.streamMyTasks(userId: user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Stream error: ${snapshot.error}'),
              );
            }

            final allTasks = snapshot.data ?? [];

            if (allTasks.isEmpty) {
              return const Center(child: Text('No tasks'));
            }

            /// ------------------------------------------------------------
            /// 🔥 SORT: Overdue → Due date → Others
            /// ------------------------------------------------------------
            allTasks.sort((a, b) {
              final aOver = _isOverdue(a);
              final bOver = _isOverdue(b);

              if (aOver && !bOver) return -1;
              if (!aOver && bOver) return 1;

              final ad = a.dueDate;
              final bd = b.dueDate;

              if (ad == null && bd == null) return 0;
              if (ad == null) return 1;
              if (bd == null) return -1;

              return ad.compareTo(bd);
            });

            final overdueCount = allTasks.where(_isOverdue).length;
            final todoCount =
                allTasks.where((t) => t.status == 'todo').length;
            final doingCount =
                allTasks.where((t) => t.status == 'doing').length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🧭 Breadcrumb + Badges
                PMBreadcrumb(
                  items: [
                    PMCrumb(
                      icon: Icons.assignment,
                      label: 'My Tasks',
                      badges: [
                        if (overdueCount > 0)
                          CrumbBadge(
                            count: overdueCount,
                            color: Colors.red,
                          ),
                        if (todoCount > 0)
                          CrumbBadge(
                            count: todoCount,
                            color: Colors.grey,
                          ),
                        if (doingCount > 0)
                          CrumbBadge(
                            count: doingCount,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 📋 TASK LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: allTasks.length,
                    itemBuilder: (context, index) {
                      final task = allTasks[index];
                      final isOverdue = _isOverdue(task);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: isOverdue ? 2 : 1,
                        child: ListTile(
                          key: ValueKey(task.id),

                          /// TITLE
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isOverdue
                                        ? Colors.red.shade700
                                        : null,
                                  ),
                                ),
                              ),
                              if (isOverdue) const _OverdueBadge(),
                            ],
                          ),

                          /// SUBTITLE
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (_descriptionPreview(task) != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _descriptionPreview(task)!,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                              if (task.dueDate != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(task.dueDate!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOverdue
                                              ? Colors.red
                                              : Colors.grey,
                                          fontWeight: isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          trailing: _StatusChip(task.status),

                          /// 👉 Jump to Project Kanban
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(
                              '/pm/project/${task.projectId}/tasks/${task.id}',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  bool _isOverdue(TaskModel task) {
    if (task.dueDate == null) return false;
    if (task.status == 'done') return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  /// 🔥 SAFE description preview
  String? _descriptionPreview(TaskModel task) {
    final text = task.plainDescription;

    if (text.trim().isEmpty) return null;

    return text;
  }
}

/// ------------------------------------------------------------
/// Overdue Badge
/// ------------------------------------------------------------
class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'OVERDUE',
        style: TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Status Chip
/// ------------------------------------------------------------
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'doing':
        color = Colors.orange;
        label = 'Doing';
        break;
      case 'done':
        color = Colors.green;
        label = 'Done';
        break;
      default:
        color = Colors.grey;
        label = 'Todo';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}