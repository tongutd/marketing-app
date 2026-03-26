class BreadcrumbItem {
  final String label;
  final String? route;

  BreadcrumbItem(this.label, {this.route});
}

class BreadcrumbResolver {
  static List<BreadcrumbItem> resolve(String route) {
    final segments = Uri.parse(route).pathSegments;

    // Dashboard
    if (route == '/dashboard') {
      return [BreadcrumbItem('Dashboard')];
    }

    // PM Projects
    if (route == '/pm/projects') {
      return [BreadcrumbItem('Project Management')];
    }

    // /pm/project/:id
    if (segments.length == 3 &&
        segments[0] == 'pm' &&
        segments[1] == 'project') {
      return [
        BreadcrumbItem('Project Management',
            route: '/pm/projects'),
        BreadcrumbItem('Project'),
      ];
    }

    // /pm/project/:id/tasks
    if (segments.length == 4 &&
        segments[0] == 'pm' &&
        segments[3] == 'tasks') {
      return [
        BreadcrumbItem('Project Management',
            route: '/pm/projects'),
        BreadcrumbItem('Project',
            route: '/pm/project/${segments[2]}'),
        BreadcrumbItem('Tasks'),
      ];
    }

    // /pm/project/:id/tasks/:taskId
    if (segments.length == 5 &&
        segments[0] == 'pm' &&
        segments[3] == 'tasks') {
      return [
        BreadcrumbItem('Project Management',
            route: '/pm/projects'),
        BreadcrumbItem('Project',
            route: '/pm/project/${segments[2]}'),
        BreadcrumbItem('Tasks',
            route:
                '/pm/project/${segments[2]}/tasks'),
        BreadcrumbItem('Task'),
      ];
    }

    return [];
  }
}