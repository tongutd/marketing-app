import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../widgets/task_side_panel.dart';
import '../../../providers/task_provider.dart';
import '../task/pm_task_board_page.dart';

class PMProjectDetailPage extends StatelessWidget {
  final String projectId;
  final String? focusTaskId;

  const PMProjectDetailPage({
    super.key,
    required this.projectId,
    this.focusTaskId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider()..startListen(projectId),
      child: _Body(
        projectId: projectId,
        focusTaskId: focusTaskId,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String projectId;
  final String? focusTaskId;

  const _Body({
    required this.projectId,
    this.focusTaskId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    /// ---------------------------------------------
    /// 🔑 URL → Selected task (Jira-style)
    /// ---------------------------------------------
    TaskModel? selectedTask;

    if (focusTaskId != null) {
      try {
        selectedTask =
            provider.tasks.firstWhere((t) => t.id == focusTaskId);
      } catch (_) {
        selectedTask = null;
      }
    }

    /// ---------------------------------------------
    /// ❌ Close panel = revert URL
    /// ---------------------------------------------
    void closePanel() {
      Navigator.of(context).pushReplacementNamed(
        '/pm/project/$projectId',
      );
    }

    return Row(
      children: [
        /// 🧱 Kanban board (always alive)
        Expanded(
          child: PMTaskBoardPage(
            projectId: projectId,
            focusTaskId: focusTaskId,
          ),
        ),

        /// 👉 Task side panel (Jira-style)
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: selectedTask == null ? 0 : 420,
          child: selectedTask == null
              ? const SizedBox.shrink()
              : TaskSidePanel(
                  projectId: projectId,
                  task: selectedTask!,
                  onClose: closePanel,
                ),
        ),
      ],
    );
  }
}