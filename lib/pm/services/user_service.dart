import 'package:cloud_firestore/cloud_firestore.dart';

class PMUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool active;

  PMUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  factory PMUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PMUser(
      uid: doc.id,
      name: data['displayName'] ?? 'No name', // ✅ สำคัญที่สุด
      email: data['email'] ?? '',
      role: data['role'] ?? 'staff',
      active: data['active'] ?? true,
    );
  }
}

class UserService {
  static Future<List<PMUser>> fetchUsers() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('active', isEqualTo: true) // ✅ เอาเฉพาะ active
        .get();

    return snap.docs
        .map((d) => PMUser.fromFirestore(d))
        .toList();
  }
}