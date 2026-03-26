import 'package:flutter/material.dart';

class QrDashboardPage extends StatefulWidget {
  const QrDashboardPage({super.key});

  @override
  State<QrDashboardPage> createState() => _QrDashboardPageState();
}

class _QrDashboardPageState extends State<QrDashboardPage> {
  String _search = '';
  String _filter = 'All';

  final List<Map<String, dynamic>> _mockQrData = [
    {
      "name": "Huawei Suphanburi",
      "folder": "Huawei",
      "owner": "Admin",
      "createdAt": "12/03/2026",
    },
    {
      "name": "Samsung Rama 2",
      "folder": "Samsung",
      "owner": "Manager",
      "createdAt": "10/03/2026",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _mockQrData.where((qr) {
      final matchesSearch =
          qr['name'].toLowerCase().contains(_search.toLowerCase());

      final matchesFilter =
          _filter == 'All' || qr['folder'] == _filter;

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Row(
              children: [
                const Text(
                  "My QR Codes",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                ElevatedButton.icon(
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text("New Folder"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/qr/create-folder');
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("New QR"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/qr/create');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Search + Filter
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search QR...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() => _search = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filter,
                  items: ['All', 'Huawei', 'Samsung']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => _filter = val ?? 'All');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// QR List
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final qr = filtered[index];

                    return ListTile(
                      title: Text(
                        qr['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                          "Folder: ${qr['folder']} • Owner: ${qr['owner']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// Move Folder
                          IconButton(
                            tooltip: "Move Folder",
                            icon: const Icon(Icons.folder_open),
                            onPressed: () {
                              _showMoveDialog(qr);
                            },
                          ),

                          /// Change Owner
                          IconButton(
                            tooltip: "Change Owner",
                            icon: const Icon(Icons.person),
                            onPressed: () {
                              _showOwnerDialog(qr);
                            },
                          ),

                          /// Settings
                          IconButton(
                            tooltip: "Settings",
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/qr/settings');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDialog(Map<String, dynamic> qr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Move to Folder"),
        content: const Text("Folder selection coming soon..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _showOwnerDialog(Map<String, dynamic> qr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Owner"),
        content: const Text("Owner selection coming soon..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}