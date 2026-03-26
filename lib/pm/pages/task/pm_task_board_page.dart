import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/kanban_column.dart';
import '../../../providers/task_provider.dart';

class PMTaskBoardPage extends StatelessWidget {
  final String projectId;
  final String? focusTaskId; // ✅ เพิ่ม

  const PMTaskBoardPage({
    super.key,
    required this.projectId,
    this.focusTaskId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    /// start listen (ครั้งเดียว)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.startListen(projectId);
    });

    final todo = provider.byStatus('todo');
    final doing = provider.byStatus('doing');
    final done = provider.byStatus('done');

    return Row(
      children: [
        KanbanColumn(
          title: 'Todo',
          status: 'todo',
          projectId: projectId,
          tasks: todo,
          highlightTaskId: focusTaskId, // ✅ ส่งต่อ
          onReorder: (updated) {
            TaskService.reorderTasks(
              projectId: projectId,
              tasks: updated,
            );
          },
          onTapTask: (task) {
            Navigator.of(context).pushReplacementNamed(
              '/pm/project/$projectId/tasks/${task.id}',
            );
          },
        ),

        KanbanColumn(
          title: 'Doing',
          status: 'doing',
          projectId: projectId,
          tasks: doing,
          highlightTaskId: focusTaskId,
          onReorder: (updated) {
            TaskService.reorderTasks(
              projectId: projectId,
              tasks: updated,
            );
          },
          onTapTask: (task) {
            Navigator.of(context).pushReplacementNamed(
              '/pm/project/$projectId/tasks/${task.id}',
            );
          },
        ),

        KanbanColumn(
          title: 'Done',
          status: 'done',
          projectId: projectId,
          tasks: done,
          highlightTaskId: focusTaskId,
          onReorder: (updated) {
            TaskService.reorderTasks(
              projectId: projectId,
              tasks: updated,
            );
          },
          onTapTask: (task) {
            Navigator.of(context).pushReplacementNamed(
              '/pm/project/$projectId/tasks/${task.id}',
            );
          },
        ),
      ],
    );
  }
}