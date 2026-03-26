import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class EditTaskDialog extends StatefulWidget {
  final String projectId;
  final TaskModel task;

  const EditTaskDialog({
    super.key,
    required this.projectId,
    required this.task,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.task.title);

    /// -------------------------------
    /// Description → Quill Delta
    /// -------------------------------
    final desc = widget.task.description;

    Document doc;
    if (desc != null && desc.isNotEmpty) {
      try {
        doc = Document.fromJson(jsonDecode(desc));
      } catch (_) {
        // fallback ถ้าเป็น text ธรรมดา
        doc = Document()..insert(0, '$desc\n');
      }
    } else {
      doc = Document()..insert(0, '\n');
    }

    _quillCtrl = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 700,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= TITLE =================
              TextField(
                controller: _titleCtrl,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Task title',
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 12),

              /// ================= TOOLBAR =================
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _quillCtrl,
                  showBoldButton: true,
                  showItalicButton: true,
                  // showUnderlineButton: true,
                  showStrikeThrough: true,
                  showInlineCode: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showLink: true,
                  showCodeBlock: true,
                ),
              ),

              const SizedBox(height: 8),

              /// ================= EDITOR =================
              Container(
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: _quillCtrl,
                    readOnly: false,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= ACTIONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await TaskService.updateTask(
      projectId: widget.projectId,
      taskId: widget.task.id,
      data: {
        'title': _titleCtrl.text.trim(),
        // ✅ save delta เป็น JSON string
        'description':
            jsonEncode(_quillCtrl.document.toDelta().toJson()),
        'updatedAt': DateTime.now(),
      },
    );

    if (mounted) Navigator.pop(context);
  }
}