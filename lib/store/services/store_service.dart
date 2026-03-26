import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';

class StoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _col =
      _db.collection('stores');

  // ==========================================================
  // STREAM ALL STORES
  // ==========================================================
  static Stream<List<StoreModel>> streamStores() {
    return _col.snapshots().map((snapshot) {
      print('🔥 STORE SNAPSHOT COUNT = ${snapshot.docs.length}');

      final stores = snapshot.docs.map((doc) {
        print('📦 DOC ID = ${doc.id}');
        return StoreModel.fromFirestore(doc);
      }).toList();

      // sort by storeId (string)
      stores.sort((a, b) => a.storeId.compareTo(b.storeId));

      return stores;
    });
  }

  // ==========================================================
  // GET ONE
  // ==========================================================
  static Future<StoreModel?> getStore(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return StoreModel.fromFirestore(doc);
  }

  // ==========================================================
  // UPSERT
  // ==========================================================
  static Future<void> upsertStore({
    required StoreModel store,
    required String uid,
  }) async {
    final ref = _col.doc(store.storeId);
    final snap = await ref.get();

    await ref.set(
      store.toFirestore(
        uid: uid,
        isCreate: !snap.exists,
      ),
      SetOptions(merge: true),
    );
  }

  // ==========================================================
  // BATCH UPSERT
  // ==========================================================
  static Future<void> batchUpsertStores({
    required List<StoreModel> stores,
    required String uid,
  }) async {
    final batch = _db.batch();

    for (final store in stores) {
      final ref = _col.doc(store.storeId);

      batch.set(
        ref,
        store.toFirestore(
          uid: uid,
          isCreate: true,
        ),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  // ==========================================================
  // TOGGLE STATUS
  // ==========================================================
  static Future<void> toggleStatus({
    required String storeId,
    required bool isActive,
    required String uid,
  }) async {
    await _col.doc(storeId).update({
      'status': isActive ? 'active' : 'inactive',
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
    });
  }

  // ==========================================================
  // DELETE
  // ==========================================================
  static Future<void> deleteStore(String storeId) async {
    await _col.doc(storeId).delete();
  }
}