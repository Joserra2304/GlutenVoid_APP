import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/user_service.dart';

class UserController {
  final UserService userService;

  UserController(this.userService);

  Future<List<UserModel>> getUsers(BuildContext context) async {
    return await UserService().fetchAllUsers(context);
  }

  Future<UserModel> getUserById(int id, BuildContext context) async {
    return await userService.getUserById(id, context);
  }

  Future<bool> registerUser(UserModel newUser, BuildContext context) async {
    try {
      return await userService.register(newUser, context);
    } catch (e) {
      throw Exception("Failed to register: $e");
    }
  }

  Future<bool> deleteUser(int id, BuildContext context) async {
    return userService.deleteUser(id, context);
  }

  Future<bool> updateUser(int id, Map<String, dynamic> updates, BuildContext context) async {
    return userService.updateUser(id, updates, context);
  }

  Future<UserModel?> attemptLogin(String username, String password, BuildContext context) async {
    try {
      return await userService.login(username, password, context);
    } catch (e) {
      print("Login attempt failed: $e");
      return null;
    }
  }


  void logout(BuildContext context) {
    userService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget getViewForCurrentUser() {
    final currentUser = userService.currentUser;
    if (currentUser == null) {
      return Center(child: Text("No hay usuario autenticado"));
    }

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
