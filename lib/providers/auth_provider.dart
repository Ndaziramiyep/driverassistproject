import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driverassist/models/user_model.dart';
import 'package:driverassist/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          _currentUser = await _authService.getCurrentUser();
        } catch (_) {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signInWithEmailPassword(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signUpWithEmailPassword(
          email, password, displayName);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signInWithGoogle();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    _setLoading(true);
    try {
      await _authService.updateProfile(
          displayName: displayName, photoUrl: photoUrl);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          photoUrl: photoUrl ?? _currentUser!.photoUrl,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('user-not-found')) return 'No account found with this email.';
      if (msg.contains('wrong-password')) return 'Incorrect password.';
      if (msg.contains('email-already-in-use')) return 'An account already exists with this email.';
      if (msg.contains('weak-password')) return 'Password is too weak.';
      if (msg.contains('invalid-email')) return 'Invalid email address.';
      if (msg.contains('network-request-failed')) return 'Network error. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
