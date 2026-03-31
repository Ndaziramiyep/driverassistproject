import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverassist/models/vehicle_model.dart';
import 'package:driverassist/utils/constants.dart';

class VehicleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.vehiclesCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => VehicleModel.fromFirestore(doc)).toList();
  }

  Stream<List<VehicleModel>> vehicleStream(String userId) {
    return _db
        .collection(AppConstants.vehiclesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => VehicleModel.fromFirestore(d)).toList());
  }

  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    final ref = await _db
        .collection(AppConstants.vehiclesCollection)
        .add(vehicle.toMap());
    final doc = await ref.get();
    return VehicleModel.fromFirestore(doc);
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _db
        .collection(AppConstants.vehiclesCollection)
        .doc(vehicle.id)
        .update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _db.collection(AppConstants.vehiclesCollection).doc(vehicleId).delete();
  }

  Future<void> updateMileage(String vehicleId, int newMileage) async {
    await _db
        .collection(AppConstants.vehiclesCollection)
        .doc(vehicleId)
        .update({'currentMileage': newMileage});
  }
}
