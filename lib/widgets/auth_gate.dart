import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/pages/login/login_page.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../layout/admin_shell.dart';

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ⏳ รอ auth พร้อม
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🚫 ยังไม่ login
    if (!auth.isLoggedIn) {
      return const LoginPage();
    }

    // ✅ login แล้ว → ห่อด้วย AdminShell
    return AdminShell(
      child: child,
    );
  }
}