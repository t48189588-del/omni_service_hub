import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, cancelled }

class AppointmentModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String customerName;
  final String customerEmail;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.customerName,
    required this.customerEmail,
    required this.startTime,
    required this.endTime,
    this.status = AppointmentStatus.pending,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => AppointmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status.name,
    };
  }
}
