import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  // Simulated verification ID for OTP flow
  String? _pendingPhone;

  Future<String> signInWithPhone(String phone) async {
    // Simulate network call delay
    await Future.delayed(const Duration(seconds: 1));
    _pendingPhone = phone;
    // Return a mock verification ID
    return 'mock_verification_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<UserModel?> verifyOTP(String verificationId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Accept any 6-digit OTP for mock
    if (otp.length == 6) {
      final user = UserModel.mock.copyWith(phone: _pendingPhone ?? '+91 9876543210');
      await _saveAuthState(user);
      return user;
    }
    throw Exception('Invalid OTP. Please try again.');
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefUserPhone);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    // Return mock user if logged in
    return UserModel.mock;
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
    List<Map<String, dynamic>>? vehicles,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserName, name);
    return UserModel.mock.copyWith(
      name: name,
      email: email,
      photoUrl: photoUrl,
      vehicles: vehicles,
    );
  }

  Future<void> _saveAuthState(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefUserId, user.id);
    await prefs.setString(AppConstants.prefUserName, user.name);
    await prefs.setString(AppConstants.prefUserPhone, user.phone);
  }

  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }
}
