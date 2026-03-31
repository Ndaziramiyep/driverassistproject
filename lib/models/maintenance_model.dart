import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel {
  final String id;
  final String vehicleId;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int? dueMileage;
  final String priority;
  final bool isCompleted;
  final int? notificationId;
  final DateTime createdAt;

  MaintenanceModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.dueMileage,
    required this.priority,
    required this.isCompleted,
    this.notificationId,
    required this.createdAt,
  });

  factory MaintenanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceModel(
      id: doc.id,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      dueMileage: data['dueMileage'] as int?,
      priority: data['priority'] as String,
      isCompleted: data['isCompleted'] as bool,
      notificationId: data['notificationId'] as int?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory MaintenanceModel.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceModel(
      id: id,
      vehicleId: map['vehicleId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['dueDate'] != null
          ? map['dueDate'] is Timestamp
              ? (map['dueDate'] as Timestamp).toDate()
              : DateTime.parse(map['dueDate'] as String)
          : null,
      dueMileage: map['dueMileage'] as int?,
      priority: map['priority'] as String,
      isCompleted: map['isCompleted'] as bool,
      notificationId: map['notificationId'] as int?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'dueMileage': dueMileage,
      'priority': priority,
      'isCompleted': isCompleted,
      'notificationId': notificationId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MaintenanceModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? dueMileage,
    String? priority,
    bool? isCompleted,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return MaintenanceModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue {
    if (isCompleted) return false;
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MaintenanceModel(id: $id, title: $title, priority: $priority)';
}
