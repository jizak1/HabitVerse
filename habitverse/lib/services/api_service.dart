import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3002/api';

  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data, String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data, String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error']?['message'] ?? 'Request failed');
    }
  }
}
