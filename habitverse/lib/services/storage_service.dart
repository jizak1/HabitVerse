import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods (for sensitive data like tokens)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: AppConstants.userKey, value: userJson);
  }

  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  // Shared Preferences Methods (for app settings)
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString(AppConstants.themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs?.getString(AppConstants.themeKey) ?? 'system';
  }

  Future<void> saveNotificationSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await _prefs?.setBool('notifications_enabled', enabled);
    await _prefs?.setInt('notification_hour', hour);
    await _prefs?.setInt('notification_minute', minute);
  }

  Map<String, dynamic> getNotificationSettings() {
    return {
      'enabled': _prefs?.getBool('notifications_enabled') ?? true,
      'hour': _prefs?.getInt('notification_hour') ?? 9,
      'minute': _prefs?.getInt('notification_minute') ?? 0,
    };
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _prefs?.setBool('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  Future<void> saveLastSyncTime(DateTime time) async {
    await _prefs?.setString('last_sync_time', time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeString = _prefs?.getString('last_sync_time');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  // Cache Methods
  Future<void> cacheHabits(List<Map<String, dynamic>> habits) async {
    final habitsJson = jsonEncode(habits);
    await _prefs?.setString('cached_habits', habitsJson);
  }

  List<Map<String, dynamic>>? getCachedHabits() {
    final habitsJson = _prefs?.getString('cached_habits');
    if (habitsJson != null) {
      final List<dynamic> habitsList = jsonDecode(habitsJson);
      return habitsList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheStats(Map<String, dynamic> stats) async {
    final statsJson = jsonEncode(stats);
    await _prefs?.setString('cached_stats', statsJson);
  }

  Map<String, dynamic>? getCachedStats() {
    final statsJson = _prefs?.getString('cached_stats');
    if (statsJson != null) {
      return jsonDecode(statsJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // App state methods
  Future<void> saveAppState(Map<String, dynamic> state) async {
    final stateJson = jsonEncode(state);
    await _prefs?.setString('app_state', stateJson);
  }

  Map<String, dynamic>? getAppState() {
    final stateJson = _prefs?.getString('app_state');
    if (stateJson != null) {
      return jsonDecode(stateJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
