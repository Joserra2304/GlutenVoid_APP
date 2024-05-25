import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '/service/glutenvoid_api_service.dart';

class UserService {
  static final UserService _singleton = UserService._internal();

  final GlutenVoidApi glutenVoidApi;

  UserModel? _currentUser;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  UserModel? get currentUser => _currentUser;

  factory UserService() {
    return _singleton;
  }

  UserService._internal() : glutenVoidApi = GlutenVoidApi();

  Future<List<UserModel>> fetchAllUsers() async {
    final response = await glutenVoidApi.get('/users');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<UserModel> getUserById(int id) async {
    final response = await glutenVoidApi.get('/users/$id');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<bool> register(UserModel newUser) async {
    final response = await glutenVoidApi.post('/users', jsonEncode(newUser.toJson()));
    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed to register: ${response.body}');
      print('Failed to register: Status ${response.statusCode}, Body: ${response.body}');
      return false;
    }
  }
  Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    final response = await glutenVoidApi.patch('/users/$userId', jsonEncode(updates));
    print('Request body: ${jsonEncode(updates)}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response.statusCode == 200;
  }



  Future<bool> deleteUser(int userId) async {
    final response = await glutenVoidApi.delete('/users/$userId');
    return response.statusCode == 204;
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await glutenVoidApi.post('/users/login', jsonEncode({
        'username': username,
        'password': password,
      }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response data: $data");  // Log para depuración

        // Verificar si el token está presente y no es nulo
        String? jwtToken = data['jwt'];
        if (jwtToken != null) {
          print("JWT Token: $jwtToken");  // Log para depuración

          // Verificar si los datos del usuario están presentes y no son nulos
          if (data.containsKey('user') && data['user'] != null) {
            Map<String, dynamic> userJson = data['user'];
            print("User JSON: $userJson");  // Log para depuración

            // Crear el UserModel desde el campo 'user' en la respuesta
            _currentUser = UserModel.fromJson(userJson);

            // Verificar que _currentUser no sea nulo antes de llamar a toJson
            if (_currentUser != null) {
              print("User Data: ${_currentUser!.toJson()}");  // Log para depuración
            }

            // Almacenar el token JWT
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt', jwtToken);

            return _currentUser;
          } else {
            print("Error: 'user' key is missing or null in the response data");
          }
        } else {
          print("No token found in the response");
        }
      } else {
        print("Login failed with status: ${response.statusCode}");
        if (response.statusCode == 500) {
          print("Server error: ${response.body}");
        }
      }
    } catch (e) {
      print("Error making login request: $e");
    }
    return null;
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
  }
}

