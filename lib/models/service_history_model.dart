import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistoryModel {
  final String id;
  final String vehicleId;
  final String userId;
  final String serviceType;
  final String? description;
  final double cost;
  final DateTime date;
  final int? mileage;
  final String? providerName;

  ServiceHistoryModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.serviceType,
    this.description,
    required this.cost,
    required this.date,
    this.mileage,
    this.providerName,
  });

  factory ServiceHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceHistoryModel(
      id: doc.id,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      serviceType: data['serviceType'] as String,
      description: data['description'] as String?,
      cost: (data['cost'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      mileage: data['mileage'] as int?,
      providerName: data['providerName'] as String?,
    );
  }

  factory ServiceHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceHistoryModel(
      id: id,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      serviceType: map['serviceType'] as String,
      description: map['description'] as String?,
      cost: (map['cost'] as num).toDouble(),
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date'] as String),
      mileage: map['mileage'] as int?,
      providerName: map['providerName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'serviceType': serviceType,
      'description': description,
      'cost': cost,
      'date': Timestamp.fromDate(date),
      'mileage': mileage,
      'providerName': providerName,
    };
  }

  ServiceHistoryModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? serviceType,
    String? description,
    double? cost,
    DateTime? date,
    int? mileage,
    String? providerName,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      providerName: providerName ?? this.providerName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceHistoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ServiceHistoryModel(id: $id, serviceType: $serviceType, cost: $cost)';
}
