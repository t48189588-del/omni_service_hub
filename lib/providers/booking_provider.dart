import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../services/database_service.dart';

class BookingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime get selectedDay => _selectedDay;

  List<DateTime> _availableSlots = [];
  List<DateTime> get availableSlots => _availableSlots;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setSelectedDay(DateTime day, String tenantId, ServiceModel service) {
    _selectedDay = day;
    fetchAvailableSlots(tenantId, service);
  }

  /// Day 3 Mission: The Slot Generator logic
  List<DateTime> generateSlots({
    required DateTime date,
    required int startHour,
    required int endHour,
    required int serviceDuration,
    required int buffer,
    required List<Map<String, dynamic>> existingIntervals,
  }) {
    List<DateTime> slots = [];
    
    // Normalize date to 00:00:00
    final baseDate = DateTime(date.year, date.month, date.day);
    
    DateTime current = baseDate.add(Duration(hours: startHour ~/ 100, minutes: startHour % 100));
    final endLimit = baseDate.add(Duration(hours: endHour ~/ 100, minutes: endHour % 100));

    final totalNeeded = serviceDuration + buffer;

    while (current.isBefore(endLimit)) {
      if (_isIntervalAvailable(current, totalNeeded, existingIntervals)) {
        slots.add(current);
      }
      // Increment by 15 mins for slot density
      current = current.add(const Duration(minutes: 15));
    }
    
    return slots;
  }

  bool _isIntervalAvailable(DateTime start, int durationWithBuffer, List<Map<String, dynamic>> existing) {
    final end = start.add(Duration(minutes: durationWithBuffer));
    
    for (var interval in existing) {
      final iStart = (interval['start'] as Timestamp).toDate();
      final iEnd = (interval['end'] as Timestamp).toDate();
      
      // Existing intervals already have their own buffers logically handled by the transaction write,
      // but for "Day 3" strictness, we check if [start, end] overlaps with any [iStart, iEnd]
      if (start.isBefore(iEnd) && end.isAfter(iStart)) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchAvailableSlots(String tenantId, ServiceModel service) async {
    _isLoading = true;
    notifyListeners();

    try {
      final startOfDayStr = "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}";
      final dayDoc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('days')
          .doc(startOfDayStr)
          .get();

      List<Map<String, dynamic>> existingIntervals = [];
      if (dayDoc.exists && dayDoc.data() != null) {
        existingIntervals = List<Map<String, dynamic>>.from(dayDoc.data()!['intervals'] ?? []);
      }

      // Fetch business hours from tenant (fallback to 900-1700)
      final tenantDoc = await FirebaseFirestore.instance.collection('tenants').doc(tenantId).get();
      final config = tenantDoc.data()?['config']?['businessHours'] ?? {'start': 900, 'end': 1700};

      _availableSlots = generateSlots(
        date: _selectedDay,
        startHour: config['start'] ?? 900,
        endHour: config['end'] ?? 1700,
        serviceDuration: service.durationMinutes,
        buffer: service.bufferMinutes,
        existingIntervals: existingIntervals,
      );
    } catch (e) {
      debugPrint("BookingProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
