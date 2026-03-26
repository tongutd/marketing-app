import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/store/services/store_export_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../models/store_model.dart';
import '../providers/store_provider.dart';
import '../settings/bu_settings.dart';
import 'package:excel/excel.dart';

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  String _keyword = '';
  String _buFilter = 'ALL';

  int _rowsPerPage = 20;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    /// ================= FILTER =================
    final filtered = provider.stores.where((s) {
      final matchKeyword = _keyword.isEmpty ||
          s.name.toLowerCase().contains(_keyword.toLowerCase()) ||
          s.storeId.toLowerCase().contains(_keyword.toLowerCase());

      final matchBu =
          _buFilter == 'ALL' || s.bu.toLowerCase() == _buFilter.toLowerCase();

      return matchKeyword && matchBu;
    }).toList()

      // ✅ DEFAULT SORT BY STORE ID
      ..sort((a, b) {
        final aId = int.tryParse(a.storeId);
        final bId = int.tryParse(b.storeId);

        // ถ้าเป็นตัวเลข ให้เรียงแบบตัวเลข
        if (aId != null && bId != null) {
          return aId.compareTo(bId);
        }

        // ถ้าไม่ใช่ตัวเลข ให้เรียงแบบ string
        return a.storeId.compareTo(b.storeId);
      });

    /// ================= PAGINATION =================
    final totalPages =
        filtered.isEmpty ? 1 : (filtered.length / _rowsPerPage).ceil();

    if (_currentPage >= totalPages) {
      _currentPage = 0;
    }

    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage > filtered.length)
        ? filtered.length
        : start + _rowsPerPage;

    final pageData =
        filtered.isEmpty ? <StoreModel>[] : filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            /// ================= TABLE CARD =================
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    /// TABLE
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(   // ✅ มี return
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columnSpacing: 40,
                                    columns: const [
                                      DataColumn(label: Text('Store ID')),
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('BU')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('URL')),
                                      DataColumn(label: Text('Action')), 
                                    ],
                                    rows: pageData.map((s) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(s.storeId)),
                                          DataCell(
                                            InkWell(
                                              onTap: () =>
                                                  _showEditDialog(context, s),
                                              child: Text(
                                                s.name,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(s.bu)),
                                          DataCell(
                                            Switch(
                                              value: s.status == 'active',
                                              onChanged: (v) {
                                                context
                                                    .read<StoreProvider>()
                                                    .toggleStatus(s, v);
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.open_in_new),
                                              onPressed: () {
                                                if (s.registerUrl.isNotEmpty) {
                                                  launchUrl(
                                                      Uri.parse(s.registerUrl));
                                                }
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _confirmDelete(context, s),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// ================= PAGINATION =================
                    _buildPagination(totalPages),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Store List',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const Spacer(),

        ElevatedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        const SizedBox(width: 12),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _importExcel,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Excel'),
            ),
            const SizedBox(width: 8),

            TextButton.icon(
              onPressed: _downloadSampleFile,
              icon: const Icon(Icons.download_for_offline, size: 18),
              label: const Text('Sample'),
            ),
          ],
        ),
        const SizedBox(width: 12),

        OutlinedButton.icon(
          onPressed: _showExportDialog,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
        const SizedBox(width: 20),

        DropdownButton<String>(
          value: _buFilter,
          items: BuSettings.buList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _buFilter = v;
                _currentPage = 0;
              });
            }
          },
        ),
        const SizedBox(width: 16),

        SizedBox(
          width: 240,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              setState(() {
                _keyword = v;
                _currentPage = 0;
              });
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PAGINATION
  // =========================================================

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page ${_currentPage + 1} of $totalPages'),

          Row(
            children: [
              DropdownButton<int>(
                value: _rowsPerPage,
                items: const [
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                  DropdownMenuItem(value: 100, child: Text('100')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _rowsPerPage = v;
                      _currentPage = 0;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADD / EDIT / IMPORT / EXPORT (เหมือนของคุณ)
  // =========================================================

  Future<void> _showAddDialog() async {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final buCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Store'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Store ID')),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: buCtrl, decoration: const InputDecoration(labelText: 'BU')),
              const SizedBox(height: 12),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<StoreProvider>().upsert(
                StoreModel(
                  storeId: idCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  bu: buCtrl.text.trim(),
                  status: 'active',
                  registerUrl: urlCtrl.text.trim(),
                  cashVoucherUrl: '',
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, StoreModel store) async {
    final nameCtrl = TextEditingController(text: store.name);
    final buCtrl = TextEditingController(text: store.bu);
    final urlCtrl = TextEditingController(text: store.registerUrl);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Store'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Store ID: ${store.storeId}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: buCtrl, decoration: const InputDecoration(labelText: 'BU')),
              const SizedBox(height: 12),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = store.copyWith(
                name: nameCtrl.text.trim(),
                bu: buCtrl.text.trim(),
                registerUrl: urlCtrl.text.trim(),
              );
              await context.read<StoreProvider>().upsert(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _importExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return;

    final sheet = excel.tables.values.first;
    if (sheet == null) return;

    final provider = context.read<StoreProvider>();

    // เริ่มที่แถว 1 (ข้าม header)
    for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);

      if (row.isEmpty) continue;

      final storeId = row.length > 0 ? row[0]?.value?.toString() ?? '' : '';
      final name = row.length > 1 ? row[1]?.value?.toString() ?? '' : '';
      final bu = row.length > 2 ? row[2]?.value?.toString() ?? '' : '';
      final status =
          row.length > 3 ? row[3]?.value?.toString() ?? 'active' : 'active';
      final registerUrl =
          row.length > 4 ? row[4]?.value?.toString() ?? '' : '';
      final cashVoucherUrl =
          row.length > 5 ? row[5]?.value?.toString() ?? '' : '';

      if (storeId.isEmpty) continue;

      await provider.upsert(
        StoreModel(
          storeId: storeId,
          name: name,
          bu: bu,
          status: status,
          registerUrl: registerUrl,
          cashVoucherUrl: cashVoucherUrl,
        ),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel import completed')),
      );
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Excel (.xlsx)'),
              onTap: () {
                StoreExportService.export(
                  stores: context.read<StoreProvider>().stores,
                  type: StoreExportType.excel,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('CSV (.csv)'),
              onTap: () {
                StoreExportService.export(
                  stores: context.read<StoreProvider>().stores,
                  type: StoreExportType.csv,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('JSON (.json)'),
              onTap: () {
                StoreExportService.export(
                  stores: context.read<StoreProvider>().stores,
                  type: StoreExportType.json,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


  void _downloadSampleFile() {
    final excel = Excel.createExcel();
    final sheet = excel['stores'];

    // Header (ต้องตรงกับ import)
    sheet.appendRow([
      TextCellValue('store_id'),
      TextCellValue('name'),
      TextCellValue('bu'),
      TextCellValue('status'),
      TextCellValue('register_url'),
      TextCellValue('cash_voucher_url'),
    ]);

    // Sample rows
    sheet.appendRow([
      TextCellValue('B001'),
      TextCellValue('BaNANA Central World'),
      TextCellValue('BaNANA'),
      TextCellValue('active'),
      TextCellValue('https://instore.bnn.in.th/banana-cw'),
      TextCellValue(''),
    ]);

    sheet.appendRow([
      TextCellValue('S001'),
      TextCellValue('Studio7 Siam Paragon'),
      TextCellValue('Studio7'),
      TextCellValue('active'),
      TextCellValue('https://instore.bnn.in.th/studio7-paragon'),
      TextCellValue(''),
    ]);

    sheet.appendRow([
      TextCellValue('SS001'),
      TextCellValue('Samsung Central Ladprao'),
      TextCellValue('Samsung'),
      TextCellValue('inactive'),
      TextCellValue('https://instore.bnn.in.th/samsung-ladprao'),
      TextCellValue(''),
    ]);

    final bytes = excel.encode();
    if (bytes == null) return;

    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-');

    StoreExportService.downloadRawFileBytes(
      bytes: bytes,
      filename: 'sample_store_import_$timestamp.xlsx',
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StoreModel store,
  ) async {
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to delete store:\n\n'
                '${store.storeId} - ${store.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type DELETE to confirm:',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              if (confirmCtrl.text.trim() == 'DELETE') {
                await context
                .read<StoreProvider>()
                .deleteStore(store);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}