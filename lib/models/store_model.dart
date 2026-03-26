import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final int id;
  final String name;
  final String bu;
  final String url;

  StoreModel({
    required this.id,
    required this.name,
    required this.bu,
    required this.url,
  });

  factory StoreModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: data['id'],
      name: data['name'],
      bu: data['bu'],
      url: data['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bu': bu,
      'url': url,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}