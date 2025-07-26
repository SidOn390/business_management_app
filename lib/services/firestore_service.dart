// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Cold Storages ─────────────────────────────────────────────────────
  /// Stream of cold storages as list of {id, name}
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

  // ─── Product Types ────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getProductTypes() => _db
      .collection('product_types')
      .orderBy('name')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
            .toList(),
      );

  Future<void> addProductType(String name) =>
      _db.collection('product_types').add({'name': name.trim()});

  Future<void> updateProductType(String id, String newName) =>
      _db.collection('product_types').doc(id).update({'name': newName.trim()});

  Future<void> deleteProductType(String id) =>
      _db.collection('product_types').doc(id).delete();

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
}
