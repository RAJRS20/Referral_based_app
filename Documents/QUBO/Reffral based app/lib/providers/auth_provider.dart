import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Generate referral code
  String _generateReferralCode(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = name.replaceAll(' ', '').toUpperCase();
    return '$cleanName${timestamp.toString().substring(timestamp.toString().length - 4)}';
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? referredByCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      final user = UserModel(
        id: const Uuid().v4(),
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        referralCode: _generateReferralCode(name),
        referredBy: referredByCode,
      );

      _currentUser = user;
      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setBool('isAuthenticated', true);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo, create a dummy user
      final user = UserModel(
        id: const Uuid().v4(),
        name: 'Demo User',
        email: emailOrPhone.contains('@') ? emailOrPhone : 'demo@example.com',
        phone: emailOrPhone.contains('@') ? '1234567890' : emailOrPhone,
        createdAt: DateTime.now(),
        referralCode: _generateReferralCode('Demo User'),
      );

      _currentUser = user;
      _isAuthenticated = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setBool('isAuthenticated', true);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool('isAuthenticated') ?? false;
      
      if (isAuth) {
        final userJson = prefs.getString('user');
        if (userJson != null) {
          _currentUser = UserModel.fromJson(jsonDecode(userJson));
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      profileImage: profileImage,
    );

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_currentUser!.toJson()));

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
