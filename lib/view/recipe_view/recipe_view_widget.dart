import 'package:glutenvoid_app/index.dart';
import '../../controller/recipe_controller.dart';
import '../../model/recipe_model.dart';
import '../../service/user_service.dart';
import '../widget/bottom_app_bar.dart';
import '../widget/snackbar_messages.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class RecipeViewWidget extends StatefulWidget {
  final RecipeController recipeController;
  final int? userId;

  const RecipeViewWidget(
      {super.key, required this.recipeController, this.userId});

  @override
  State<RecipeViewWidget> createState() => _RecipeViewWidgetState();
}

class _RecipeViewWidgetState extends State<RecipeViewWidget> {
  late Future<List<RecipeModel>> _recipes;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final userService = UserService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  void _refreshRecipes() {
    setState(() {
      if (widget.userId != null) {
        _recipes = widget.recipeController.getRecipesByUserId(widget.userId!);
      } else {
        _recipes = widget.recipeController.fetchApprovedRecipes();
      }
    });
  }

  void _showAddRecipeDialog() {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _ingredientsController = TextEditingController();
    TextEditingController _instructionsController = TextEditingController();
    TextEditingController _preparationTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4),
          title: const Text('Añadir Receta',
              style: TextStyle(color: Colors.yellow)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Receta',
                    labelStyle: TextStyle(color: Colors.yellow),
                  ),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: Colors.yellow),
                  ),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary),
                ),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredientes',
                    labelStyle: TextStyle(color: Colors.yellow),
                  ),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary),
                ),
                TextField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instrucciones',
                    labelStyle: TextStyle(color: Colors.yellow),
                  ),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary),
                ),
                TextField(
                  controller: _preparationTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de Preparación (min)',
                    labelStyle: TextStyle(color: Colors.yellow),
                  ),
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Guardar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () async {
                if (userService.currentUser?.id == null) {
                  print("Error: Usuario no autenticado.");
                  return;
                }

                bool isAdmin = userService.isAdmin;
                RecipeModel newRecipe = RecipeModel(
                  id: 0,
                  // ID se maneja en el backend
                  name: _nameController.text,
                  description: _descriptionController.text,
                  ingredients: _ingredientsController.text,
                  instructions: _instructionsController.text,
                  preparationTime:
                      int.tryParse(_preparationTimeController.text) ?? 0,
                  approval: isAdmin,
                  userId: userService.currentUser?.id ?? 0,
                  username: userService.currentUser?.username ??
                      '', // Añadir nombre de usuario
                );

                // Utilizar Log para mostrar la información de la receta
                print("Guardando receta: ${newRecipe.toString()}");
                print("userId: ${newRecipe.userId}");

                bool result =
                    await widget.recipeController.addRecipe(newRecipe);
                Navigator.of(context).pop();
                if (result) {
                  SnackbarMessages.showPositiveSnackbar(
                      context,
                      "Receta añadida con éxito y " +
                          (isAdmin ? "aprobada." : "pendiente de aprobación."));
                  if (isAdmin) {
                    _refreshRecipes(); // Refresh the list immediately for admins
                  }
                } else {
                  SnackbarMessages.showNegativeSnackbar(
                      context, "Error al guardar la receta");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditRecipeDialog(RecipeModel recipe) async {
    TextEditingController _nameController =
        TextEditingController(text: recipe.name);
    TextEditingController _descriptionController =
        TextEditingController(text: recipe.description);
    TextEditingController _ingredientsController =
        TextEditingController(text: recipe.ingredients);
    TextEditingController _instructionsController =
        TextEditingController(text: recipe.instructions);
    TextEditingController _preparationTimeController =
        TextEditingController(text: recipe.preparationTime.toString());

    var result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Receta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration:
                        InputDecoration(labelText: 'Nombre de la Receta')),
                TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descripción')),
                TextField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(labelText: 'Ingredientes')),
                TextField(
                    controller: _instructionsController,
                    decoration: InputDecoration(labelText: 'Instrucciones')),
                TextField(
                    controller: _preparationTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Tiempo de Preparación (min)')),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                RecipeModel updatedRecipe = RecipeModel(
                  id: recipe.id,
                  name: _nameController.text,
                  description: _descriptionController.text,
                  ingredients: _ingredientsController.text,
                  instructions: _instructionsController.text,
                  preparationTime:
                      int.tryParse(_preparationTimeController.text) ?? 0,
                  approval: recipe.approval,
                  userId: recipe.userId,
                  username: recipe.username, // Mantener nombre de usuario
                );

                bool result = await widget.recipeController
                    .updateRecipe(recipe.id, updatedRecipe.toJson());
                Navigator.of(context).pop(result);
                if (result) {
                  SnackbarMessages.showPositiveSnackbar(
                      context, "Receta actualizada con éxito");
                  _refreshRecipes();
                } else {
                  SnackbarMessages.showNegativeSnackbar(
                      context, "Error al actualizar la receta");
                }
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      _refreshRecipes();
    }
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4), // Color morado claro
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: Colors.yellow)),
          content: Text('¿Estás seguro de que quieres eliminar esta receta?',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          actions: [
            TextButton(
              child: Text('Cancelar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = UserService().isAdmin;
    final bool isSpecificUserView = widget.userId != null;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
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
              if (isSpecificUserView && widget.userId != null) {
                context.pushNamed('UserProfileView',
                    queryParameters: {'id': widget.userId.toString()});
              } else {
                context.pushNamed(isAdmin ? 'AdminView' : 'UserView');
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recetas',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Outfit',
                      color: FlutterFlowTheme.of(context).secondary,
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (userService.isAdmin && !isSpecificUserView)
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.approval,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeApprovalViewWidget(
                                recipeController: widget.recipeController),
                          ),
                        );
                      },
                    ),
                  if ((userService.isAdmin && !isSpecificUserView) ||
                      !userService.isAdmin)
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.add,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: _showAddRecipeDialog,
                    ),
                ],
              ),
            ],
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: FutureBuilder<List<RecipeModel>>(
                future: _recipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar las recetas'));
                  } else {
                    var recipes = snapshot.data ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        var recipe = recipes[index];
                        bool isPendingApproval = !recipe.approval;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isPendingApproval
                                      ? [Color(0xFF9575CD), Color(0xFFB39DDB)]
                                      : [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
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
                                subtitle: isPendingApproval
                                    ? Text(
                                        'Pendiente de aprobación',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.red,
                                              letterSpacing: 0.0,
                                            ),
                                      )
                                    : null,
                                tileColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                dense: false,
                                onTap: () async {
                                  var result = await context.pushNamed(
                                      'RecipeDetailsView',
                                      queryParameters: {
                                        'recipeId': recipe.id.toString(),
                                        'userId': recipe.userId.toString()
                                      });
                                  if (result == true) {
                                    _refreshRecipes();
                                  }
                                },
                                trailing: userService.isAdmin
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FlutterFlowIconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
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
                                                          "Error al eliminar la receta");
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: isAdmin
            ? null
            : CommonBottomAppBar(
                selectedIndex: _selectedIndex,
                parentContext: context,
              ),
      ),
    );
  }
}
