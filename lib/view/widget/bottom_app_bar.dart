import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../service/user_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class CommonBottomAppBar extends StatelessWidget {
  final BuildContext parentContext;
  final int selectedIndex;

  CommonBottomAppBar({
    required this.selectedIndex,
    required this.parentContext,
  });

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        GoRouter.of(parentContext).go('/productView');
        break;
      case 1:
        GoRouter.of(parentContext).go('/recipeView');
        break;
      case 2:
        GoRouter.of(parentContext).go('/mapView');
        break;
      case 3:
        var userService = UserService();
        var userId = userService.currentUser?.id;
        if (userId != null) {
          GoRouter.of(parentContext).go('/userProfileView?id=$userId');
        } else {
          print("No hay un usuario autenticado para mostrar el perfil");
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = FlutterFlowTheme.of(context).primary;
    final secondaryColor = FlutterFlowTheme.of(context).secondary;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: primaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color:
                  selectedIndex == 0 ? const Color(0xFFe9d7ac) : secondaryColor,
            ),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            icon: Icon(
              Icons.menu_book,
              color:
                  selectedIndex == 1 ? secondaryColor : const Color(0xFFe9d7ac),
            ),
            onPressed: () => _onItemTapped(1),
          ),
          IconButton(
            icon: Icon(
              Icons.restaurant_menu,
              color:
                  selectedIndex == 2 ? secondaryColor : const Color(0xFFe9d7ac),
            ),
            onPressed: () => _onItemTapped(2),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color:
                  selectedIndex == 3 ? secondaryColor : const Color(0xFFe9d7ac),
            ),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
    );
  }
}
