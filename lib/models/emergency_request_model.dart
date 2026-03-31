import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequestModel {
  final String id;
  final String userId;
  final String type;
  final String status;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  EmergencyRequestModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    this.resolvedAt,
  });

  factory EmergencyRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyRequestModel(
      id: doc.id,
      userId: data['userId'] as String,
      type: data['type'] as String,
      status: data['status'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      address: data['address'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory EmergencyRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyRequestModel(
      id: id,
      userId: map['userId'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? map['resolvedAt'] is Timestamp
              ? (map['resolvedAt'] as Timestamp).toDate()
              : DateTime.parse(map['resolvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  EmergencyRequestModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return EmergencyRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EmergencyRequestModel(id: $id, type: $type, status: $status)';
}
