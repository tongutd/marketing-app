import 'package:flutter/material.dart';
import '../navigation/breadcrumbs.dart';

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final items = BreadcrumbResolver.resolve(route);

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            GestureDetector(
              onTap: items[i].route == null
                  ? null
                  : () {
                      Navigator.pushReplacementNamed(
                        context,
                        items[i].route!,
                      );
                    },
              child: Text(
                items[i].label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: items[i].route != null
                      ? Colors.blue
                      : Colors.black87,
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('›'),
              ),
          ],
        ],
      ),
    );
  }
}