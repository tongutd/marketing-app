import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/pm/models/project_model.dart';
import 'package:flutter_admin_dashboard/pm/services/project_service.dart';
import 'package:flutter_admin_dashboard/pm/widgets/add_project_dialog.dart';
import 'package:flutter_admin_dashboard/pm/pm_routes.dart';

class PMProjectDashboardPage extends StatelessWidget {
  const PMProjectDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddProjectDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Project list
            Expanded(
              child: StreamBuilder<List<ProjectModel>>(
                stream: ProjectService.streamProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load projects',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    );
                  }

                  final projects = snapshot.data ?? [];

                  if (projects.isEmpty) {
                    return const Center(
                      child: Text('No projects yet'),
                    );
                  }

                  return ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return Card(
                        child: ListTile(
                          title: Text(project.name),
                          subtitle: project.description != null
                              ? Text(project.description!)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PMRoutes.projectDetail(project.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}