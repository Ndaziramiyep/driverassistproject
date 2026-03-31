import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String? phone;
  final bool isOpen;
  final double? distance;
  final String? imageUrl;

  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    this.phone,
    required this.isOpen,
    this.distance,
    this.imageUrl,
  });

  factory ServiceProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceProviderModel(
      id: doc.id,
      name: data['name'] as String,
      type: data['type'] as String,
      address: data['address'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'] as int,
      phone: data['phone'] as String?,
      isOpen: data['isOpen'] as bool,
      distance: data['distance'] != null ? (data['distance'] as num).toDouble() : null,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceProviderModel(
      id: id,
      name: map['name'] as String,
      type: map['type'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      phone: map['phone'] as String?,
      isOpen: map['isOpen'] as bool,
      distance: map['distance'] != null ? (map['distance'] as num).toDouble() : null,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'phone': phone,
      'isOpen': isOpen,
      'distance': distance,
      'imageUrl': imageUrl,
    };
  }

  ServiceProviderModel copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    String? phone,
    bool? isOpen,
    double? distance,
    String? imageUrl,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ServiceProviderModel(id: $id, name: $name, type: $type)';
}
