import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialize a new tenant and an admin user profile
  Future<void> initializeNewTenant({
    required String uid,
    required String email,
    required String businessName,
  }) async {
    try {
      // 1. Create a new unique Tenant ID
      final tenantRef = _db.collection('tenants').doc();
      final tenantId = tenantRef.id;

      // 2. Perform a multi-document write
      // Note: In rules we allow matching 'tenantId' for creation if authenticated
      await _db.runTransaction((transaction) async {
        // Create the Tenant document
        transaction.set(tenantRef, {
          'name': businessName,
          'createdAt': FieldValue.serverTimestamp(),
          'ownerUid': uid,
          'config': {
            'currency': 'USD',
            'timezone': 'UTC',
          },
        });

        // Create the User document linked to the tenant
        final userRef = _db.collection('users').doc(uid);
        transaction.set(userRef, {
          'email': email,
          'tenantId': tenantId,
          'role': 'admin', // First user is admin
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint("DatabaseService Error (InitTenant): $e");
      rethrow;
    }
  }

  // Fetch tenant info
  Future<DocumentSnapshot> getTenant(String tenantId) {
    return _db.collection('tenants').doc(tenantId).get();
  }

  // --- Service Management ---

  Stream<List<ServiceModel>> getServices(String tenantId) {
    return _db
        .collection('tenants')
        .doc(tenantId)
        .collection('services')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addService(String tenantId, ServiceModel service) async {
    try {
      await _db
          .collection('tenants')
          .doc(tenantId)
          .collection('services')
          .add(service.toMap());
    } catch (e) {
      debugPrint("DatabaseService Error (AddService): $e");
      rethrow;
    }
  }

  Future<void> deleteService(String tenantId, String serviceId) async {
    await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('services')
        .doc(serviceId)
        .delete();
  }
}
