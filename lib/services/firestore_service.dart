// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Cold Storages ─────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getColdStorages() => _db
      .collection('cold_storages')
      .orderBy('name')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList(),
      );

  Future<void> addColdStorage(String name) =>
      _db.collection('cold_storages').add({'name': name.trim()});

  Future<void> updateColdStorage(String id, String newName) =>
      _db.collection('cold_storages').doc(id).update({'name': newName.trim()});

  Future<void> deleteColdStorage(String id) =>
      _db.collection('cold_storages').doc(id).delete();

  // ─── Products ───────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getProducts() => _db
      .collection('products')
      .orderBy('name')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList(),
      );

  Future<void> addProduct(String name) =>
      _db.collection('products').add({'name': name.trim()});

  Future<void> updateProduct(String id, String newName) =>
      _db.collection('products').doc(id).update({'name': newName.trim()});

  Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  // ─── Brands ───────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getBrands() => _db
      .collection('brands')
      .orderBy('name')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList(),
      );

  Future<void> addBrand(String name) =>
      _db.collection('brands').add({'name': name.trim()});

  Future<void> updateBrand(String id, String newName) =>
      _db.collection('brands').doc(id).update({'name': newName.trim()});

  Future<void> deleteBrand(String id) =>
      _db.collection('brands').doc(id).delete();

  // In lib/services/firestore_service.dart

  // Checks if a receipt with the given number already exists for a specific cold storage
  Future<bool> doesReceiptExist(
    String receiptNumber,
    String coldStorageName,
  ) async {
    final query = await _db
        .collection('receipts')
        .where('receiptNumber', isEqualTo: receiptNumber)
        .where('coldStorageName', isEqualTo: coldStorageName)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}
