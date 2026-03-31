import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLocationModel {
  final String id;
  final String userId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final DateTime createdAt;

  SavedLocationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.createdAt,
  });

  factory SavedLocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedLocationModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      address: data['address'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      type: data['type'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory SavedLocationModel.fromMap(Map<String, dynamic> map, String id) {
    return SavedLocationModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      type: map['type'] as String,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SavedLocationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
    DateTime? createdAt,
  }) {
    return SavedLocationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedLocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SavedLocationModel(id: $id, name: $name, type: $type)';
}
