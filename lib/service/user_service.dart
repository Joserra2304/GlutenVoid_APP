import 'dart:async';

import 'package:flutter/material.dart';
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
  Timer? _tokenTimer;

  factory UserService() {
    return _singleton;
  }

  UserService._internal() : glutenVoidApi = GlutenVoidApi();

  Future<void> saveTokenAndExpiration(String token, int expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    await prefs.setInt('tokenExpiryTime', expiresAt);
  }

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

  Future<UserModel?> login(String username, String password, BuildContext context) async {
    try {
      final response = await glutenVoidApi.post('/users/login', jsonEncode({
        'username': username,
        'password': password,
      }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response data: $data");  // Log para depuración

        String? jwtToken = data['jwt'];
        int? expiresAt = data['expiresAt'];
        if (jwtToken != null && expiresAt != null) {
          await saveTokenAndExpiration(jwtToken, expiresAt);
          print("JWT Token: $jwtToken");  // Log para depuración
          _startTokenTimer(context, expiresAt - DateTime.now().millisecondsSinceEpoch);

          if (data.containsKey('user') && data['user'] != null) {
            Map<String, dynamic> userJson = data['user'];
            print("User JSON: $userJson");  // Log para depuración

            _currentUser = UserModel.fromJson(userJson);
            if (_currentUser != null) {
              print("User Data: ${_currentUser!.toJson()}");  // Log para depuración
            }

            return _currentUser;
          } else {
            print("Error: 'user' key is missing or null in the response data");
          }
        } else {
          print("No token or expiration info found in the response");
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

  void _startTokenTimer(BuildContext context, int expiryDuration) {
    _tokenTimer?.cancel();  // Cancela cualquier timer existente
    _tokenTimer = Timer(Duration(milliseconds: expiryDuration - 5000), () => _showTokenExpiryAlert(context));  // 5 segundos antes de que expire
  }

  void _showTokenExpiryAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Session Expiry"),
          content: Text("Your session is about to expire. Please log in again to continue."),
          actions: [
            TextButton(
              child: Text("Renew Session"),
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('tokenExpiryTime'); // Asegúrate de eliminar el tiempo de expiración
    _tokenTimer?.cancel(); // Cancela el temporizador del token
  }
}
