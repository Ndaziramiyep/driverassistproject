import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverassist/models/saved_location_model.dart';
import 'package:driverassist/utils/constants.dart';

class SavedLocationsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<SavedLocationModel> _savedLocations = [];
  bool _isLoading = false;
  String? _userId;

  List<SavedLocationModel> get savedLocations => _savedLocations;
  bool get isLoading => _isLoading;

  SavedLocationModel? get homeLocation {
    for (final location in _savedLocations) {
      if (location.type == AppConstants.locationHome) return location;
    }
    return null;
  }

  SavedLocationModel? get workLocation {
    for (final location in _savedLocations) {
      if (location.type == AppConstants.locationWork) return location;
    }
    return null;
  }

  Future<void> loadLocations(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    try {
      final snap =
          await _db
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .collection('saved_locations')
              .orderBy('createdAt', descending: false)
              .get();
      _savedLocations =
          snap.docs.map((d) => SavedLocationModel.fromFirestore(d)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLocation(SavedLocationModel location) async {
    if (_userId == null) return;
    final ref = await _db
        .collection(AppConstants.usersCollection)
        .doc(_userId)
        .collection('saved_locations')
        .add(location.toMap());
    final doc = await ref.get();
    _savedLocations.add(SavedLocationModel.fromFirestore(doc));
    notifyListeners();
  }

  Future<void> updateLocation(SavedLocationModel location) async {
    if (_userId == null) return;
    await _db
        .collection(AppConstants.usersCollection)
        .doc(_userId)
        .collection('saved_locations')
        .doc(location.id)
        .update(location.toMap());
    final idx = _savedLocations.indexWhere((l) => l.id == location.id);
    if (idx != -1) {
      _savedLocations[idx] = location;
      notifyListeners();
    }
  }

  Future<void> deleteLocation(String id) async {
    if (_userId == null) return;
    await _db
        .collection(AppConstants.usersCollection)
        .doc(_userId)
        .collection('saved_locations')
        .doc(id)
        .delete();
    _savedLocations.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  List<SavedLocationModel> getLocationsByType(String type) {
    return _savedLocations.where((l) => l.type == type).toList();
  }
}
