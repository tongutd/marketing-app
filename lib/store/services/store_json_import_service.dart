import 'dart:convert';
import 'dart:typed_data';

import '../models/store_model.dart';

class StoreJsonImportService {
  /// Parse JSON file → List<StoreModel>
  static List<StoreModel> parseJson(
    Uint8List bytes,
  ) {
    final jsonString = utf8.decode(bytes);
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final List<StoreModel> stores = [];

    data.forEach((key, value) {
      final storeId = key;
      final name = value['name']?.toString() ?? '';
      final bu = value['bu']?.toString() ?? '';
      final registerUrl = value['url']?.toString() ?? '';

      /// สร้าง cash voucher url อัตโนมัติ
      final cashVoucherUrl =
          'https://instore.bnn.in.th/script/7clubplus-qr-code-cash-voucher/?id=$storeId';

      stores.add(
        StoreModel(
          storeId: storeId,
          name: name,
          bu: bu,
          status: 'active', // 🔥 default active
          registerUrl: registerUrl,
          cashVoucherUrl: cashVoucherUrl,
        ),
      );
    });

    return stores;
  }
}