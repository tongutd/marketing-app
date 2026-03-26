import 'package:flutter/material.dart';

class AdminMenu {
  final String key;
  final String label;
  final String route;
  final IconData icon;

  /// ⭐ สิทธิ์ที่เข้าได้
  final List<String> roles;

  /// ⭐ เมนูย่อย
  final List<AdminMenu> children;

  const AdminMenu({
    required this.key,
    required this.label,
    required this.route,
    required this.icon,
    this.roles = const ['admin'],
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
}

final List<AdminMenu> adminMenus = [
  AdminMenu(
    key: 'dashboard',
    label: 'Dashboard',
    route: '/dashboard',
    icon: Icons.dashboard,
    roles: ['admin', 'manager'],
  ),

  AdminMenu(
    key: 'pm_projects',
    label: 'Projects',
    route: '/pm/projects',
    icon: Icons.view_kanban,
    roles: ['admin', 'manager', 'staff'],
  ),

  AdminMenu(
    key: 'my_tasks',
    label: 'My Tasks',
    route: '/pm/my-tasks',
    icon: Icons.checklist,
    roles: ['admin', 'manager', 'staff'],
  ),

  AdminMenu(
    key: 'my_job',
    label: 'My Job',
    route: '/pm/my-job',
    icon: Icons.work_outline,
    roles: ['admin', 'manager', 'staff'],
  ),

  /// 🔥 NEW: My QR Codes (Parent Menu)
  AdminMenu(
    key: 'my_qr',
    label: 'My QR Codes',
    route: '/qr',
    icon: Icons.qr_code,
    roles: ['admin', 'manager', 'staff'],
    children: [
      AdminMenu(
        key: 'qr_create',
        label: 'Create New QR',
        route: '/qr/create',
        icon: Icons.add_circle_outline,
        roles: ['admin', 'manager', 'staff'],
      ),
      AdminMenu(
        key: 'qr_create_folder',
        label: 'Create New Folder',
        route: '/qr/create-folder',
        icon: Icons.create_new_folder,
        roles: ['admin', 'manager', 'staff'],
      ),
      AdminMenu(
        key: 'qr_settings',
        label: 'Settings',
        route: '/qr/settings',
        icon: Icons.settings,
        roles: ['admin'],
      ),
    ],
  ),

  AdminMenu(
    key: 'stores',
    label: 'Stores',
    route: '/store',
    icon: Icons.store,
    roles: ['admin', 'manager', 'staff'],
  ),
];