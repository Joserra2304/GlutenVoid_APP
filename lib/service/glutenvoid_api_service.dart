import 'package:http/http.dart' as http;

class GlutenVoidApi {
  //final String baseUrl = 'http://10.0.2.2:8080';
  //final String baseUrl = 'http://192.168.1.176:8080';
  //final String baseUrl = 'http://192.168.0.37:8080';
  final String baseUrl = 'https://glutenvoid-api-0697772007f6.herokuapp.com';

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(uri);
  }

  Future<http.Response> post(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: data,
    );
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.delete(uri);
  }

  Future<http.Response> put(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: data,
    );
  }

  Future<http.Response> patch(String path, dynamic data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: data,
    );
  }

  // Método para probar la conexión
  Future<void> testConnection() async {
    try {
      final response = await get('/users');  // Asumiendo que el endpoint es '/test'
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
