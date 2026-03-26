import 'dart:typed_data';
import 'package:excel/excel.dart';

import '../models/store_model.dart';

class StoreImportService {
  /// ============================================
  /// Excel → StoreModel
  ///
  /// Sheet name: stores
  ///
  /// Columns:
  /// A = storeId
  /// B = name
  /// C = bu
  /// D = registerUrl
  /// E = cashVoucherUrl
  /// F = status (active / inactive)
  /// ============================================
  static List<StoreModel> parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables['stores'];
    if (sheet == null) {
      throw Exception('Sheet "stores" not found');
    }

    final List<StoreModel> stores = [];

    /// Row 0 = header
    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      final storeId = row.length > 0
          ? row[0]?.value?.toString().trim()
          : null;

      final name = row.length > 1
          ? row[1]?.value?.toString().trim()
          : null;

      final bu = row.length > 2
          ? row[2]?.value?.toString().trim()
          : null;

      final registerUrl = row.length > 3
          ? row[3]?.value?.toString().trim()
          : '';

      final cashVoucherUrl = row.length > 4
          ? row[4]?.value?.toString().trim()
          : '';

      final rawStatus = row.length > 5
          ? row[5]?.value?.toString().trim().toLowerCase()
          : 'active';

      if (storeId == null || storeId.isEmpty) continue;
      if (name == null || name.isEmpty) continue;
      if (bu == null || bu.isEmpty) continue;

      final status =
          rawStatus == 'inactive' ? 'inactive' : 'active';

      stores.add(
        StoreModel(
          storeId: storeId,
          name: name,
          bu: bu,
          status: status,
          registerUrl: registerUrl ?? '',
          cashVoucherUrl: cashVoucherUrl ?? '',
        ),
      );
    }

    return stores;
  }
}