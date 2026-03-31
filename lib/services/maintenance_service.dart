import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverassist/models/maintenance_model.dart';
import 'package:driverassist/services/notification_service.dart';
import 'package:driverassist/utils/constants.dart';

class MaintenanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<List<MaintenanceModel>> getMaintenanceForVehicle(String vehicleId) async {
    final snapshot = await _db
        .collection(AppConstants.maintenanceCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => MaintenanceModel.fromFirestore(d)).toList();
  }

  Stream<List<MaintenanceModel>> maintenanceStream(String vehicleId) {
    return _db
        .collection(AppConstants.maintenanceCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => MaintenanceModel.fromFirestore(d)).toList());
  }

  Stream<List<MaintenanceModel>> userMaintenanceStream(String userId) {
    return _db
        .collection(AppConstants.maintenanceCollection)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MaintenanceModel.fromFirestore(d)).toList());
  }

  Future<MaintenanceModel> addMaintenance(MaintenanceModel maintenance) async {
    final ref = await _db
        .collection(AppConstants.maintenanceCollection)
        .add(maintenance.toMap());
    if (maintenance.dueDate != null && !maintenance.isCompleted) {
      await _notificationService.scheduleMaintenanceReminder(
        ref.hashCode,
        'Maintenance Due: ${maintenance.title}',
        maintenance.description ?? 'Your vehicle maintenance is due',
        maintenance.dueDate!,
      );
    }
    final doc = await ref.get();
    return MaintenanceModel.fromFirestore(doc);
  }

  Future<void> updateMaintenance(MaintenanceModel maintenance) async {
    await _db
        .collection(AppConstants.maintenanceCollection)
        .doc(maintenance.id)
        .update(maintenance.toMap());
  }

  Future<void> deleteMaintenance(String maintenanceId) async {
    await _db
        .collection(AppConstants.maintenanceCollection)
        .doc(maintenanceId)
        .delete();
  }

  Future<void> completeMaintenance(String maintenanceId) async {
    await _db
        .collection(AppConstants.maintenanceCollection)
        .doc(maintenanceId)
        .update({'isCompleted': true});
  }

  Future<List<MaintenanceModel>> getOverdueMaintenance(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _db
        .collection(AppConstants.maintenanceCollection)
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .where('dueDate', isLessThan: now)
        .get();
    return snapshot.docs.map((d) => MaintenanceModel.fromFirestore(d)).toList();
  }
}
