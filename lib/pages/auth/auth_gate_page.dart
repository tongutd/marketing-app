import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';
import '../../navigation/route_tracker.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key}); // ✅ constructor ต้องมี

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginPage();
    }

    // // login แล้ว → redirect ไป dashboard
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pushReplacementNamed(context, '/dashboard');
    // });

    final lastRoute = RouteTracker.lastRoute ?? '/dashboard';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, lastRoute);
    });

    return const Scaffold();
  }
}