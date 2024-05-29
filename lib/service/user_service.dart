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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<int?> _getTokenExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tokenExpiryTime');
  }

  Future<void> renewToken(BuildContext context) async {
    final token = await _getToken();
    if (token != null) {
      final response = await glutenVoidApi.post('/auth/refresh', jsonEncode({'token': token}));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? newToken = data['token'];
        int? newExpiresAt = data['expiresAt'];
        if (newToken != null && newExpiresAt != null) {
          await saveTokenAndExpiration(newToken, newExpiresAt);
          _startTokenTimer(context, newExpiresAt - DateTime.now().millisecondsSinceEpoch);
        }
      } else {
        print("Failed to renew token with status: ${response.statusCode}");
      }
    }
  }

  Future<void> ensureTokenIsValid(BuildContext context) async {
    final expiryTime = await _getTokenExpiryTime();
    if (expiryTime != null && DateTime.now().millisecondsSinceEpoch >= expiryTime - 5000) {
      await renewToken(context);
    }
  }

  Future<List<UserModel>> fetchAllUsers(BuildContext context) async {
    await ensureTokenIsValid(context);
    final response = await glutenVoidApi.get('/users');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<UserModel> getUserById(int id, BuildContext context) async {
    await ensureTokenIsValid(context);
    final response = await glutenVoidApi.get('/users/$id');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<bool> register(UserModel newUser, BuildContext context) async {
    await ensureTokenIsValid(context);
    final response = await glutenVoidApi.post('/users', jsonEncode(newUser.toJson()));
    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed to register: ${response.body}');
      return false;
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> updates, BuildContext context) async {
    await ensureTokenIsValid(context);
    final response = await glutenVoidApi.patch('/users/$userId', jsonEncode(updates));
    return response.statusCode == 200;
  }

  Future<bool> deleteUser(int userId, BuildContext context) async {
    await ensureTokenIsValid(context);
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
        String? jwtToken = data['jwt'];
        int? expiresAt = data['expiresAt'];
        if (jwtToken != null && expiresAt != null) {
          await saveTokenAndExpiration(jwtToken, expiresAt);
          _startTokenTimer(context, expiresAt - DateTime.now().millisecondsSinceEpoch);

          if (data.containsKey('user') && data['user'] != null) {
            Map<String, dynamic> userJson = data['user'];
            _currentUser = UserModel.fromJson(userJson);
            return _currentUser;
          }
        }
      }
    } catch (e) {
      print("Error making login request: $e");
    }
    return null;
  }

  void _startTokenTimer(BuildContext context, int expiryDuration) {
    _tokenTimer?.cancel();
    _tokenTimer = Timer(Duration(milliseconds: expiryDuration - 5000), () => _showTokenExpiryAlert(context));
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
              onPressed: () async {
                await renewToken(context);
                Navigator.of(context).pop();
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
    await prefs.remove('tokenExpiryTime');
    _tokenTimer?.cancel();
  }
}