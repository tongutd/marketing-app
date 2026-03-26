// ignore: deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/widgets.dart';

class RouteTracker extends NavigatorObserver {
  static const _key = 'last_route';

  @override
  void didPush(Route route, Route? previousRoute) {
    _save(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _save(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _save(Route route) {
    final name = route.settings.name;
    if (name != null && name != '/login' && name != '/') {
      html.window.localStorage[_key] = name;
    }
  }

  static String? get lastRoute =>
      html.window.localStorage[_key];
}