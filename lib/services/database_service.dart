import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
}
