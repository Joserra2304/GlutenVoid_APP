import 'package:glutenvoid_app/service/user_service.dart';
import 'package:go_router/go_router.dart';
import '../../controller/establishment_controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/recipe_controller.dart';
import '../../model/establishment_model.dart';
import '../../model/product_model.dart';
import '../../model/recipe_model.dart';
import '../../service/establishment_service.dart';
import '../../service/glutenvoid_api_service.dart';
import '../../service/recipe_service.dart';
import '../widget/bottom_app_bar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'user_view_model.dart';
export 'user_view_model.dart';

class UserViewWidget extends StatefulWidget {
  const UserViewWidget({super.key});

  @override
  State<UserViewWidget> createState() => _UserViewWidgetState();
}

class _UserViewWidgetState extends State<UserViewWidget> {
  late UserViewModel _model;
  int _selectedIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductController productController = ProductController();
  final RecipeController recipeController =
      RecipeController(RecipeService(GlutenVoidApi()));
  final EstablishmentController establishmentController =
      EstablishmentController(EstablishmentService(GlutenVoidApi()));
  bool _isLoadingProducts = true;
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserViewModel());
    _fetchProducts();
    _fetchOtherData();
  }

  void _fetchProducts() async {
    try {
      List<ProductModel> products =
          await productController.fetchGlutenFreeProducts();
      setState(() {
        productController.products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  void _fetchOtherData() async {
    List<RecipeModel> recipes = await recipeController.fetchApprovedRecipes();
    List<EstablishmentModel> establishments =
        await establishmentController.fetchEstablishments();

    setState(() {
      recipeController.recipes = recipes;
      establishmentController.establishments = establishments;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<bool> shouldExit(BuildContext context) async {
    bool shouldExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF7C4DA4),
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.yellow)),
        content: Text('¿Está seguro de que deseas salir de tu sesión?',
            style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No',
                style:
                    TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sí',
                style:
                    TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          ),
        ],
      ),
    );

    if (shouldExit) {
      userService.logout();
      context.pushNamed("MainMenu");
    }

    return false;
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return shouldExit(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gluten Void',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.map,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: () {
                        context.pushNamed('MapView');
                      },
                    ),
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.logout_outlined,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: () {
                        shouldExit(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [],
            centerTitle: false,
            elevation: 2.0,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'RECETAS',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    buildSection<RecipeModel>(
                      context: context,
                      icon: Icons.cookie,
                      title: 'Recetas',
                      items: recipeController.recipes,
                      buildItem: buildRecipeItem,
                    ),
                    SizedBox(height: 16.0),
                    const Text(
                      'RESTAURANTES',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    buildSection<EstablishmentModel>(
                      context: context,
                      icon: Icons.food_bank,
                      title: 'Establecimientos',
                      items: establishmentController.establishments,
                      buildItem: buildEstablishmentItem,
                    ),
                    SizedBox(height: 16.0),
                    const Text(
                      'PRODUCTOS',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    _isLoadingProducts
                        ? Center(child: CircularProgressIndicator())
                        : buildSection<ProductModel>(
                            context: context,
                            icon: Icons.shopping_bag,
                            title: 'Productos',
                            items: productController.products,
                            buildItem: buildProductItem,
                          ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: CommonBottomAppBar(
            selectedIndex: _selectedIndex,
            parentContext: context,
          ),
        ),
      ),
    );
  }

  Widget buildSection<T>({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<T> items,
    required Widget Function(T) buildItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 30.0, color: Colors.black),
            SizedBox(width: 10.0),
            Expanded(
              child: Container(
                height: 2.0,
                color: Colors.black,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          height: 150.0,
          child: buildCarousel(items, buildItem),
        ),
      ],
    );
  }

  Widget buildCarousel<T>(List<T> items, Widget Function(T) buildItem) {
    return items.isEmpty
        ? Center(
            child: Text(
              'No hay elementos disponibles',
              style: TextStyle(
                color: Colors.pink[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : CarouselSlider(
            items: items.map((item) => buildItem(item)).toList(),
            options: CarouselOptions(
              height: 150.0,
              initialPage: 0,
              viewportFraction: 0.8,
              disableCenter: true,
              enlargeCenterPage: true,
              enlargeFactor: 0.25,
              enableInfiniteScroll: true,
              scrollDirection: Axis.horizontal,
              autoPlay: false,
            ),
          );
  }

  Widget buildProductItem(ProductModel item) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('ProductDetailsView',
            queryParameters: {'barcode': item.barcode});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                item.imageUrl,
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10.0),
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecipeItem(RecipeModel item) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('RecipeDetailsView',
            queryParameters: {'id': item.id.toString()});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  item.description,
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondary,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEstablishmentItem(EstablishmentModel item) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('EstablishmentDetailsView',
            queryParameters: {'id': item.id.toString()});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 7.5),
                Text(
                  '${item.address}',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondary,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  '${item.city}',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondary,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
