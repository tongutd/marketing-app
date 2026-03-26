import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/store_model.dart';
import '../services/store_import_service.dart';
import '../services/store_service.dart';
import '../../providers/auth_provider.dart';

class StoreImportPage extends StatefulWidget {
  const StoreImportPage({super.key});

  @override
  State<StoreImportPage> createState() => _StoreImportPageState();
}

class _StoreImportPageState extends State<StoreImportPage> {
  Uint8List? _bytes;
  List<StoreModel> _preview = [];
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Stores (Excel)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPickButton(),
            const SizedBox(height: 12),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),

            if (_preview.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Preview (${_preview.length} stores)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildPreviewTable()),
              const SizedBox(height: 12),
              _buildConfirmButton(uid),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PICK FILE
  // ==========================================================
  Widget _buildPickButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text('Select Excel file'),
      onPressed: _loading ? null : _pickFile,
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _error = null;
      _preview = [];
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      setState(() => _error = 'Cannot read file');
      return;
    }

    try {
      final stores = StoreImportService.parseExcel(bytes);

      setState(() {
        _bytes = bytes;
        _preview = stores;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  // ==========================================================
  // PREVIEW TABLE
  // ==========================================================
  Widget _buildPreviewTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            MaterialStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('Store ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('BU')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Register URL')),
          DataColumn(label: Text('Cash Voucher URL')),
        ],
        rows: _preview.map((s) {
          return DataRow(
            cells: [
              DataCell(Text(s.storeId)),
              DataCell(Text(s.name)),
              DataCell(Text(s.bu)),
              DataCell(Text(s.status)),
              DataCell(
                SizedBox(
                  width: 220,
                  child: Text(
                    s.registerUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 220,
                  child: Text(
                    s.cashVoucherUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // CONFIRM IMPORT
  // ==========================================================
  Widget _buildConfirmButton(String uid) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Confirm Import'),
        onPressed: _loading
            ? null
            : () => _confirmImport(uid),
      ),
    );
  }

  Future<void> _confirmImport(String uid) async {
    if (_preview.isEmpty) return;

    setState(() => _loading = true);

    try {
      await StoreService.batchUpsertStores(
        stores: _preview,
        uid: uid,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${_preview.length} stores successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _preview = [];
        _bytes = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}