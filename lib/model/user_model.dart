import 'dart:convert';

enum UserRole { admin, user }
enum GlutenCondition {ALERGIC, INTOLERANT, SENSITIVE}

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

  UserModel({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.username,
    required this.password,
    this.profileBio,
    this.glutenCondition = GlutenCondition.INTOLERANT,
    this.isAdmin = false,
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
            (e) => e.toString().split('.').last == json['glutenCondition'],
        orElse: () => GlutenCondition.INTOLERANT,
      ),
      isAdmin: json['admin'] as bool ?? false,
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
    };
  }
}
