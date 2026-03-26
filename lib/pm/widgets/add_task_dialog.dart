import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showAddTaskDialog(BuildContext context) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String status = 'todo';
  String priority = 'medium';
  String? assignedTo = FirebaseAuth.instance.currentUser?.uid;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Add Task'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'todo', child: Text('TODO')),
                    DropdownMenuItem(value: 'doing', child: Text('DOING')),
                    DropdownMenuItem(value: 'done', child: Text('DONE')),
                  ],
                  onChanged: (v) => status = v ?? 'todo',
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) => priority = v ?? 'medium',
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => assignedTo = v.trim().isEmpty ? null : v.trim(),
                  decoration: InputDecoration(
                    labelText: 'AssignedTo (UID) (optional)',
                    hintText: assignedTo ?? 'leave empty',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              titleCtrl.dispose();
              descCtrl.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();

              if (title.isEmpty) return;

              final now = DateTime.now();

              // สร้าง order เป็นท้ายคอลัมน์แบบง่าย: ใช้เวลาหรือ 0 ก่อน
              // ถ้าคุณมีระบบ order จริงค่อยปรับทีหลัง
              await FirebaseFirestore.instance.collection('tasks').add({
                'title': title,
                'description': desc,
                'status': status,
                'priority': priority,
                'assignedTo': assignedTo,
                'order': 0,
                'createdAt': Timestamp.fromDate(now),
                'updatedAt': Timestamp.fromDate(now),
              });

              titleCtrl.dispose();
              descCtrl.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}