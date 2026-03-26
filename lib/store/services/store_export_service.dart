import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:excel/excel.dart';

import '../models/store_model.dart';

enum StoreExportType {
  excel,
  csv,
  json,
}

class StoreExportService {
  /// =========================================================
  /// MAIN EXPORT METHOD (เลือกประเภทไฟล์ได้)
  /// =========================================================
  static void export({
    required List<StoreModel> stores,
    required StoreExportType type,
  }) {
    switch (type) {
      case StoreExportType.excel:
        _exportExcel(stores);
        break;

      case StoreExportType.csv:
        _exportCsv(stores);
        break;

      case StoreExportType.json:
        _exportJson(stores);
        break;
    }
  }

  /// =========================================================
  /// EXCEL
  /// =========================================================
  static void _exportExcel(List<StoreModel> stores) {
    final excel = Excel.createExcel();
    final sheet = excel['stores'];

    sheet.appendRow([
      TextCellValue('store_id'),
      TextCellValue('name'),
      TextCellValue('bu'),
      TextCellValue('status'),
      TextCellValue('register_url'),
      TextCellValue('cash_voucher_url'),
      TextCellValue('updated_at'),
    ]);

    for (final s in stores) {
      sheet.appendRow([
        TextCellValue(s.storeId),
        TextCellValue(s.name),
        TextCellValue(s.bu),
        TextCellValue(s.status),
        TextCellValue(s.registerUrl),
        TextCellValue(s.cashVoucherUrl),
        TextCellValue(s.updatedAt?.toIso8601String() ?? ''),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    _download(
      bytes: Uint8List.fromList(bytes),
      filename: 'stores.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// =========================================================
  /// CSV
  /// =========================================================
  static void _exportCsv(List<StoreModel> stores) {
    final buffer = StringBuffer();

    buffer.writeln(
        'store_id,name,bu,status,register_url,cash_voucher_url,updated_at');

    for (final s in stores) {
      buffer.writeln(
        '"${s.storeId}",'
        '"${_escape(s.name)}",'
        '"${_escape(s.bu)}",'
        '"${s.status}",'
        '"${_escape(s.registerUrl)}",'
        '"${_escape(s.cashVoucherUrl)}",'
        '"${s.updatedAt?.toIso8601String() ?? ''}"',
      );
    }

    _download(
      bytes: Uint8List.fromList(buffer.toString().codeUnits),
      filename: 'stores.csv',
      mimeType: 'text/csv',
    );
  }

  /// =========================================================
  /// JSON
  /// =========================================================
  static void _exportJson(List<StoreModel> stores) {
    final data = {
      for (final s in stores)
        s.storeId: {
          'name': s.name,
          'bu': s.bu,
          'status': s.status,
          'registerUrl': s.registerUrl,
          'cashVoucherUrl': s.cashVoucherUrl,
          'updatedAt': s.updatedAt?.toIso8601String(),
        }
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    _download(
      bytes: Uint8List.fromList(jsonStr.codeUnits),
      filename: 'stores.json',
      mimeType: 'application/json',
    );
  }

  /// =========================================================
  /// DOWNLOAD HELPER (WEB SAFE)
  /// =========================================================
  static void _download({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  static String _escape(String value) {
    return value.replaceAll('"', '""');
  }

  static void downloadRawFile({
    required String content,
    required String filename,
  }) {
    final bytes = Uint8List.fromList(content.codeUnits);

    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  static void downloadRawFileBytes({
    required List<int> bytes,
    required String filename,
  }) {
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
  }


