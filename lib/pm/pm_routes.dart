/// PM Lite – Route Definitions
/// ใช้ร่วมกับ Named Routes ใน MaterialApp
///
/// Phase 1
/// - /pm/projects      → Project Dashboard
/// - /pm/my-work       → My Work (Personal Tasks)
/// - /pm/reports       → Reports (Admin)
///
/// Phase 2 (เตรียมไว้)
/// - /pm/project/:id
/// - /pm/project/:id/tasks
/// - /pm/project/:id/settings

class PMRoutes {
  PMRoutes._(); // 🔒 ป้องกันการ new class

  /// Project Dashboard
  static const String projects = '/pm/projects';

  // My Tasks
  static const myTasks = '/pm/my-tasks';

  /// My Work (Personal Tasks)
  static const String myWork = '/pm/my-work';

  /// Reports (Admin only)
  static const String reports = '/pm/reports';

  

  // ------------------------------------------------------------
  // Helpers (Optional – ใช้ตอน onGenerateRoute)
  // ------------------------------------------------------------

  /// /pm/project/{projectId}
  static String projectDetail(String projectId) =>
      '/pm/project/$projectId';

  static String projectSettings(String projectId) =>
      '/pm/project/$projectId/settings';

  static String projectTasks(String projectId, {String? taskId}) {
    if (taskId != null) {
      return '/pm/project/$projectId/tasks?task=$taskId';
    }
    return '/pm/project/$projectId/tasks';
  }
      
}