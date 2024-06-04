import 'dart:convert';

import 'recipe_model.dart';

enum UserRole { admin, user }
enum GlutenCondition { Alergia, Celiaquia, Sensibilidad, Ninguna }

class UserModel {
  final int? id;
  final String name;
  final String surname;
  final String email;
  final String username;
  final String password;
  final String? profileBio;
  final GlutenCondition glutenCondition;
  final bool isAdmin;
  final List<RecipeModel> recipes;

  UserModel({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.username,
    required this.password,
    this.profileBio,
    this.glutenCondition = GlutenCondition.Ninguna,
    this.isAdmin = false,
    this.recipes = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      profileBio: json['profileBio'],
      glutenCondition: GlutenCondition.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['glutenCondition'].toString().toUpperCase(),
        orElse: () => GlutenCondition.Ninguna,
      ),
      isAdmin: json['admin'] ?? false,
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'username': username,
      'password': password,
      if (profileBio != null) 'profileBio': profileBio,
      'glutenCondition': glutenCondition.toString().split('.').last,
      'admin': isAdmin,
      'recipes': recipes.map((recipe) => recipe.toJson()).toList(),
    };
  }
}

