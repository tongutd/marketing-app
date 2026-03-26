import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/pages/dashboard/dashboard_page.dart';
import 'package:flutter_admin_dashboard/pm/pages/my_job/my_job_page.dart';

import 'package:flutter_admin_dashboard/pm/pages/project/pm_project_detail_page.dart';
import 'package:flutter_admin_dashboard/qr/pages/qr_dashboard_page.dart';
import 'package:flutter_admin_dashboard/store/pages/store_list_page.dart';
import 'package:flutter_admin_dashboard/widgets/auth_gate.dart';

import 'pages/task/pm_my_task_board_page.dart';
import 'pages/project/pm_project_list_page.dart';

Route<dynamic> pmOnGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? '/dashboard';
  final uri = Uri.parse(name);

  return MaterialPageRoute(
    settings: settings,
    builder: (_) => AuthGate(
      child: _resolvePage(uri),
    ),
  );
}

Widget _resolvePage(Uri uri) {
  /// Dashboard
  if (uri.path == '/dashboard') {
    return const DashboardPage();
  }

  /// Store list
  if (uri.path == '/store') {
    return const StoreListPage();
  }

  /// My Tasks
  if (uri.path == '/pm/my-tasks') {
    return const PMMyTaskBoardPage();
  }

  /// Project list
  if (uri.path == '/pm/projects') {
    return const PMProjectListPage();
  }

  /// /pm/project/:projectId
  if (uri.pathSegments.length == 3 &&
      uri.pathSegments[0] == 'pm' &&
      uri.pathSegments[1] == 'project') {
    return PMProjectDetailPage(
      projectId: uri.pathSegments[2],
    );
  }

  /// /pm/project/:projectId/tasks
  if (uri.pathSegments.length == 4 &&
      uri.pathSegments[0] == 'pm' &&
      uri.pathSegments[1] == 'project' &&
      uri.pathSegments[3] == 'tasks') {
    return PMProjectDetailPage(
      projectId: uri.pathSegments[2],
    );
  }

  /// ⭐ /pm/project/:projectId/tasks/:taskId
  if (uri.pathSegments.length == 5 &&
      uri.pathSegments[0] == 'pm' &&
      uri.pathSegments[1] == 'project' &&
      uri.pathSegments[3] == 'tasks') {
    return PMProjectDetailPage(
      projectId: uri.pathSegments[2],
      focusTaskId: uri.pathSegments[4],
    );
  }


  if (uri.path == '/qr') {
    return const QrDashboardPage();
  }

  // if (uri.path == '/qr/create') {
  //   return const QrCreatePage();
  // }

  // if (uri.path == '/qr/create-folder') {
  //   return const QrCreateFolderPage();
  // }

  // if (uri.path == '/qr/settings') {
  //   return const QrSettingsPage();
  // }

  /// /pm/my-job
  if (uri.path == '/pm/my-job') {
    return const MyJobPage();
  }

  debugPrint('⚠️ Unknown route: ${uri.path}');
  return const DashboardPage();
}