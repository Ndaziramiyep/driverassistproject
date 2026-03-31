import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return _db.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    return _db.collection(collection).get();
  }

  Future<QuerySnapshot> getCollectionWhere(
    String collection, {
    required String field,
    required dynamic value,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _db.collection(collection).where(field, isEqualTo: value);
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.get();
  }

  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
  }) {
    Query query = _db.collection(collection);
    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots();
  }

  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    return _db.collection(collection).add(data);
  }

  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _db.batch();
    for (final op in operations) {
      final ref = _db.collection(op['collection'] as String).doc(op['docId'] as String?);
      switch (op['type'] as String) {
        case 'set':
          batch.set(ref, op['data'] as Map<String, dynamic>);
          break;
        case 'update':
          batch.update(ref, op['data'] as Map<String, dynamic>);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    }
    await batch.commit();
  }
}
