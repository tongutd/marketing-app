import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'pages/login/login_page.dart';
import 'layout/admin_shell.dart';
import 'pages/dashboard/dashboard_page.dart';

import 'pm/pm_on_generate_route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      ),

      // ✅ ใช้แค่นี้พอ
      onGenerateRoute: (settings) {
        debugPrint('🧭 ROUTE -> ${settings.name}');
        return pmOnGenerateRoute(settings);
      },

      initialRoute: '/dashboard',
    );
  }
}

/// ============================================================
/// Root Auth Router (สำคัญมาก)
// ============================================================
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {

        // Loading
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not login
        if (!auth.isLoggedIn) {
          return const LoginPage();
        }

        // ✅ Logged in → redirect ไป dashboard route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        });

        return const SizedBox();
      },
    );
  }
}