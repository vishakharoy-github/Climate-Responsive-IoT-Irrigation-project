import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<bool> signIn(String email, String password) async {
    // Mock authentication
    await Future.delayed(Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString(_userIdKey, 'user_${email.hashCode}');
      return true;
    }
    throw Exception('Invalid credentials');
  }

  Future<bool> signUp(String email, String password) async {
    // Mock registration
    await Future.delayed(Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      return signIn(email, password);
    }
    throw Exception('Registration failed');
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
