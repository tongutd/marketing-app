class BreadcrumbItem {
  final String label;
  final String? route;

  BreadcrumbItem(this.label, {this.route});
}

class BreadcrumbResolver {
  static List<BreadcrumbItem> resolve(String? route) {
    if (route == null) return [];

    // Dashboard
    if (route == '/dashboard') {
      return [
        BreadcrumbItem('Dashboard'),
      ];
    }

    // PM Projects
    if (route == '/pm/projects') {
      return [
        BreadcrumbItem('Project Management'),
      ];
    }

    // PM My Tasks
    if (route == '/pm/my-tasks') {
      return [
        BreadcrumbItem('Project Management', route: '/pm/projects'),
        BreadcrumbItem('My Tasks'),
      ];
    }

    // PM Project Detail (List / Kanban)
    if (route.startsWith('/pm/project/')) {
      return [
        BreadcrumbItem(
          'Project Management',
          route: '/pm/projects',
        ),
        BreadcrumbItem('Project'),
      ];
    }

    return [];
  }
}