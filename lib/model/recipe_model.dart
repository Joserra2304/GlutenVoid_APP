

class RecipeModel {
  final int id;
  final String name;
  final String description;
  final String ingredients;
  final String instructions;
  final int preparationTime;
  final bool approval;
  final int userId;
  final String username;

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.approval,
    required this.userId,
    required this.username,
});

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        ingredients: json['ingredients'] ?? '',
        instructions: json['instructions'] ?? '',
        preparationTime: json['preparationTime'] ?? 0,
        approval: json['approvedRecipe'] ?? false,
        userId: json['userId'] ?? -1,
        username: json['username'] ?? '',
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
      'approvedRecipe': approval,
      'userId': userId,
      'username': username,
    };
  }

  @override
  String toString() {
    return 'RecipeModel{id: $id, name: $name, description: $description,'
        ' ingredients: $ingredients, instructions: $instructions,'
        ' preparationTime: $preparationTime, approval: $approval, userId: $userId}';
  }
}
