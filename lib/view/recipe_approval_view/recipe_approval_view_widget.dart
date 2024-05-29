import '../../controller/recipe_controller.dart';
import '../../model/recipe_model.dart';
import '../../service/user_service.dart';
import '../widget/snackbar_messages.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class RecipeApprovalViewWidget extends StatefulWidget {
  final RecipeController recipeController;

  const RecipeApprovalViewWidget({super.key, required this.recipeController});

  @override
  State<RecipeApprovalViewWidget> createState() =>
      _RecipeApprovalViewWidgetState();
}

class _RecipeApprovalViewWidgetState extends State<RecipeApprovalViewWidget> {
  late Future<List<RecipeModel>> _unapprovedRecipes;
  final List<GlobalKey<FlipCardState>> _cardKeys = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshUnapprovedRecipes();
  }

  void _refreshUnapprovedRecipes() {
    setState(() {
      _unapprovedRecipes = widget.recipeController.fetchPendingRecipes();
    });
  }

  void _approveRecipe(int id) async {
    bool success = await widget.recipeController.approveRecipe(id);
    if (success) {
      SnackbarMessages.showPositiveSnackbar(
          context, "Receta aprobada con éxito");
      _refreshUnapprovedRecipes();
    } else {
      SnackbarMessages.showNegativeSnackbar(
          context, "No se pudo aprobar la receta");
    }
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta receta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _flipCard(int index) {
    for (int i = 0; i < _cardKeys.length; i++) {
      if (i != index && _cardKeys[i].currentState!.isFront == false) {
        _cardKeys[i].currentState!.toggleCard();
      }
    }
    _cardKeys[index].currentState!.toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).secondary,
            size: 30.0,
          ),
          onPressed: () {
            userService.isAdmin
                ? context.pushNamed("AdminView")
                : context.pushNamed("UserView");
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aprobar Recetas',
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
                  fillColor: FlutterFlowTheme.of(context).accent1,
                  icon: Icon(
                    Icons.list_alt,
                    color: FlutterFlowTheme.of(context).secondary,
                    size: 24.0,
                  ),
                  onPressed: () {
                    context.pushNamed("RecipeView");
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
        child: FutureBuilder<List<RecipeModel>>(
          future: _unapprovedRecipes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar las recetas'));
            } else {
              var recipes = snapshot.data ?? [];
              _cardKeys.clear();
              for (int i = 0; i < recipes.length; i++) {
                _cardKeys.add(GlobalKey<FlipCardState>());
              }
              return Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          var recipe = recipes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Material(
                              color: Color(0xFF9575CD),
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                              child: userService.isAdmin
                                  ? FlipCard(
                                key: _cardKeys[index],
                                direction: FlipDirection.HORIZONTAL,
                                front: GestureDetector(
                                  onTap: () => _flipCard(index),
                                  child: Container(
                                    width: double.infinity,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF9575CD),
                                          Color(0xFFB39DDB)
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(0.0, -1.0),
                                        end: AlignmentDirectional(0, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(22.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: Text(
                                              recipe.name,
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .override(
                                                fontFamily: 'Outfit',
                                                color: FlutterFlowTheme
                                                    .of(context)
                                                    .secondary,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            subtitle: Text(
                                              recipe.description,
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                fontFamily: 'Readex Pro',
                                                color: FlutterFlowTheme
                                                    .of(context)
                                                    .secondary,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            tileColor: Colors.transparent,
                                            dense: false,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 42.0),
                                          child: Icon(
                                            Icons.touch_app_outlined,
                                            color:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                            size: 30.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                back: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).accent4,
                                        FlutterFlowTheme.of(context)
                                            .accent4Dark,
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.circular(22.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      FlutterFlowIconButton(
                                        borderColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius: 20.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .warning,
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          var result = await context.pushNamed('RecipeDetailsView',
                                              queryParameters: {
                                                'recipeId': recipe.id.toString(),
                                                'userId': recipe.userId.toString()
                                              });
                                          if (result == true) {
                                            _refreshUnapprovedRecipes();
                                          }
                                        },
                                      ),
                                      FlutterFlowIconButton(
                                        borderColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius: 20.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .success,
                                        icon: Icon(
                                          Icons.check,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () {
                                          _approveRecipe(recipe.id);
                                        },
                                      ),
                                      FlutterFlowIconButton(
                                        borderColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius: 20.0,
                                        borderWidth: 1.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .error,
                                        icon: Icon(
                                          Icons.delete,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          bool confirmed =
                                          await _confirmDeletion();
                                          if (confirmed) {
                                            bool success = await widget
                                                .recipeController
                                                .deleteRecipe(recipe.id);
                                            if (success) {
                                              setState(() {
                                                recipes.removeAt(index);
                                              });
                                              SnackbarMessages
                                                  .showPositiveSnackbar(
                                                  context,
                                                  "Receta eliminada con éxito");
                                            } else {
                                              SnackbarMessages
                                                  .showNegativeSnackbar(
                                                  context,
                                                  "Error al eliminar receta");
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Container(
                                width: double.infinity,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).accent3,
                                      FlutterFlowTheme.of(context).accent4
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(22.0),
                                  border: Border.all(
                                    color:
                                    FlutterFlowTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    recipe.name,
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                      fontFamily: 'Outfit',
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    recipe.description,
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  tileColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  dense: false,
                                  onTap: () {
                                    //_navigateToDetails(recipe.id);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
