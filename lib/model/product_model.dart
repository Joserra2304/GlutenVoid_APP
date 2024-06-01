class ProductModel {
  final String name;
  final String company;
  final String description;
  final String imageUrl;
  final bool hasGluten;
  final String? barcode;

  ProductModel({
    required this.name,
    required this.company,
    required this.description,
    required this.imageUrl,
    required this.hasGluten,
    this.barcode,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    bool glutenFree = false;
    if (json['labels_tags'] != null && json['labels_tags'] is List) {
      glutenFree = (json['labels_tags'] as List).contains('en:no-gluten');
    }

    List<String> glutenAllergens = [
      'gluten', 'wheat', 'trigo', 'barley','cebada', 'rye','centeno', 'triticale'
    ];

    bool containsGlutenAllergens = false;
    if (json['allergens'] != null && json['allergens'] is String) {
      for (String allergen in glutenAllergens) {
        if ((json['allergens'] as String).toLowerCase().contains(allergen)) {
          containsGlutenAllergens = true;
          break;
        }
      }
    }

    bool containsGlutenIngredients = false;
    if (json['ingredients_text'] != null && json['ingredients_text'] is String) {
      for (String allergen in glutenAllergens) {
        if ((json['ingredients_text'] as String).toLowerCase().contains(allergen)) {
          containsGlutenIngredients = true;
          break;
        }
      }
    }

    return ProductModel(
      imageUrl: json["image_url"] ?? 'https://via.placeholder.com/150',
      name: json['product_name'] ?? 'Nombre no disponible',
      company: json['brands'] ?? 'Marca no disponible',
      description: json['ingredients_text'] ?? 'Descripción no disponible',
      hasGluten: !glutenFree && (containsGlutenAllergens || containsGlutenIngredients),
      barcode: json['code'] ?? '',
    );
  }
}
