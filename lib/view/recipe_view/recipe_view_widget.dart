import 'package:glutenvoid_app/index.dart';
import '../../controller/recipe_controller.dart';
import '../../model/recipe_model.dart';
import '../../service/user_service.dart';
import '../widget/bottom_app_bar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class RecipeViewWidget extends StatefulWidget {
  final RecipeController recipeController;

  const RecipeViewWidget({super.key, required this.recipeController});

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
      _recipes = widget.recipeController.fetchApprovedRecipes();
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
          title: Text('Añadir Receta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nombre de la Receta')),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Descripción')),
                TextField(controller: _ingredientsController, decoration: InputDecoration(labelText: 'Ingredientes')),
                TextField(controller: _instructionsController, decoration: InputDecoration(labelText: 'Instrucciones')),
                TextField(controller: _preparationTimeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Tiempo de Preparación (min)')),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (userService.currentUser?.id == null) {
                  print("Error: Usuario no autenticado.");
                  return;
                }

                bool isAdmin = userService.isAdmin;
                RecipeModel newRecipe = RecipeModel(
                  id: 0, // ID se maneja en el backend
                  name: _nameController.text,
                  description: _descriptionController.text,
                  ingredients: _ingredientsController.text,
                  instructions: _instructionsController.text,
                  preparationTime: int.tryParse(_preparationTimeController.text) ?? 0,
                  approval: isAdmin,
                  userId: userService.currentUser?.id ?? 0,
                );

                // Utilizar Log para mostrar la información de la receta
                print("Guardando receta: ${newRecipe.toString()}");
                print("userId: ${newRecipe.userId}");

                bool result = await widget.recipeController.addRecipe(newRecipe);
                Navigator.of(context).pop();
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receta añadida con éxito y " + (isAdmin ? "aprobada." : "pendiente de aprobación."))));
                  if (isAdmin) {
                    _refreshRecipes(); // Refresh the list immediately for admins
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar la receta.")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditRecipeDialog(RecipeModel recipe) async {
    TextEditingController _nameController = TextEditingController(text: recipe.name);
    TextEditingController _descriptionController = TextEditingController(text: recipe.description);
    TextEditingController _ingredientsController = TextEditingController(text: recipe.ingredients);
    TextEditingController _instructionsController = TextEditingController(text: recipe.instructions);
    TextEditingController _preparationTimeController = TextEditingController(text: recipe.preparationTime.toString());

    var result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Receta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nombre de la Receta')),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Descripción')),
                TextField(controller: _ingredientsController, decoration: InputDecoration(labelText: 'Ingredientes')),
                TextField(controller: _instructionsController, decoration: InputDecoration(labelText: 'Instrucciones')),
                TextField(controller: _preparationTimeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Tiempo de Preparación (min)')),
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
                  preparationTime: int.tryParse(_preparationTimeController.text) ?? 0,
                  approval: recipe.approval,
                  userId: recipe.userId,
                );

                bool result = await widget.recipeController.updateRecipe(recipe.id, updatedRecipe.toJson());
                Navigator.of(context).pop(result);
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receta actualizada con éxito.")));
                  _refreshRecipes();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al actualizar la receta.")));
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

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = UserService().isAdmin;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondary,
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
            userService.isAdmin ? context.pushNamed('AdminView') : context.pushNamed('UserView');
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
                if (userService.isAdmin)
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context).primary,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).accent1,
                    icon: Icon(
                      Icons.approval,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 24.0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeApprovalViewWidget(recipeController: widget.recipeController),
                        ),
                      );
                    },
                  ),
                FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).primary,
                  borderRadius: 20.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).accent1,
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
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    var recipe = recipes[index];
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
                              colors: [
                                FlutterFlowTheme.of(context).accent3,
                                FlutterFlowTheme.of(context).accent4,
                              ],
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
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                fontFamily: 'Outfit',
                                color: FlutterFlowTheme.of(context).secondary,
                                letterSpacing: 0.0,
                              ),
                            ),
                            tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                            dense: false,
                            onTap: () async {
                              context.pushNamed('RecipeDetailsView',
                                  queryParameters: {'id': recipe.id.toString()});
                            },
                            trailing: userService.isAdmin
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlutterFlowIconButton(
                                  icon: Icon(Icons.edit, color: Colors.green),
                                  onPressed: () {
                                    _showEditRecipeDialog(recipe);
                                  },
                                ),
                                FlutterFlowIconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool confirmed = await _confirmDeletion();
                                    if (confirmed) {
                                      bool success = await widget.recipeController
                                          .deleteRecipe(recipe.id);
                                      if (success) {
                                        setState(() {
                                          recipes.removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receta eliminada con éxito')));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar la receta')));
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
      bottomNavigationBar: isAdmin
          ? null
          : CommonBottomAppBar(
        selectedIndex: _selectedIndex,
        parentContext: context,
      ),
    );
  }
}
