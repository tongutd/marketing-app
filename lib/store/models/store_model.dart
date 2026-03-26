import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String storeId;
  final String name;
  final String bu;
  final String status;

  final String registerUrl;
  final String cashVoucherUrl;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const StoreModel({
    required this.storeId,
    required this.name,
    required this.bu,
    required this.status,
    required this.registerUrl,
    required this.cashVoucherUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // ======================================================
  // Firestore → Model (SAFE VERSION)
  // ======================================================
  factory StoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      return StoreModel(
        storeId: doc.id,
        name: '',
        bu: '',
        status: 'active',
        registerUrl: '',
        cashVoucherUrl: '',
      );
    }

    final qr = data['qr'] as Map<String, dynamic>?;

    return StoreModel(
      storeId: doc.id,
      name: data['name'] ?? '',
      bu: data['bu'] ?? '',
      status: data['status'] ?? 'active',

      registerUrl: qr?['registerUrl'] ?? '',
      cashVoucherUrl: qr?['cashVoucherUrl'] ?? '',

      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
    );
  }

  // ======================================================
  // Model → Firestore
  // ======================================================
  Map<String, dynamic> toFirestore({
    required String uid,
    bool isCreate = false,
  }) {
    return {
      'storeId': storeId,
      'name': name,
      'bu': bu,
      'status': status,

      'qr': {
        'registerUrl': registerUrl,
        'cashVoucherUrl': cashVoucherUrl,
      },

      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      if (isCreate) 'createdBy': uid,
      'updatedBy': uid,
    };
  }

  // ======================================================
  // COPY
  // ======================================================
  StoreModel copyWith({
    String? name,
    String? bu,
    String? status,
    String? registerUrl,
    String? cashVoucherUrl,
  }) {
    return StoreModel(
      storeId: storeId,
      name: name ?? this.name,
      bu: bu ?? this.bu,
      status: status ?? this.status,
      registerUrl: registerUrl ?? this.registerUrl,
      cashVoucherUrl: cashVoucherUrl ?? this.cashVoucherUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}