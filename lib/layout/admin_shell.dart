import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/pm/utils/breadcrumb_resolver.dart';

import '../widgets/sidebar.dart';
import '../pm/widgets/add_task_dialog.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final routeName =
        ModalRoute.of(context)?.settings.name ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: _JiraBreadcrumb(routeName: routeName),
      ),
      
      body: Row(
        children: [
          SizedBox(
            child: Sidebar(),
          ),

          /// ✅ FIX ที่ถูกต้อง
          Expanded(
            child: child,
          ),
        ],
      ),

      floatingActionButton: _buildFab(context, routeName),
    );
  }

  Widget? _buildFab(BuildContext context, String routeName) {
    if (routeName.startsWith('/pm/project/')) {
      return FloatingActionButton.extended(
        heroTag: 'pm_add_task_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
        backgroundColor: const Color(0xFF0052CC),
        onPressed: () {
          showAddTaskDialog(context);
        },
      );
    }
    return null;
  }
}

/// ============================================================
/// Jira-style Breadcrumb
/// ============================================================
class _JiraBreadcrumb extends StatelessWidget {
  final String routeName;

  const _JiraBreadcrumb({
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final items = BreadcrumbResolver.resolve(routeName);

    return Row(
      children: items.map((item) {
        final isLast = item == items.last;

        return Row(
          children: [
            if (item.route != null && !isLast)
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(item.route!);
                },
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF0052CC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('/'),
              ),
          ],
        );
      }).toList(),
    );
  }
}