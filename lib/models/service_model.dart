import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int bufferMinutes;
  final DateTime? createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.durationMinutes = 60,
    this.bufferMinutes = 10,
    this.createdAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 60,
      bufferMinutes: data['bufferMinutes'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'bufferMinutes': bufferMinutes,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
