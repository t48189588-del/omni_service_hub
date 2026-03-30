import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

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

  Future<void> updateService(String tenantId, ServiceModel service) async {
    try {
      if (service.id == null) throw "Service ID missing for update";
      await _db
          .collection('tenants')
          .doc(tenantId)
          .collection('services')
          .doc(service.id)
          .update(service.toMap());
    } catch (e) {
      debugPrint("DatabaseService Error (UpdateService): $e");
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

  // --- Appointment Management ---

  /// Checks if a time slot is available for a tenant.
  /// Includes a 10-minute buffer between appointments.
  Future<bool> checkAvailability(String tenantId, DateTime startTime, int durationMinutes) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    
    // We check for overlaps. 
    // An overlap exists if: (existingStart < requestedEnd + 10min) AND (existingEnd + 10min > requestedStart)
    // To simplify: check all appointments for that day and compare.
    final dayStart = DateTime(startTime.year, startTime.month, startTime.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('appointments')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
        .get();

    for (var doc in snapshot.docs) {
      final existingStart = (doc['startTime'] as Timestamp).toDate();
      final existingEnd = (doc['endTime'] as Timestamp).toDate();
      
      // Add 10 min buffer to existing appointments for check
      final bufferedExistingEnd = existingEnd.add(const Duration(minutes: 10));
      final bufferedRequestedEnd = endTime.add(const Duration(minutes: 10));

      // Standard overlap check: (StartA < EndB) && (EndA > StartB)
      if (startTime.isBefore(bufferedExistingEnd) && endTime.add(const Duration(minutes: 10)).isAfter(existingStart)) {
        // Double check: specifically if requested start is before existing end+buffer, 
        // AND requested end+buffer is after existing start.
        return false; 
      }
    }
    return true;
  }

  Future<void> createAppointment(String tenantId, AppointmentModel appointment) async {
    await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('appointments')
        .add(appointment.toMap());
  }

  Stream<List<AppointmentModel>> getAppointments(String tenantId) {
    return _db
        .collection('tenants')
        .doc(tenantId)
        .collection('appointments')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateAppointmentStatus(String tenantId, String appId, AppointmentStatus status) async {
    await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('appointments')
        .doc(appId)
        .update({'status': status.name});
  }
}
