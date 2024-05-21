

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/recipe_model.dart';
import 'glutenvoid_api_service.dart';

class RecipeService {
  final GlutenVoidApi glutenVoidApi;

  // Private constructor
  RecipeService._privateConstructor(this.glutenVoidApi);

  // Static instance
  static RecipeService? _instance;

  // Factory constructor
  factory RecipeService(GlutenVoidApi api) {
    _instance ??= RecipeService._privateConstructor(api);
    return _instance!;
  }

  Future<List<RecipeModel>> fetchRecipesByApproval(bool isApproved) async {
    var response = await glutenVoidApi.get('/recipes?isApproved=$isApproved');
    if (response.statusCode == 200) {
      List<dynamic> recipesJson = jsonDecode(response.body);
      return recipesJson.map((json) => RecipeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<RecipeModel> getRecipeById(int id) async {
    final response = await glutenVoidApi.get('/recipes/$id');
    if (response.statusCode == 200) {
      return RecipeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<bool> addRecipe(RecipeModel recipe) async {
    var response = await glutenVoidApi.post(
        '/recipes',
        jsonEncode(recipe.toJson())
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to add recipe: ${response.statusCode} ${response.body}");
      return false;
    }
  }

  Future<bool> updateRecipe(int recipeId, Map<String, dynamic> updates) async {
    var response = await glutenVoidApi.patch('/recipes/$recipeId', jsonEncode(updates));
    return response.statusCode == 200;
  }

  Future<bool> approveRecipe(int recipeId) async {
    final response = await glutenVoidApi.patch('/recipes/$recipeId', jsonEncode({'approval': true}));
    return response.statusCode == 200;
  }

  Future<bool> deleteRecipe(int recipeId) async {
    var response = await glutenVoidApi.delete('/recipes/$recipeId');
    return response.statusCode == 200;
  }
}

