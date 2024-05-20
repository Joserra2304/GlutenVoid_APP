import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/service/glutenvoid_api_service.dart';
import '../model/product_model.dart';
import '../service/openfoodfacts_api_service.dart';
import '../service/product_service.dart';

class ProductController {
  final ProductService productService;
  List<ProductModel> products = [];
  bool isLoading = false;
  bool isMoreAvailable = true;
  int currentPage = 1;
  String currentFilter = "";
  String filterValue = "";
  bool isSearchToolVisible = false;  // Para controlar la visibilidad de la barra de búsqueda

  // Define updateView como una función que puede ser sobrescrita.
  Function? updateView;

  ProductController(this.productService);

  //Obtener todos lo productos sin gluten
  Future<List<ProductModel>> fetchGlutenFreeProducts({int page = 1, int limit = 20}) async {
    try {
      return await productService.fetchGlutenFreeProducts(page: page, limit: limit);
    } catch (e) {
      // Manejar errores adecuadamente, por ejemplo, mostrando un mensaje en la interfaz
      rethrow;
    }
  }

  //Obtener productos por supermercado
  Future<List<ProductModel>> fetchProductsByStore(String store, {int page = 1, int limit = 20}) async{
    try {
      return await productService.fetchProductsByStore(store, page: page, limit: limit);
    } catch (e) {
      // Manejar errores adecuadamente, por ejemplo, mostrando un mensaje en la interfaz
      rethrow;
    }
  }

  //Obtener productos por categoria
  Future<List<ProductModel>> fetchProductsByCategory(String category, {int page = 1, int limit = 20}) async{
    try {
      return await productService.fetchProductsByCategory(category, page: page, limit: limit);
    } catch (e) {
      // Manejar errores adecuadamente, por ejemplo, mostrando un mensaje en la interfaz
      rethrow;
    }
  }

  //Obtener el código de barras del producto (es como el id)
  Future<ProductModel?> fetchProductByBarcode(String barcode) async{
    try {
      return await productService.fetchProductByBarcode(barcode);
    } catch (e) {
      // Manejar errores adecuadamente, por ejemplo, mostrando un mensaje en la interfaz
      rethrow;
    }
  }
}