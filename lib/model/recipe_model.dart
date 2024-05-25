

class RecipeModel {
  final int id;
  final String name;
  final String description;
  final String ingredients;
  final String instructions;
  final int preparationTime;
  final bool approval;
  final int userId;

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.approval,
    required this.userId,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        ingredients: json['ingredients'] ?? '',
        instructions: json['instructions'] ?? '',
        preparationTime: json['preparationTime'] ?? 0,
        approval: json['isApproved'] ?? false,
        userId: json['userId'] ?? -1 // Usando -1 o cualquier otro valor predeterminado apropiado
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'preparationTime': preparationTime,
      'isApproved': approval,
      'userId': userId  // Asegúrate de incluir esto si es necesario
    };
  }

  @override
  String toString() {
    return 'RecipeModel{id: $id, name: $name, description: $description, ingredients: $ingredients, instructions: $instructions, preparationTime: $preparationTime, approval: $approval, userId: $userId}';
  }
}
