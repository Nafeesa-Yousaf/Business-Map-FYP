import 'package:business_map/data/model/request/firebase_filter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCrudService {
  final FirebaseFirestore _firestore;

  FirebaseCrudService(this._firestore);

  Future<String> insert({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    if (docId != null) {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data)
          .timeout(const Duration(seconds: 10));
      return docId;
    } else {
      DocumentReference docRef = await _firestore
          .collection(collection)
          .add(data)
          .timeout(const Duration(seconds: 10));
      return docRef.id;
    }
  }

  Future<void> update({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await _firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge))
        .timeout(const Duration(seconds: 10));
  }

  Future<void> delete({
    required String collection,
    required String docId,
  }) async {
    await _firestore
        .collection(collection)
        .doc(docId)
        .delete()
        .timeout(const Duration(seconds: 10));
  }

  Future<Map<String, dynamic>?> getById({
    required String collection,
    required String docId,
  }) async {
    DocumentSnapshot doc = await _firestore
        .collection(collection)
        .doc(docId)
        .get()
        .timeout(const Duration(seconds: 10));
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<List<Map<String, dynamic>>> getAll({
    required String collection,
  }) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .get()
        .timeout(const Duration(seconds: 10));
    return querySnapshot.docs
        .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<List<Map<String, dynamic>>> search({
    required String collection,
    required List<FirebaseFilterModel> filters,
  }) async {
    Query query = _firestore.collection(collection);

    for (var filter in filters) {
      query = query.where(filter.field, isEqualTo: filter.value);
    }

    QuerySnapshot querySnapshot = await query.get().timeout(const Duration(seconds: 10));
    return querySnapshot.docs
        .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Stream<List<Map<String, dynamic>>> getFilteredStream({
    required String collection,
    required List<FirebaseFilterModel> filters,
  }) {
    Query query = _firestore.collection(collection);

    for (var filter in filters) {
      query = query.where(filter.field, isEqualTo: filter.value);
    }

    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }
}
