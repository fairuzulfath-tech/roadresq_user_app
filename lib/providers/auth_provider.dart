import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get verificationId => _verificationId;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _setLoading(true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      final id = await _authService.signInWithPhone(phone);
      _verificationId = id;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _error = 'No verification in progress.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.verifyOTP(_verificationId!, otp);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      }
      _error = 'Verification failed.';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _isLoggedIn = false;
    _verificationId = null;
    _setLoading(false);
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? photoUrl,
    List<Map<String, dynamic>>? vehicles,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final updated = await _authService.updateProfile(
        userId: _currentUser?.id ?? '',
        name: name,
        email: email,
        photoUrl: photoUrl,
        vehicles: vehicles,
      );
      _currentUser = updated;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
