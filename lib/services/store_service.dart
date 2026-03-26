import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';

class StoreService {
  final _col = FirebaseFirestore.instance.collection('stores');

  Stream<List<StoreModel>> getStores() {
    return _col.orderBy('id').snapshots().map(
          (snap) => snap.docs.map((e) => StoreModel.fromDoc(e)).toList(),
        );
  }

  Future<void> addOrUpdate(StoreModel store) async {
    await _col.doc(store.id.toString()).set(
      {
        ...store.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> delete(int id) async {
    await _col.doc(id.toString()).delete();
  }
}