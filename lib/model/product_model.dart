import '../service/openfoodfacts_api_service.dart';

class ProductModel {
  final String name;
  final String company;
  final String description;
  final String imageUrl;
  final bool hasGluten;

  ProductModel({
    required this.name,
    required this.company,
    required this.description,
    required this.imageUrl,
    required this.hasGluten,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json){
    return ProductModel(
      imageUrl: json["image_url"] ?? 'https://via.placeholder.com/150',
      name: json['product_name'] ?? 'Nombre no disponible',
      company: json['brands'] ?? 'Marca no disponible',
      description:json['ingredients_text'] ?? 'Descripción no disponible',
      hasGluten: json['has_gluten'] ?? false,
    );
  }
}
