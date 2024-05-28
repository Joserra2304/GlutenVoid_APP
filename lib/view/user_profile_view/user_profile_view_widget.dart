import 'package:flutter/material.dart';
import 'package:glutenvoid_app/controller/user_controller.dart';
import 'package:glutenvoid_app/service/user_service.dart';
import '../widget/bottom_app_bar.dart';
import '../widget/snackbar_messages.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'user_profile_view_model.dart';
import '../../model/user_model.dart';
import '../../model/recipe_model.dart';

class UserProfileViewWidget extends StatefulWidget {
  final int userId;

  const UserProfileViewWidget({super.key, required this.userId});

  @override
  State<UserProfileViewWidget> createState() => _UserProfileViewWidgetState();
}

class _UserProfileViewWidgetState extends State<UserProfileViewWidget> {
  late UserProfileViewModel _model;
  UserModel? _user;
  late UserController userController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isEditingBio = false;
  TextEditingController _profileBioController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  final List<String> glutenConditions = ['Alergia', 'Celiaquia', 'Sensibilidad', 'Ninguna'];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileViewModel());
    userController = UserController(UserService());
    _loadUser();
  }

  @override
  void dispose() {
    _model.dispose();
    _profileBioController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = await userController.getUserById(widget.userId, context);
      setState(() {
        _user = user;
        _profileBioController.text = user.profileBio ?? '';
      });
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _showEditUserDialog(UserModel user) async {
    TextEditingController _nameController = TextEditingController(text: user.name);
    TextEditingController _surnameController = TextEditingController(text: user.surname);

    GlutenCondition? _selectedCondition = user.glutenCondition;

    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF7C4DA4),
              title: Text(
                "Editar Usuario",
                style: TextStyle(color: Colors.yellow),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(labelText: 'Apellido'),
                    ),
                    DropdownButtonFormField<GlutenCondition>(
                      value: _selectedCondition,
                      items: GlutenCondition.values.map((GlutenCondition condition) {
                        return DropdownMenuItem<GlutenCondition>(
                          value: condition,
                          child: Text(condition.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (GlutenCondition? newValue) {
                        setState(() {
                          _selectedCondition = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Condición de Gluten'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Guardar Cambios', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () async {
                    Map<String, dynamic> updates = {
                      'name': _nameController.text,
                      'surname': _surnameController.text,
                      'glutenCondition': _selectedCondition.toString().split('.').last,
                    };
                    print('Saving updates: $updates'); // Registro para depuración
                    bool success = await userController.updateUser(user.id!, updates, context);
                    Navigator.of(context).pop(success);
                    if (success) {
                      _loadUser();
                      SnackbarMessages.showPositiveSnackbar(context, "Usuario actualizado con éxito");
                    } else {
                      SnackbarMessages.showNegativeSnackbar(context, "Error al actualizar usuario");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _loadUser();
    }
  }

  Future<void> _confirmDeletion(int userId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          backgroundColor: Color(0xFF7C4DA4),
        );
      },
    );

    if (result == true) {
      bool success = await userController.deleteUser(userId, context);
      if (success) {
        SnackbarMessages.showPositiveSnackbar(context, "Éxito al eliminar usuario");
      } else {
        SnackbarMessages.showNegativeSnackbar(context, "Error al eliminar usuario");
      }
    }
  }

  Widget buildRecipeItem(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('RecipeDetailsView', queryParameters: {'id': recipe.id.toString()});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
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
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  recipe.ingredients,
                  style: TextStyle(
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService().currentUser;
    final bool isViewingOwnProfile = currentUser != null && currentUser.id == widget.userId;
    final bool isAdmin = currentUser?.isAdmin ?? false;

    return GestureDetector(
      onTap: () {
        if (_isEditingBio) {
          setState(() {
            _isEditingBio = false;
          });
        } else {
          _model.unfocusNode.canRequestFocus
              ? FocusScope.of(context).requestFocus(_model.unfocusNode)
              : FocusScope.of(context).unfocus();
        }
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
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              if (isViewingOwnProfile && !isAdmin) {
                context.go('/userView');
              } else {
                context.go('/userControlView');
              }
            },
          ),
          title: Text(
            isViewingOwnProfile && !isAdmin ? 'Mi perfil sin gluten' : 'Perfil del usuario',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 18.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: isAdmin
              ? [
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
                if (_user != null) {
                  _showEditUserDialog(_user!);
                }
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
              onPressed: () {
                if (_user != null) {
                  _confirmDeletion(_user!.id!);
                }
              },
            ),
          ]
              : [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _user == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                              child: Container(
                                width: 325.0,
                                decoration: BoxDecoration(
                                  color: Colors.purple[700],
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(width: 1.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _user!.username,
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context).labelMedium.override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context).secondary,
                                          fontSize: 30.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        _user!.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                        color: FlutterFlowTheme.of(context).secondary,
                                        size: 30.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 6.0),
                          child: Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Condición: ',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _user!.glutenCondition.toString().split('.').last,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isAdmin)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Admin',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 16.0,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: _user!.isAdmin ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Switch(
                                  value: _user!.isAdmin,
                                  onChanged: (bool value) async {
                                    setState(() {
                                      _user = UserModel(
                                        id: _user!.id,
                                        name: _user!.name,
                                        surname: _user!.surname,
                                        email: _user!.email,
                                        username: _user!.username,
                                        password: _user!.password,
                                        profileBio: _user!.profileBio,
                                        glutenCondition: _user!.glutenCondition,
                                        isAdmin: value,
                                        recipes: _user!.recipes,
                                      );
                                    });
                                    // Save the new state using UserController
                                    Map<String, dynamic> updates = {
                                      'admin': value, // Cambia 'isAdmin' a 'admin'
                                    };
                                    print('Attempting to update user with: $updates');
                                    bool success = await userController.updateUser(_user!.id!, updates, context);
                                    if (!success) {
                                      setState(() {
                                        _user = UserModel(
                                          id: _user!.id,
                                          name: _user!.name,
                                          surname: _user!.surname,
                                          email: _user!.email,
                                          username: _user!.username,
                                          password: _user!.password,
                                          profileBio: _user!.profileBio,
                                          glutenCondition: _user!.glutenCondition,
                                          isAdmin: !value,
                                          recipes: _user!.recipes,
                                        );
                                      });
                                      SnackbarMessages.showNegativeSnackbar(context, "Error al actualizar estado de admin");
                                    } else {
                                      SnackbarMessages.showPositiveSnackbar(context, "Estado de admin actualizado con éxito");
                                    }
                                  },
                                  activeColor: Colors.green, // Color del switch activo
                                  inactiveThumbColor: Colors.red, // Color del switch inactivo
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: FFButtonWidget(
                            onPressed: () {
                              if (_user != null) {
                                context.go('/userRecipesView?userId=${_user!.id}');
                              } else {
                                SnackbarMessages.showNegativeSnackbar(
                                    context, "Este usuario no tiene recetas agregadas");
                              }
                            },
                            text: 'Ver Recetas',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                              color: Colors.purple[700],
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                              elevation: 3.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingBio = true;
                                _focusNode.requestFocus();
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
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
                                child: _isEditingBio
                                    ? Column(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _profileBioController,
                                        maxLines: null,
                                        expands: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Rellena tu biografía',
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context).secondary,
                                        ),
                                        focusNode: _focusNode,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.save,
                                        color: Colors.yellow,
                                      ),
                                      onPressed: () async {
                                        Map<String, dynamic> updates = {
                                          'profileBio': _profileBioController.text,
                                        };
                                        bool success = await userController.updateUser(_user!.id!, updates, context);
                                        if (success) {
                                          setState(() {
                                            _isEditingBio = false;
                                          });
                                          _loadUser();
                                          SnackbarMessages.showPositiveSnackbar(context, "Bio actualizado con éxito");
                                        } else {
                                          SnackbarMessages.showNegativeSnackbar(context, "Error al actualizar bio");
                                        }
                                      },
                                    ),
                                  ],
                                )
                                    : Center(
                                  child: Text(
                                    _user!.profileBio ?? 'Sin información',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      color: FlutterFlowTheme.of(context).secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (currentUser != null && !isAdmin)
                          Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FFButtonWidget(
                                  onPressed: () {
                                    if (_user != null) {
                                      _showEditUserDialog(_user!);
                                    }
                                  },
                                  text: 'Editar perfil',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    color: Colors.purple[700],
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FFButtonWidget(
                                  onPressed: () {
                                    if (_user != null) {
                                      _confirmDeletion(_user!.id!);
                                    }
                                  },
                                  text: 'Eliminar cuenta',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).error,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
