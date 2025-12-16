import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easypharma_flutter/core/constants/app_constants.dart';

class WebProxyService {
  static const String _backendUrl = 'http://localhost:8080';
  
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.accessTokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      print('🌐 Adding Bearer token to headers');
      headers['Authorization'] = 'Bearer $token';
    } else {
      print('⚠️ No token available for request');
    }
    
    return headers;
  }
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = '$_backendUrl$endpoint';
      print('🌐 Web Proxy GET: $url');
      
      final headers = await _getHeaders();
      print('🌐 Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Proxy GET Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    try {
      final url = '$_backendUrl$endpoint';
      print('🌐 Web Proxy POST: $url');
      
      final headers = await _getHeaders();
      print('🌐 Headers: $headers');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Proxy POST Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      final url = '$_backendUrl$endpoint';
      print('🌐 Web Proxy PUT: $url');
      print('🌐 Web Proxy PUT Data: $data');
      
      final headers = await _getHeaders();
      print('🌐 Headers: $headers');
      print('🌐 Token present: ${headers.containsKey('Authorization')}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Proxy PUT Error: $e');
      rethrow;
    }
  }
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('📡 Proxy Response Status: ${response.statusCode}');
    print('📡 Proxy Response Headers: ${response.headers}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        final decoded = jsonDecode(response.body);
        print('📡 Proxy Response Body: $decoded');
        return decoded;
      } catch (e) {
        print('❌ JSON Decode Error: $e');
        return {'success': false, 'message': 'Invalid JSON response'};
      }
    } else {
      print('❌ Proxy Error: HTTP ${response.statusCode}');
      print('❌ Response Body: ${response.body}');
      
      try {
        final errorJson = jsonDecode(response.body);
        throw Exception(errorJson['message'] ?? 'HTTP ${response.statusCode}');
      } catch (_) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    }
  }
  
  // Méthode de test (temporairement publique)
  static Future<void> testAuth() async {
    try {
      print('=== TESTING AUTH TOKEN ===');
      
      final token = await _getToken();
      print('Token from storage: $token');
      
      print('=== TESTING GET /auth/me ===');
      final response = await get('/api/v1/auth/me');
      print('GET response: $response');
    } catch (e) {
      print('Test error: $e');
    }
  }
}