import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  final StorageService _storageService = StorageService();

  AuthProvider() {
    _checkAuthStatus();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);

    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _storageService.getUser();
        _token = await _storageService.getToken();
        _isAuthenticated = true;
        _setError(null);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);

    try {
      final response = await ApiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response['success']) {
        final userData = response['data'];
        _user = User.fromJson(userData['user']);
        _token = userData['token'];
        _isAuthenticated = true;

        // Save to storage
        await _storageService.saveUser(_user!);
        await _storageService.saveToken(_token!);

        _setError(null);
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);

    try {
      final response = await ApiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response['success']) {
        final userData = response['data'];
        _user = User.fromJson(userData['user']);
        _token = userData['token'];
        _isAuthenticated = true;

        // Save to storage
        await _storageService.saveUser(_user!);
        await _storageService.saveToken(_token!);

        _setError(null);
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear storage
      await _storageService.clearAll();

      // Reset state
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    if (!_isAuthenticated || _token == null) {
      throw Exception('Not authenticated');
    }

    _setLoading(true);

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await ApiService.put('/user/profile',
        token: _token,
        data: data,
      );

      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        await _storageService.saveUser(_user!);
        _setError(null);
      } else {
        throw Exception(response['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    if (!_isAuthenticated || _token == null) return;

    try {
      final response = await ApiService.get('/user/profile', token: _token);

      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        await _storageService.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for refresh
      print('Failed to refresh user: $e');
    }
  }
}