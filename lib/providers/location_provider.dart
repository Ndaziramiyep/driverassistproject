import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driverassist/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  String _currentAddress = 'Getting location...';
  bool _isLoading = false;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSub;

  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  bool get isTracking => _isTracking;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        _currentPosition = pos;
        _currentAddress = await _locationService.getAddressFromCoordinates(
            pos.latitude, pos.longitude);
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    notifyListeners();
    _positionSub = _locationService.getPositionStream().listen((pos) async {
      _currentPosition = pos;
      _currentAddress = await _locationService.getAddressFromCoordinates(
          pos.latitude, pos.longitude);
      notifyListeners();
    });
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _isTracking = false;
    notifyListeners();
  }

  Future<double?> distanceTo(double lat, double lng) async {
    if (_currentPosition == null) return null;
    return _locationService.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
