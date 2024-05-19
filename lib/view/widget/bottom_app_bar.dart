import 'package:flutter/material.dart';

import '../../flutter_flow/flutter_flow_theme.dart';


class CommonBottomAppBar extends StatelessWidget {
  final BuildContext parentContext;
  final int selectedIndex;

  CommonBottomAppBar(
      {required this.selectedIndex, required this.parentContext});

  /*void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(parentContext,
            MaterialPageRoute(builder: (context) => ProductsView()));
        break;
      case 1:
        Navigator.push(
            parentContext,
            MaterialPageRoute(
                builder: (context) => RecipesView(
                  recipeController: RecipeController(
                    RecipeService(GlutenVoidApi()),
                  ),
                )
            )
        );
        break;
      case 2:
        Navigator.push(
            parentContext,
            MaterialPageRoute(
                builder: (context) => EstablishmentsView(
                  establishmentController: EstablishmentController(
                      EstablishmentService(GlutenVoidApi())),
                )
            )
        );
        break;
      case 3:
        var userService = UserService();
        var userId = userService.currentUser?.id;
        if (userId != null) {
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => UserProfileView(
                  userController: UserController(userService), // Pasar el userService adecuadamente
                  userId: userId
              ),
            ),
          );
        } else {
          // Opcional: Mostrar mensaje o redirigir al login
          print("No hay un usuario autenticado para mostrar el perfil");
        }
        break;
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    final primaryColor = FlutterFlowTheme.of(context).primary;
    final secondaryColor = FlutterFlowTheme.of(context).secondary;
    return BottomAppBar(

      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,

      color: primaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart, color: secondaryColor),
              onPressed: () {

              }),
          IconButton(
              icon: Icon(Icons.menu_book, color: secondaryColor),
              onPressed: () {

    }),
          IconButton(
              icon: Icon(Icons.restaurant_menu, color: secondaryColor),
              onPressed: () {

              }),
          IconButton(
              icon: Icon(Icons.person, color: Color(0xFFe9d7ac)),
              onPressed: () {

              }),
        ],
      ),
    );
  }
}
