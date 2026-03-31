import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final String? color;
  final String fuelType;
  final int currentMileage;
  final String? imageUrl;
  final DateTime? lastServiceDate;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.color,
    required this.fuelType,
    required this.currentMileage,
    this.imageUrl,
    this.lastServiceDate,
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      userId: data['userId'] as String,
      make: data['make'] as String,
      model: data['model'] as String,
      year: data['year'] as int,
      plateNumber: data['plateNumber'] as String,
      color: data['color'] as String?,
      fuelType: data['fuelType'] as String,
      currentMileage: data['currentMileage'] as int,
      imageUrl: data['imageUrl'] as String?,
      lastServiceDate: data['lastServiceDate'] != null
          ? (data['lastServiceDate'] as Timestamp).toDate()
          : null,
    );
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map, String id) {
    return VehicleModel(
      id: id,
      userId: map['userId'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      plateNumber: map['plateNumber'] as String,
      color: map['color'] as String?,
      fuelType: map['fuelType'] as String,
      currentMileage: map['currentMileage'] as int,
      imageUrl: map['imageUrl'] as String?,
      lastServiceDate: map['lastServiceDate'] != null
          ? map['lastServiceDate'] is Timestamp
              ? (map['lastServiceDate'] as Timestamp).toDate()
              : DateTime.parse(map['lastServiceDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
      'color': color,
      'fuelType': fuelType,
      'currentMileage': currentMileage,
      'imageUrl': imageUrl,
      'lastServiceDate':
          lastServiceDate != null ? Timestamp.fromDate(lastServiceDate!) : null,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? plateNumber,
    String? color,
    String? fuelType,
    int? currentMileage,
    String? imageUrl,
    DateTime? lastServiceDate,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      currentMileage: currentMileage ?? this.currentMileage,
      imageUrl: imageUrl ?? this.imageUrl,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VehicleModel(id: $id, make: $make, model: $model, year: $year)';
}
