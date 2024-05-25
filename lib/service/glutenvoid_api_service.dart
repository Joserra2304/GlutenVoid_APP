import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GlutenVoidApi {
  final String baseUrl = 'https://glutenvoid-api-0697772007f6.herokuapp.com';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.get(uri, headers: headers);
  }

  Future<http.Response> post(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.post(
      uri,
      headers: headers,
      body: data,
    );
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.delete(uri, headers: headers);
  }

  Future<http.Response> put(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.put(
      uri,
      headers: headers,
      body: data,
    );
  }

  Future<http.Response> patch(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return await http.patch(
      uri,
      headers: headers,
      body: data,
    );
  }

  // Método para probar la conexión
  Future<void> testConnection() async {
    try {
      final response = await get('/users');
      if (response.statusCode == 200) {
        print("Conexión exitosa: ${response.body}");
      } else {
        print("Falló la conexión: ${response.statusCode}");
      }
    } catch (e) {
      print("Error durante la prueba de conexión: $e");
    }
  }
}
