import '../model/recipe_model.dart';
import '../service/recipe_service.dart';

class RecipeController {
  final RecipeService recipeService;
  List<RecipeModel> recipes = [];

  RecipeController(this.recipeService);

  Future<List<RecipeModel>> fetchApprovedRecipes() async {
    return await recipeService.fetchApprovedRecipes();
  }

  Future<List<RecipeModel>> fetchPendingRecipes() async {
    return await recipeService.fetchRecipesByApproval();
  }

  Future<RecipeModel> getRecipeById(int id) async {
    return await recipeService.getRecipeById(id);
  }

  // Add a new recipe
  Future<bool> addRecipe(RecipeModel recipe) async {
    try {
      return await recipeService.addRecipe(recipe);
    } catch (e) {
      throw Exception("Failed to add recipe: $e");
    }
  }

  Future<bool> updateRecipe(int recipeId, Map<String, dynamic> changes) async {
    return await updateRecipe(recipeId, changes);
  }

  Future<bool> approveRecipe(int recipeId) async {
    return await recipeService.approveRecipe(recipeId);
  }


  Future<bool> deleteRecipe(int recipeId) async {
    return await recipeService.deleteRecipe(recipeId);
  }



}