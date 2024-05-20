



import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/user_service.dart';

class UserController {
  final UserService userService;

  UserController(this.userService);

  Future<List<UserModel>> getUsers() async {
    return await userService.fetchAllUsers();
  }

  Future<UserModel> getUserById(int id) async {
    return await userService.getUserById(id);
  }

  Future<bool> registerUser(UserModel newUser) async {
    try {
      return await userService.register(newUser);
    } catch (e) {
      throw Exception("Failed to register: $e");
    }
  }

  Future<bool> deleteUser(int id) async {
    return userService.deleteUser(id);
  }

  Future<bool> updateUser(int id, Map<String, dynamic> updates) async {
    return userService.updateUser(id, updates);
  }

  Future<UserModel?> attemptLogin(String username, String password) async {
    return await userService.login(username, password);
  }

  void logout(BuildContext context) {
    userService.logout(); // Llama al método logout del UserService
    Navigator.pushReplacementNamed(context, '/login'); // Redirige al login
  }

  Widget getViewForCurrentUser() {
    final currentUser = userService.currentUser;
    if (currentUser == null) {
      return Center(child: Text("No hay usuario autenticado"));
    }
    // Simplifica las vistas, retorna solo el esqueleto básico.
    if (currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text("Admin Dashboard")),
        body: Center(child: Text("Admin Area")),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("User Dashboard")),
        body: Center(child: Text("User Area")),
      );
    }
  }
}
