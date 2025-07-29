import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final StorageService _storageService = StorageService();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return await _storageService.getToken();
  }

  Future<void> loadHabits() async {
    _setLoading(true);

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.get('/habits', token: token);
      if (response['success']) {
        _habits = (response['data']['habits'] as List)
            .map((json) => Habit.fromJson(json))
            .toList();
        _setError(null);
      } else {
        throw Exception(response['message'] ?? 'Failed to load habits');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createHabit(Habit habit) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.post('/habits',
        token: token,
        data: {
          'title': habit.title,
          'description': habit.description,
          'category': habit.category,
          'icon': habit.icon,
          'color': habit.color,
          'is_public': habit.isPublic,
        }
      );

      if (response['success']) {
        final newHabit = Habit.fromJson(response['data']['habit']);
        _habits.add(newHabit);
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to create habit');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.put('/habits/${habit.id}',
        token: token,
        data: {
          'title': habit.title,
          'description': habit.description,
          'category': habit.category,
          'icon': habit.icon,
          'color': habit.color,
          'is_public': habit.isPublic,
        }
      );

      if (response['success']) {
        final updatedHabit = Habit.fromJson(response['data']['habit']);
        final index = _habits.indexWhere((h) => h.id == habit.id);
        if (index != -1) {
          _habits[index] = updatedHabit;
          notifyListeners();
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update habit');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.delete('/habits/$habitId', token: token);

      if (response['success']) {
        _habits.removeWhere((habit) => habit.id == habitId);
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to delete habit');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> checkHabit(String habitId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.post('/habits/check/$habitId', token: token);

      if (response['success']) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to check habit');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.get('/habits/$habitId/stats', token: token);

      if (response['success']) {
        return response['data']['stats'];
      } else {
        throw Exception(response['message'] ?? 'Failed to get habit stats');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.get('/habits/stats', token: token);

      if (response['success']) {
        return response['data']['stats'];
      } else {
        throw Exception(response['message'] ?? 'Failed to get overall stats');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}