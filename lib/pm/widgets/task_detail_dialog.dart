import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskDetailDialog extends StatefulWidget {
  final TaskModel task;

  const TaskDetailDialog({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _assigneeNameCtrl;
  DateTime? _dueDate;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description ?? '');
    _assigneeNameCtrl = TextEditingController(
          text: widget.task.assigneeId != null
              ? widget.task.assigneeId!
              : 'Unassigned',
        );
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assigneeNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await TaskService.updateTask(
        projectId: widget.task.projectId,
        taskId: widget.task.id,
        data: {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          'dueDate': _dueDate,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Task Detail'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// TITLE
                TextFormField(
                  controller: _titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 12),

                /// DESCRIPTION
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),

                const SizedBox(height: 12),

                /// DUE DATE
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );

                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dueDate == null
                              ? 'No due date'
                              : _dueDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ASSIGNEE (display only for now)
                TextFormField(
                  controller: _assigneeNameCtrl,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Assignee',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}