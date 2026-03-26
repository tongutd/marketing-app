import 'package:flutter/material.dart';

class PMBreadcrumb extends StatelessWidget {
  final List<PMCrumb> items;

  const PMBreadcrumb({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          InkWell(
            onTap: items[i].onTap,
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Icon(
                  items[i].icon,
                  size: 18,
                  color: i == items.length - 1
                      ? Colors.black
                      : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  items[i].label,
                  style: TextStyle(
                    color: i == items.length - 1
                        ? Colors.black
                        : Colors.blue,
                    fontWeight: i == items.length - 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),

                /// 🔴 Badge (ถ้ามี)
                if (items[i].badges != null)
                  Row(
                    children: items[i].badges!
                        .where((b) => b.count > 0)
                        .map(
                          (b) => _Badge(
                            count: b.count,
                            color: b.color,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          if (i < items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('>'),
            ),
        ],
      ],
    );
  }
}

/// ------------------------------------------------------------
/// Badge widget
/// ------------------------------------------------------------
class _Badge extends StatelessWidget {
  final int count;
  final Color color;

  const _Badge({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
/// ------------------------------------------------------------
/// Crumb model (รองรับ badgeCount หลายอัน)
/// ------------------------------------------------------------
class PMCrumb {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// badge หลายอัน (เช่น todo / doing / overdue)
  final List<CrumbBadge>? badges;

  const PMCrumb({
    required this.label,
    required this.icon,
    this.onTap,
    this.badges,
  });
}

class CrumbBadge {
  final int count;
  final Color color;

  const CrumbBadge({
    required this.count,
    required this.color,
  });
}