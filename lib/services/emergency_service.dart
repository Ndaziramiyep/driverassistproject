import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverassist/models/emergency_request_model.dart';
import 'package:driverassist/utils/constants.dart';

class EmergencyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<EmergencyRequestModel> createEmergencyRequest(
    String userId,
    String type,
    double lat,
    double lng,
    String? address,
  ) async {
    final request = EmergencyRequestModel(
      id: '',
      userId: userId,
      type: type,
      status: 'pending',
      latitude: lat,
      longitude: lng,
      address: address,
      createdAt: DateTime.now(),
    );
    final ref = await _db
        .collection(AppConstants.emergencyCollection)
        .add(request.toMap());
    final doc = await ref.get();
    return EmergencyRequestModel.fromFirestore(doc);
  }

  Future<void> resolveEmergencyRequest(String requestId) async {
    await _db.collection(AppConstants.emergencyCollection).doc(requestId).update({
      'status': 'resolved',
      'resolvedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<EmergencyRequestModel>> userEmergencyStream(String userId) {
    return _db
        .collection(AppConstants.emergencyCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => EmergencyRequestModel.fromFirestore(d)).toList());
  }
}
