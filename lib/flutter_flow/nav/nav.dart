import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glutenvoid_app/view/recipe_approval_view/recipe_approval_view_widget.dart';
import 'package:glutenvoid_app/view/widget/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../controller/establishment_controller.dart';
import '../../controller/map_controller.dart';
import '../../controller/recipe_controller.dart';
import '../../service/barcode_scanner_service.dart';
import '../../service/establishment_service.dart';
import '../../service/glutenvoid_api_service.dart';
import '../../service/product_service.dart';
import '../../service/recipe_service.dart';
import '../../service/user_service.dart';
import '../../view/admin_view/admin_view_widget.dart';
import '../../view/product_view/product_view_widget.dart';
import '../../view/recipe_details_view/recipe_details_view_widget.dart';
import '../../view/recipe_view/recipe_view_widget.dart';
import '../../view/register_view/register_view_widget.dart';
import '../../view/user_control_view/user_control_view_widget.dart';
import '../../view/user_profile_view/user_profile_view_widget.dart';
import '../../view/user_view/user_view_widget.dart';
import '../../view/widget/map_view.dart';
import '/index.dart';
import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}
GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  errorBuilder: (context, state) => MainMenuWidget(),
  routes: [
    GoRoute(
      name: 'SplashScreen',
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      name: 'MainMenu',
      path: '/mainMenu',
      builder: (context, state) => MainMenuWidget(),
    ),
    GoRoute(
      name: 'RegisterView',
      path: '/registerView',
      builder: (context, state) => RegisterViewWidget(),
    ),
    GoRoute(
      name: 'AdminView',
      path: '/adminView',
      builder: (context, state) => AdminViewWidget(),
    ),
    GoRoute(
      name: 'UserView',
      path: '/userView',
      builder: (context, state) => UserViewWidget(),
    ),
    GoRoute(
      name: 'ProductView',
      path: '/productView',
      builder: (context, state) => ProductViewWidget(),
    ),

    GoRoute(
      name: 'EstablishmentView',
      path: '/establishmentView',
      builder: (context, state) => EstablishmentViewWidget(
        establishmentController: EstablishmentController(EstablishmentService(GlutenVoidApi())),
      ),
    ),

    GoRoute(
      name: 'RecipeApprovalView',
      path: '/recipeApprovalView',
      builder: (context, state) => RecipeApprovalViewWidget(
        recipeController: RecipeController(RecipeService(GlutenVoidApi())),
      ),
    ),
    //RECIPES
    GoRoute(
      name: 'RecipeView',
      path: '/recipeView',
      builder: (context, state) => RecipeViewWidget(
        recipeController: RecipeController(RecipeService(GlutenVoidApi())),
      ),
    ),

    GoRoute(
      name: 'UserRecipesView',
      path: '/userRecipesView',
      builder: (context, state) {
        final userIdParam = state.uri.queryParameters['userId'];
        if (userIdParam != null) {
          final userId = int.tryParse(userIdParam);
          if (userId != null) {
            return RecipeViewWidget(
              recipeController: RecipeController(RecipeService(GlutenVoidApi())),
              userId: userId,
            );
          }
        }
        return RecipeViewWidget(
          recipeController: RecipeController(RecipeService(GlutenVoidApi())),
        );
      },
    ),

    GoRoute(
      name: 'RecipeDetailsView',
      path: '/recipeDetailsView',
      builder: (context, state) {
        final recipeIdParam = state.uri.queryParameters['recipeId'];
        final userIdParam = state.uri.queryParameters['userId'];
        if (recipeIdParam != null && userIdParam != null) {
          final recipeId = int.tryParse(recipeIdParam);
          final userId = int.tryParse(userIdParam);
          if (recipeId != null && userId != null) {
            return RecipeDetailsViewWidget(
              recipeId: recipeId,
              recipeController: RecipeController(RecipeService(GlutenVoidApi())),
              userId: userId,
            );
          }
        }
        return RecipeViewWidget(
            recipeController: RecipeController(RecipeService(GlutenVoidApi())),
        );
      },
    ),
    GoRoute(
      name: 'EstablishmentDetailsView',
      path: '/establishmentDetailsView',
      builder: (context, state) {
        final id = int.parse(state.uri.queryParameters['id']!);
        return EstablishmentDetailsViewWidget(
          establishmentId: id,
          establishmentController: EstablishmentController(EstablishmentService(GlutenVoidApi())),
        );
      },
    ),
    GoRoute(
      name: 'ProductDetailsView',
      path: '/productDetailsView',
      builder: (context, state) {
        final barcode = state.uri.queryParameters['barcode'];
        return ProductDetailsViewWidget(
          barcode: barcode ?? 'nou',
          onScan: () async {
            await BarcodeScannerService((String barcode) async {
              final newProduct = await ProductService().fetchProductByBarcode(barcode);
              if (newProduct != null) {
                // Actualiza el estado o navega al detalle del producto escaneado
              }
            }).scanBarcode(context);
          },
        );
      },
    ),
    GoRoute(
      name: 'UserProfileView',
      path: '/userProfileView',
      builder: (context, state) {
        final userId = int.parse(state.uri.queryParameters['id']!);
        return UserProfileViewWidget(userId: userId);
      },
    ),
    GoRoute(
      name: 'MapView',
      path: '/mapView',
      builder: (context, state) => MapView(
        mapController: MapController(EstablishmentService(GlutenVoidApi())),
        establishmentController: EstablishmentController(EstablishmentService(GlutenVoidApi())),
      ),
    ),
    GoRoute(
      name: 'UserControlView',
      path: '/userControlView',
      builder: (context, state) => UserControlViewWidget(),
    ),
  ],
);



extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    if (canPop()) {
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
    value: RootPageContext(true, errorRoute),
    child: child,
  );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
