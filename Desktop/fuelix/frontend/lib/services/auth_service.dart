import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<String?> getToken() async {
    // For MVP/Mock, return a static token or fetch from storage
    // In a real app, this would get the JWT from secure storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? "mock_token_for_dev";
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  Future<bool> isLoggedIn() async {
     final token = await getToken();
     return token != null;
  }
}
