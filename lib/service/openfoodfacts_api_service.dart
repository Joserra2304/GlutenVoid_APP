import 'package:http/http.dart' as http;

class OpenFoodFactsApi {
  final String baseUrl = 'https://es.openfoodfacts.org';

  Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.get(url);
  }
}