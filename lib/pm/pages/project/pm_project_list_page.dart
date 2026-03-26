import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PMProjectListPage extends StatelessWidget {
  const PMProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -------------------------
          /// Header
          /// -------------------------
          const Text(
            'Projects',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// -------------------------
          /// Project list
          /// -------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style:
                          const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No projects found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final projectId = doc.id;
                    final data = doc.data();

                    final name =
                        data['name'] ?? 'Untitled Project';
                    final description =
                        data['description'] ?? '';

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(12),
                      onTap: () {
                        // 👉 เข้า Kanban ของ project นี้
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(
                          '/pm/project/$projectId',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 8,
                              offset:
                                  const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(
                                        0xFF36B37E)
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color:
                                    Color(0xFF36B37E),
                              ),
                            ),
                            const SizedBox(width: 16),

                            /// Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                  if (description
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      description,
                                      style:
                                          TextStyle(
                                        fontSize: 13,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}