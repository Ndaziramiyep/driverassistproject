import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driverassist/utils/constants.dart';

class BiometricProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  BiometricProvider() {
    _init();
  }

  Future<void> _init() async {
    await checkBiometricAvailability();
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    notifyListeners();
  }

  Future<void> checkBiometricAvailability() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      _isBiometricAvailable = false;
    }
    notifyListeners();
  }

  Future<bool> authenticate() async {
    if (!_isBiometricAvailable) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in to DriverAssist',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometric(String email, String password) async {
    await _secureStorage.write(key: 'bio_email', value: email);
    await _secureStorage.write(key: 'bio_password', value: password);
    _isBiometricEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.biometricEnabledKey, true);
    notifyListeners();
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: 'bio_email');
    await _secureStorage.delete(key: 'bio_password');
    _isBiometricEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.biometricEnabledKey, false);
    notifyListeners();
  }

  Future<Map<String, String?>> getBiometricCredentials() async {
    return {
      'email': await _secureStorage.read(key: 'bio_email'),
      'password': await _secureStorage.read(key: 'bio_password'),
    };
  }
}
