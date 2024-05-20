import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to register: ${response.body}');
      print('Failed to register: Status ${response.statusCode}, Body: ${response.body}');
      return false;
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    final response = await glutenVoidApi.patch('/users/$userId', jsonEncode(updates));
    return response.statusCode == 200;
  }

  Future<bool> deleteUser(int userId) async {
    final response = await glutenVoidApi.delete('/users/$userId');
    return response.statusCode == 200;
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await glutenVoidApi.post('/users/login', jsonEncode({
        'username': username,
        'password': password,
      }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data);
        return _currentUser;
      } else {
        print("Login failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error making login request: $e");
      return null;
    }
  }

  void logout() {
    _currentUser = null;
  }
}
