import 'package:flutter/material.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_icon_button.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_theme.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_util.dart';
import 'package:glutenvoid_app/controller/recipe_controller.dart';
import 'package:glutenvoid_app/model/recipe_model.dart';
import 'package:glutenvoid_app/service/user_service.dart';

class RecipeDetailsViewWidget extends StatefulWidget {
  final int recipeId;
  final RecipeController recipeController;

  RecipeDetailsViewWidget({Key? key, required this.recipeId, required this.recipeController}) : super(key: key);

  @override
  _RecipeDetailsViewWidgetState createState() => _RecipeDetailsViewWidgetState();
}

class _RecipeDetailsViewWidgetState extends State<RecipeDetailsViewWidget> {
  late Future<RecipeModel> _recipeFuture;
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    _recipeFuture = widget.recipeController.getRecipeById(widget.recipeId);
  }

  void _showEditRecipeDialog(RecipeModel recipe) {
    TextEditingController _nameController = TextEditingController(text: recipe.name);
    TextEditingController _descriptionController = TextEditingController(text: recipe.description);
    TextEditingController _ingredientsController = TextEditingController(text: recipe.ingredients);
    TextEditingController _instructionsController = TextEditingController(text: recipe.instructions);
    TextEditingController _preparationTimeController = TextEditingController(text: recipe.preparationTime.toString());
    bool _isApproved = recipe.approval;  // Estado actual de aprobación

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Receta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nombre')),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Descripción')),
                TextField(controller: _ingredientsController, decoration: InputDecoration(labelText: 'Ingredientes')),
                TextField(controller: _instructionsController, decoration: InputDecoration(labelText: 'Instrucciones')),
                TextField(controller: _preparationTimeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Tiempo de Preparación')),
                if (userService.isAdmin) SwitchListTile(  // Solo visible para administradores
                  value: _isApproved,
                  onChanged: (bool value) {
                    setState(() {
                      _isApproved = value;
                    });
                  },
                  title: Text('Aprobada'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar Cambios'),
              onPressed: () async {
                Map<String, dynamic> updates = {
                  'id': recipe.id,
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                  'ingredients': _ingredientsController.text,
                  'instructions': _instructionsController.text,
                  'preparationTime': int.tryParse(_preparationTimeController.text) ?? recipe.preparationTime,
                  'approval': _isApproved,
                  'userId': recipe.userId // Mantener el mismo userId
                };
                bool success = await widget.recipeController.updateRecipe(recipe.id, updates);
                if (success) {
                  Navigator.of(context).pop();
                  setState(() {
                    _recipeFuture = widget.recipeController.getRecipeById(widget.recipeId); // Refresh the details
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receta actualizada con éxito")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al actualizar la receta")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar esta receta?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                bool success = await widget.recipeController.deleteRecipe(widget.recipeId);
                Navigator.of(context).pop(success);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              context.pop();
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
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: userService.isAdmin
                    ? [
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context).primaryColor,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).accent1,
                    icon: Icon(
                      Icons.edit,
                      color: FlutterFlowTheme.of(context).secondaryColor,
                      size: 24.0,
                    ),
                    onPressed: () {
                      _recipeFuture.then((recipe) {
                        if (recipe != null) _showEditRecipeDialog(recipe);
                      });
                    },
                  ),
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context).primaryColor,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).accent1,
                    icon: Icon(
                      Icons.delete,
                      color: FlutterFlowTheme.of(context).tertiaryColor,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      bool deleted = await _confirmDeletion();
                      if (deleted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                ]
                    : [],
              ),
            ],
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: FutureBuilder<RecipeModel>(
            future: _recipeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data!.name,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300.0,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      snapshot.data!.description,
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                        fontFamily: 'Readex Pro',
                                        color: FlutterFlowTheme.of(context).secondaryColor,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300.0,
                                  height: 125.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      snapshot.data!.ingredients,
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                        fontFamily: 'Readex Pro',
                                        color: FlutterFlowTheme.of(context).secondaryColor,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300.0,
                                  height: 125.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      snapshot.data!.instructions,
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                        fontFamily: 'Readex Pro',
                                        color: FlutterFlowTheme.of(context).secondaryColor,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 6.0),
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                                    child: Icon(
                                      Icons.av_timer,
                                      color: FlutterFlowTheme.of(context).primaryColor,
                                      size: 40.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                    child: Text(
                                      snapshot.data!.preparationTime.toString(),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'min.',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
