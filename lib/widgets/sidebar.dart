import 'package:flutter/material.dart';
import '../menu/menu_registry.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final visibleItems =
        _buildVisibleMenuItems(currentRoute);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _collapsed ? 72 : 240,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          /// Collapse Button
          SizedBox(
            height: 56,
            child: Align(
              alignment: _collapsed
                  ? Alignment.center
                  : Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _collapsed
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  color: Colors.grey.shade700,
                ),
                onPressed: () {
                  setState(() {
                    _collapsed = !_collapsed;
                  });
                },
              ),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 8),
              itemCount: visibleItems.length,
              itemBuilder: (_, index) {
                final item = visibleItems[index];
                return _menuRow(
                  label: item.label,
                  icon: item.icon,
                  active: item.active,
                  indent: item.indent,
                  trailing: item.trailing,
                  onTap: item.onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Route-driven expansion (No state bug)
  // ------------------------------------------------------------

  List<_SidebarItem> _buildVisibleMenuItems(
      String? currentRoute) {
    final List<_SidebarItem> items = [];

    for (final menu in adminMenus) {
      final isActive = currentRoute != null &&
          (currentRoute == menu.route ||
              currentRoute
                  .startsWith('${menu.route}/'));

      final hasActiveChild = menu.children.any(
        (child) =>
            currentRoute != null &&
            currentRoute
                .startsWith(child.route),
      );

      final expanded =
          !_collapsed &&
              (isActive || hasActiveChild);

      // Parent
      items.add(
        _SidebarItem(
          label: menu.label,
          icon: menu.icon,
          active: isActive || hasActiveChild,
          indent: 16,
          trailing: menu.hasChildren && !_collapsed
              ? AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration:
                      const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    size: 16,
                  ),
                )
              : null,
          onTap: () {
            if (_collapsed) return;

            Navigator.of(context,
                    rootNavigator: true)
                .pushReplacementNamed(
                    menu.route);
          },
        ),
      );

      // Children
      if (menu.hasChildren && expanded) {
        for (final child in menu.children) {
          final childActive =
              currentRoute != null &&
                  currentRoute
                      .startsWith(child.route);

          items.add(
            _SidebarItem(
              label: child.label,
              icon: child.icon,
              active: childActive,
              indent: 32,
              onTap: () {
                Navigator.of(context,
                        rootNavigator: true)
                    .pushReplacementNamed(
                        child.route);
              },
            ),
          );
        }
      }
    }

    return items;
  }

  // ------------------------------------------------------------
  // Row
  // ------------------------------------------------------------

  Widget _menuRow({
    required String label,
    required IconData icon,
    required bool active,
    required double indent,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    const activeColor = Color(0xFF36B37E);

    if (_collapsed) {
      return InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Tooltip(
              message: label,
              child: Icon(
                icon,
                size: 20,
                color: active
                    ? activeColor
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding:
            EdgeInsets.symmetric(horizontal: indent),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active
                  ? activeColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: active
                      ? activeColor
                      : Colors.grey.shade800,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;
  final bool active;
  final double indent;
  final VoidCallback? onTap;
  final Widget? trailing;

  _SidebarItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.indent,
    this.onTap,
    this.trailing,
  });
}