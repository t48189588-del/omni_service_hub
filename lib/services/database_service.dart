import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialize a new tenant and an admin user profile
  Future<void> initializeNewTenant({
    required String uid,
    required String email,
    required String businessName,
    String businessType = 'massage',
  }) async {
    try {
      // 1. Create a new unique Tenant ID
      final tenantRef = _db.collection('tenants').doc();
      final tenantId = tenantRef.id;

      // 2. Perform a multi-document write
      await _db.runTransaction((transaction) async {
        // Create the Tenant document
        transaction.set(tenantRef, {
          'name': businessName,
          'createdAt': FieldValue.serverTimestamp(),
          'ownerUid': uid,
          'businessType': businessType,
          'config': {
            'currency': 'USD',
            'timezone': 'UTC',
            'businessHours': {
              'start': 900,
              'end': 1700,
            },
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

  Future<void> updateTenantConfig(String tenantId, Map<String, dynamic> data) async {
    try {
      await _db.collection('tenants').doc(tenantId).update(data);
    } catch (e) {
      debugPrint("DatabaseService Error (UpdateTenant): $e");
      rethrow;
    }
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
      if (service.id.isEmpty) throw "Service ID missing for update";
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
        .collection('bookings') // Standardized
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
        .get();

    for (var doc in snapshot.docs) {
      final existingStart = (doc['startTime'] as Timestamp).toDate();
      final existingEnd = (doc['endTime'] as Timestamp).toDate();
      
      final bufferedExistingEnd = existingEnd.add(const Duration(minutes: 10));

      if (startTime.isBefore(bufferedExistingEnd) && endTime.add(const Duration(minutes: 10)).isAfter(existingStart)) {
        return false; 
      }
    }
    return true;
  }

  /// Fetches confirmed bookings for a tenant
  Stream<List<BookingModel>> getBookings(String tenantId) {
    return _db
        .collection('tenants')
        .doc(tenantId)
        .collection('bookings')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Fetches bookings for today based on the local timezone
  Stream<List<BookingModel>> getTodayBookings(String tenantId) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _db
        .collection('tenants')
        .doc(tenantId)
        .collection('bookings')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Updates the status of a specific booking
  Future<void> updateBookingStatus(String tenantId, String appId, BookingStatus status) async {
    await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('bookings')
        .doc(appId)
        .update({'status': status.name});
  }
  /// Day 3 Atomic Shield: Atomic Transaction for Booking
  Future<String> performBooking(String tenantId, BookingModel booking, int totalDurationPlusBuffer) async {
    final startOfDayStr = "${booking.startTime.year}-${booking.startTime.month.toString().padLeft(2, '0')}-${booking.startTime.day.toString().padLeft(2, '0')}";
    final dayRef = _db.collection('tenants').doc(tenantId).collection('days').doc(startOfDayStr);
    final bookingsRef = _db.collection('tenants').doc(tenantId).collection('bookings');
    
    final String humanId = _generateHumanReadableId();

    await _db.runTransaction((transaction) async {
      // 1. Fetch the daily lock document
      final daySnapshot = await transaction.get(dayRef);
      final List<dynamic> currentIntervals = daySnapshot.exists ? daySnapshot.get('intervals') ?? [] : [];
      final List<Map<String, dynamic>> existingIntervals = List<Map<String, dynamic>>.from(currentIntervals);

      // 2. Re-verify availability using the specific buffer from Service
      final isAvailable = _isIntervalAvailableTransaction(
        booking.startTime, 
        totalDurationPlusBuffer, 
        existingIntervals
      );

      if (!isAvailable) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-booked',
          message: 'The slot was taken while you were processing.',
        );
      }

      // 3. Update the daily lock document
      final newInterval = {
        'start': Timestamp.fromDate(booking.startTime),
        'end': Timestamp.fromDate(booking.endTime),
        'serviceId': booking.serviceId,
      };

      if (!daySnapshot.exists) {
        transaction.set(dayRef, {'intervals': [newInterval]});
      } else {
        transaction.update(dayRef, {
          'intervals': FieldValue.arrayUnion([newInterval])
        });
      }

      // 4. Create the detailed booking record
      final newBookingRef = bookingsRef.doc();
      final finalBooking = booking.toMap();
      finalBooking['humanReadableId'] = humanId; // Assign the generated ID
      
      transaction.set(newBookingRef, finalBooking);
    });

    return humanId;
  }

  String _generateHumanReadableId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const nums = '123456789';
    final random = Random();
    
    String res = '';
    for (int i = 0; i < 3; i++) {
      res += chars[random.nextInt(chars.length)];
    }
    res += '-';
    for (int i = 0; i < 3; i++) {
      res += nums[random.nextInt(nums.length)];
    }
    
    return res;
  }

  // Transaction-specific interval overlap check
  bool _isIntervalAvailableTransaction(DateTime startTime, int durationMinutes, List<Map<String, dynamic>> existing) {
    final endTimeWithBuffer = startTime.add(Duration(minutes: durationMinutes + 10));
    
    for (var interval in existing) {
      final iStart = (interval['start'] as Timestamp).toDate();
      final iEnd = (interval['end'] as Timestamp).toDate();
      
      // Existing intervals also effective reserve a 10-minute window AFTER their end time.
      final existingEndWithBuffer = iEnd.add(const Duration(minutes: 10));

      if (startTime.isBefore(existingEndWithBuffer) && endTimeWithBuffer.isAfter(iStart)) {
        return false;
      }
    }
    return true;
  }
}
