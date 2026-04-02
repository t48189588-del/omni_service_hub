import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, cancelled }

class BookingModel {
  final String id;
  final String tenantId;
  final String serviceId;
  final String serviceName;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final String humanReadableId;
  final double price;
  final Map<String, dynamic> customFields;

  BookingModel({
    required this.id,
    required this.tenantId,
    required this.serviceId,
    required this.serviceName,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.confirmed,
    required this.humanReadableId,
    this.price = 0.0,
    this.customFields = const {},
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => BookingStatus.confirmed),
      humanReadableId: data['humanReadableId'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      customFields: data['customFields'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status.name,
      'humanReadableId': humanReadableId,
      'price': price,
      'customFields': customFields,
    };
  }
}
