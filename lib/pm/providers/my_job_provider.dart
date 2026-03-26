import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/my_job_model.dart';

class MyJobProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('my_jobs');
  final _auth = FirebaseAuth.instance;

  Stream<List<MyJobModel>> watchTodayJobs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('my_jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((e) => MyJobModel.fromFirestore(e)).toList());
      }

  Future<void> add(MyJobModel job) async {
    final uid = _auth.currentUser!.uid;

    await _col.add(job.copyWith(uid: uid).toFirestore());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> update(MyJobModel job) async {
    await _col.doc(job.id).update({
      'title': job.title,
      'description': job.description,
      'workDate': job.workDate,
      'mainUrl': job.mainUrl,
      'relatedLinks': job.relatedLinks,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleCompleted(MyJobModel job) async {
    await _col.doc(job.id).update({
      'completed': !job.completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}