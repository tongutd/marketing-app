import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pm/models/task_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  bool get isLoggedIn => user != null;
  bool get isLoading => false;

  /// -------------------------
  /// Permission helpers (TEMP: allow all)
  /// -------------------------

  /// 🔓 ตอนนี้ให้ทุกคนลาก task ได้ (พัก assignee logic)
  bool canDragTask(TaskModel task) {
    return true;
  }

  /// 🔓 ตอนนี้ให้ทุกคนแก้ task ได้
  bool canEditTask(TaskModel task) {
    return true;
  }

  /// 🔓 auto assign ยังไม่ใช้
  bool canAutoAssign(TaskModel task) {
    return true;
  }

  /// -------------------------
  /// Login (minimal)
  /// -------------------------
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}