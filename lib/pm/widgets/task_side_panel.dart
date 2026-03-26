import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskSidePanel extends StatefulWidget {
  final String projectId;
  final TaskModel task;
  final VoidCallback onClose;

  const TaskSidePanel({
    super.key,
    required this.projectId,
    required this.task,
    required this.onClose,
  });

  @override
  State<TaskSidePanel> createState() => _TaskSidePanelState();
}

class _TaskSidePanelState extends State<TaskSidePanel> {
  late final QuillController _descCtrl;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  DateTime? _dueDate;
  String? _assigneeId;

  @override
  void initState() {
    super.initState();

    _descCtrl = QuillController(
      document: _buildDocument(widget.task.description),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _dueDate = widget.task.dueDate;
    _assigneeId = widget.task.assigneeId;
  }

  /// ------------------------------------
  /// Firestore → Quill Document
  /// ------------------------------------
  Document _buildDocument(dynamic description) {
    if (description is Map && description['ops'] is List) {
      try {
        return Document.fromJson(
          List<Map<String, dynamic>>.from(description['ops']),
        );
      } catch (_) {}
    }
    return Document()..insert(0, '');
  }

  /// ------------------------------------
  /// SAVE ALL
  /// ------------------------------------
  Future<void> _saveAll() async {
    await TaskService.updateTask(
      projectId: widget.projectId,
      taskId: widget.task.id,
      data: {
        'description': {
          'ops': _descCtrl.document.toDelta().toJson(),
        },
        'dueDate': _dueDate,
        'assigneeId': _assigneeId,
        'updatedAt': DateTime.now(),
      },
    );
  }

  void _closePanel() async {
    await _saveAll();
    widget.onClose();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;

    return Material(
      elevation: 6,
      color: Colors.white,
      child: Column(
        children: [
          _Header(
            title: widget.task.title,
            onClose: _closePanel,
          ),
          const Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// STATUS
                  _StatusField(
                    projectId: widget.projectId,
                    task: widget.task,
                  ),

                  const SizedBox(height: 12),

                  /// ASSIGNEE (simple version)
                  DropdownButtonFormField<String>(
                    value: _assigneeId,
                    decoration: const InputDecoration(
                      labelText: 'Assignee',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      if (me != null)
                        DropdownMenuItem(
                          value: me.uid,
                          child: Text(me.email ?? me.uid),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _assigneeId = v);
                    },
                  ),

                  const SizedBox(height: 12),

                  /// DUE DATE
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dueDate == null
                                ? 'No due date'
                                : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          QuillSimpleToolbar(
                            configurations:
                                QuillSimpleToolbarConfigurations(
                              controller: _descCtrl,
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: QuillEditor(
                              focusNode: _focusNode,
                              scrollController: _scrollCtrl,
                              configurations:
                                  QuillEditorConfigurations(
                                controller: _descCtrl,
                                readOnly: false,
                                padding:
                                    const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================================================
/// HEADER
/// ===================================================
class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _Header({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

/// ===================================================
/// STATUS FIELD
/// ===================================================
class _StatusField extends StatefulWidget {
  final String projectId;
  final TaskModel task;

  const _StatusField({
    required this.projectId,
    required this.task,
  });

  @override
  State<_StatusField> createState() => _StatusFieldState();
}

class _StatusFieldState extends State<_StatusField> {
  String? _assigneeId;

  @override
  void initState() {
    super.initState();
    _assigneeId = widget.task.assigneeId;
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// STATUS
        DropdownButtonFormField<String>(
          value: widget.task.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'todo', child: Text('Todo')),
            DropdownMenuItem(value: 'doing', child: Text('Doing')),
            DropdownMenuItem(value: 'done', child: Text('Done')),
          ],
          onChanged: (value) async {
            if (value == null || value == widget.task.status) return;

            await TaskService.updateTask(
              projectId: widget.projectId,
              taskId: widget.task.id,
              data: {'status': value},
            );
          },
        ),

        const SizedBox(height: 12),

        /// ASSIGNEE
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: _assigneeId,
            decoration: const InputDecoration(
              labelText: 'Assignee',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(
                  'Unassigned',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (me != null)
                DropdownMenuItem(
                  value: me.uid,
                  child: Text(
                    me.email ?? me.uid,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) async {
              setState(() => _assigneeId = v);

              await TaskService.updateTask(
                projectId: widget.projectId,
                taskId: widget.task.id,
                data: {'assigneeId': v},
              );
            },
          ),
        ),
      ],
    );
  }
}