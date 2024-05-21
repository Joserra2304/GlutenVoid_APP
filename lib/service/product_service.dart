import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/product_model.dart';
import 'openfoodfacts_api_service.dart';

class ProductService {
  static final ProductService _singleton = ProductService._internal();
  final OpenFoodFactsApi openFoodFactsApi;

  Map<String, List<ProductModel>> _cachedProducts = {};

  ProductService._internal() : openFoodFactsApi = OpenFoodFactsApi();

  factory ProductService() {
    return _singleton;
  }

  // Búsqueda de productos sin gluten
  Future<List<ProductModel>> fetchGlutenFreeProducts({int page = 1, int limit = 21}) async {
    final key = 'gluten_free_page_$page';
    if (_cachedProducts.containsKey(key)) {
      return _cachedProducts[key]!;
    }

    final response = await openFoodFactsApi.get('/etiqueta/sin-gluten.json?page=$page&limit=$limit');
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var productsJson = jsonResponse['products'] as List<dynamic>;
      List<ProductModel> newProducts = productsJson.map((productJson) => ProductModel.fromJson(productJson)).toList();
      _cachedProducts[key] = newProducts;
      return newProducts;
    } else {
      throw Exception('Failed to load products from API: ${response.statusCode}');
    }
  }

  // Búsquedas de productos por supermercado
  Future<List<ProductModel>> fetchProductsByStore(String store, {int page = 1, int limit = 20}) async {
    final String cacheKey = 'store_${store}_page_$page';

    if (_cachedProducts.containsKey(cacheKey)) {
      return _cachedProducts[cacheKey]!;
    }
    final response = await openFoodFactsApi.get('/api/v2/search?stores_tags=$store&page=$page&limit=$limit');

    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      var productsJson = jsonResponse['products'] as List;
      return productsJson.map((productsJson) => ProductModel.fromJson(productsJson)).toList();

    } else {
      throw Exception('Error al cargar los productos de la API: ${response.statusCode}');
    }
  }

  // Búsquedas de productos por categoría
  Future<List<ProductModel>> fetchProductsByCategory(String category, {int page = 1, int limit = 20}) async {
    final String cacheKey = 'category_${category}_page_$page';

    if (_cachedProducts.containsKey(cacheKey)) {
      return _cachedProducts[cacheKey]!;
    }

    final response = await openFoodFactsApi.get('/api/v2/search?categories_tags=$category&page=$page&limit=$limit');

    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      var productsJson = jsonResponse['products'] as List;
      return productsJson.map((productsJson) => ProductModel.fromJson(productsJson)).toList();
    } else {
      throw Exception('Error al cargar los productos de la API: ${response.statusCode}');
    }
  }

  // Escanear producto
  Future<ProductModel?> fetchProductByBarcode(String barcode) async {
    final response = await openFoodFactsApi.get('/api/v3/product/$barcode.json');
    if (response.statusCode == 200 && json.decode(response.body)['product'] != null) {
      return ProductModel.fromJson(json.decode(response.body)['product']);
    } else {
      print('Error fetching product details: ${response.statusCode}');
      return null;
    }
  }
}
