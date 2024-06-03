import '../model/product_model.dart';
import '../service/product_service.dart';

class ProductController {
  final ProductService productService = ProductService();
  List<ProductModel> products = [];
  bool isLoading = false;
  bool isMoreAvailable = true;
  int currentPage = 1;
  String currentFilter = "";
  String filterValue = "";
  bool isSearchToolVisible = false;

  Function? updateView;

  // Obtener todos los productos sin gluten
  Future<List<ProductModel>> fetchGlutenFreeProducts({int page = 1, int limit = 21}) async {
    try {
      return await productService.fetchGlutenFreeProducts(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener productos por supermercado
  Future<List<ProductModel>> fetchProductsByStore(String store, {int page = 1, int limit = 20}) async{
    try {
      return await productService.fetchProductsByStore(store, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener productos por categoría
  Future<List<ProductModel>> fetchProductsByCategory(String category, {int page = 1, int limit = 20}) async{
    try {
      return await productService.fetchProductsByCategory(category, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener el código de barras del producto (es como el id)
  Future<ProductModel?> fetchProductByBarcode(String barcode) async{
    try {
      return await productService.fetchProductByBarcode(barcode);
    } catch (e) {
      rethrow;
    }
  }
}
