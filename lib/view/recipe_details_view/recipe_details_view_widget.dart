import 'package:flutter/material.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_icon_button.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_theme.dart';
import 'package:glutenvoid_app/flutter_flow/flutter_flow_util.dart';
import 'package:glutenvoid_app/controller/recipe_controller.dart';
import 'package:glutenvoid_app/model/recipe_model.dart';
import 'package:glutenvoid_app/service/user_service.dart';
import 'package:go_router/go_router.dart';

import '../widget/bottom_app_bar.dart';
import '../widget/snackbar_messages.dart';

class RecipeDetailsViewWidget extends StatefulWidget {
  final int recipeId;
  final RecipeController recipeController;
  final int userId;

  RecipeDetailsViewWidget({Key? key, required this.recipeId, required this.recipeController, required this.userId}) : super(key: key);

  @override
  _RecipeDetailsViewWidgetState createState() => _RecipeDetailsViewWidgetState();
}

class _RecipeDetailsViewWidgetState extends State<RecipeDetailsViewWidget> {
  late Future<RecipeModel> _recipeFuture;
  final userService = UserService();
  int _selectedIndex = 0;

  bool _isEditingDescription = false;
  bool _isEditingIngredients = false;
  bool _isEditingInstructions = false;

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _ingredientsController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _ingredientsFocusNode = FocusNode();
  FocusNode _instructionsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _recipeFuture = widget.recipeController.getRecipeById(widget.recipeId);
    _recipeFuture.then((recipe) {
      if (recipe != null) {
        _descriptionController.text = recipe.description;
        _ingredientsController.text = recipe.ingredients;
        _instructionsController.text = recipe.instructions;
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _descriptionFocusNode.dispose();
    _ingredientsFocusNode.dispose();
    _instructionsFocusNode.dispose();
    super.dispose();
  }

  void _showEditRecipeDialog(RecipeModel recipe) {
    TextEditingController _nameController = TextEditingController(text: recipe.name);
    TextEditingController _preparationTimeController = TextEditingController(
        text: recipe.preparationTime.toString());
    bool _isApproved = recipe.approval;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF7C4DA4).withOpacity(0.9),
              title: const Text('Editar Receta',
                  style: TextStyle(color: Colors.yellow)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(controller: _nameController,
                        decoration: const InputDecoration(
                            labelText: 'Nombre',
                          labelStyle: TextStyle(color: Colors.yellow),
                        ),
                      style: TextStyle(color: FlutterFlowTheme.of(context).secondary),
                    ),
                    TextField(controller: _preparationTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Tiempo de Preparación',
                          labelStyle: TextStyle(color: Colors.yellow),
                        ),
                      style: TextStyle(color: FlutterFlowTheme.of(context).secondary),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Guardar Cambios', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () async {
                    Map<String, dynamic> updates = {
                      'id': recipe.id,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                      'ingredients': _ingredientsController.text,
                      'instructions': _instructionsController.text,
                      'preparationTime': int.tryParse(_preparationTimeController.text)
                          ?? recipe.preparationTime,
                      'approval': _isApproved,
                      'userId': recipe.userId,
                      'username': recipe.username,
                    };
                    bool success = await widget.recipeController.updateRecipe(recipe.id, updates);
                    if (success) {
                      Navigator.of(context).pop();
                      setState(() {
                        _recipeFuture = widget.recipeController.getRecipeById(widget.recipeId);
                      });
                      SnackbarMessages.showPositiveSnackbar(context, "Receta actualizada con éxito");
                    } else {
                      SnackbarMessages.showNegativeSnackbar(context, "Error al actualizar la receta");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4).withOpacity(0.9),
          title: const Text('Confirmar Eliminación', style: TextStyle(
              color: Colors.yellow)),
          content: Text('¿Estás seguro de que quieres eliminar esta receta?',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userService.isAdmin;
    final bool canEdit = isAdmin || userService.currentUser?.id == widget.userId;

    return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingDescription = false;
            _isEditingIngredients = false;
            _isEditingInstructions = false;
          });
          FocusScope.of(context).unfocus();

        },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
                Navigator.of(context).pop(true);
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
                if (canEdit)
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
                          Icons.edit,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 24.0,
                        ),
                        onPressed: () {
                          _recipeFuture.then((recipe) {
                            if (recipe != null) _showEditRecipeDialog(recipe);
                          });
                        },
                      ),
                      FlutterFlowIconButton(
                        borderColor: FlutterFlowTheme.of(context).primary,
                        borderRadius: 20.0,
                        borderWidth: 1.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).primary,
                        icon: Icon(
                          Icons.delete,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          bool confirmed = await _confirmDeletion();
                          if (confirmed) {
                            bool success = await widget.recipeController.deleteRecipe(widget.recipeId);
                            if (success) {
                              SnackbarMessages.showPositiveSnackbar(context, "Receta eliminada con éxito");
                              Navigator.of(context).pop(true);
                            } else {
                              SnackbarMessages.showNegativeSnackbar(context, "Error al eliminar la receta");
                            }
                          }
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
                                  Flexible(
                                    child: Text(
                                      snapshot.data!.name,
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 22.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildEditableField(
                              context,
                              label: 'Descripción',
                              isEditing: _isEditingDescription,
                              focusNode: _descriptionFocusNode,
                              controller: _descriptionController,
                              onTap: () {
                                if (canEdit) {
                                  setState(() {
                                    _isEditingDescription = true;
                                    _isEditingIngredients = false;
                                    _isEditingInstructions = false;
                                    _descriptionFocusNode.requestFocus();
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            _buildEditableField(
                              context,
                              label: 'Ingredientes',
                              isEditing: _isEditingIngredients,
                              focusNode: _ingredientsFocusNode,
                              controller: _ingredientsController,
                              onTap: () {
                                if (canEdit) {
                                  setState(() {
                                    _isEditingDescription = false;
                                    _isEditingIngredients = true;
                                    _isEditingInstructions = false;
                                    _ingredientsFocusNode.requestFocus();
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            _buildEditableField(
                              context,
                              label: 'Instrucciones',
                              isEditing: _isEditingInstructions,
                              focusNode: _instructionsFocusNode,
                              controller: _instructionsController,
                              onTap: () {
                                if (canEdit) {
                                  setState(() {
                                    _isEditingDescription = false;
                                    _isEditingIngredients = false;
                                    _isEditingInstructions = true;
                                    _instructionsFocusNode.requestFocus();
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                                    child: Icon(
                                      Icons.av_timer,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 40.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                    child: Text(
                                      snapshot.data!.preparationTime.toString(),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Readex Pro',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'min.',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!snapshot.data!.approval)
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Receta pendiente de aprobación',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
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
          bottomNavigationBar: isAdmin
              ? null
              : CommonBottomAppBar(
            selectedIndex: _selectedIndex,
            parentContext: context,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      BuildContext context, {
        required String label,
        required bool isEditing,
        required FocusNode focusNode,
        required TextEditingController controller,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300.0,
        height: 150.0,
        decoration: BoxDecoration(
          gradient: isEditing
              ? const LinearGradient(
            colors: [
              Color(0xFF8E5DB2),
              Color(0xFF7A2B9B),
            ],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          )
              : const LinearGradient(
            colors: [
              Color(0xFF7C4DA4),
              Color(0xFF6A1B9A),
            ],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.black,
            width: 3.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: isEditing
              ? Column(children: [Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                          fillColor: Colors.yellow,
                        ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondary,
                  ),
                  focusNode: focusNode,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Colors.yellow,
                ),
                onPressed: () async {
                  Map<String, dynamic> updates = {
                    'description': _descriptionController.text,
                    'ingredients': _ingredientsController.text,
                    'instructions': _instructionsController.text,
                  };
                  bool success = await widget.recipeController.updateRecipe(widget.recipeId, updates);
                  if (success) {
                    setState(() {
                      _isEditingDescription = false;
                      _isEditingIngredients = false;
                      _isEditingInstructions = false;
                    });
                    _recipeFuture = widget.recipeController.getRecipeById(widget.recipeId);
                    SnackbarMessages.showPositiveSnackbar(context, "Receta actualizada con éxito");
                  } else {
                    SnackbarMessages.showNegativeSnackbar(context, "Error al actualizar la receta");
                  }
                },
              ),
            ],
          )
              : Center(
            child: Text(
              controller.text.isNotEmpty ? controller.text : 'No hay $label',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: FlutterFlowTheme.of(context).secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
