import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/store_model.dart';
import '../services/store_service.dart';

class StoreProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  bool _initialized = false;

  StoreProvider() {
    _listen();
  }

  void _listen() {
    if (_initialized) return;
    _initialized = true;

    StoreService.streamStores().listen((data) {
      _stores = data;
      notifyListeners();
    });
  }

  // ==================================================
  // 🔥 UPSERT (สำคัญมาก ตัวที่ขาด)
  // ==================================================
  Future<void> upsert(StoreModel store) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await StoreService.upsertStore(
      store: store,
      uid: user.uid,
    );
  }

  // ==================================================
  // TOGGLE STATUS
  // ==================================================
  Future<void> toggleStatus(StoreModel store, bool isActive) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await StoreService.toggleStatus(
      storeId: store.storeId,
      isActive: isActive,
      uid: user.uid,
    );
  }

  // ==================================================
  // DELETE
  // ==================================================
  Future<void> deleteStore(StoreModel store) async {
    await FirebaseFirestore.instance
        .collection('stores')
        .doc(store.storeId)
        .delete();

    stores.removeWhere((s) => s.storeId == store.storeId);
    notifyListeners();
  }

}