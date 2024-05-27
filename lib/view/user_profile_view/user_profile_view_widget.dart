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
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = await userController.getUserById(widget.userId);
      setState(() {
        _user = user;
      });
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _showEditUserDialog(UserModel user) async {
    TextEditingController _nameController = TextEditingController(text: user.name);
    TextEditingController _surnameController = TextEditingController(text: user.surname);
    TextEditingController _emailController = TextEditingController(text: user.email);
    TextEditingController _usernameController = TextEditingController(text: user.username);
    TextEditingController _profileBioController = TextEditingController(text: user.profileBio);

    GlutenCondition? _selectedCondition = user.glutenCondition;

    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Editar Usuario"),
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
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Correo electrónico'),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Nombre de usuario'),
                    ),
                    TextField(
                      controller: _profileBioController,
                      decoration: InputDecoration(labelText: 'Bio'),
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
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Guardar Cambios'),
                  onPressed: () async {
                    Map<String, dynamic> updates = {
                      'name': _nameController.text,
                      'surname': _surnameController.text,
                      'email': _emailController.text,
                      'username': _usernameController.text,
                      'profileBio': _profileBioController.text,
                      'glutenCondition': _selectedCondition.toString().split('.').last,
                    };
                    print('Saving updates: $updates'); // Registro para depuración
                    bool success = await userController.updateUser(user.id!, updates);
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
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      bool success = await userController.deleteUser(userId);
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
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
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
              : Padding(
            padding: EdgeInsets.all(14.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                color: FlutterFlowTheme.of(context).primary,
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
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                              child: Text(
                                'Condición:',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 25.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
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
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                child: Text(
                                  _user!.glutenCondition.toString().split('.').last,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                  bool success = await userController.updateUser(_user!.id!, updates);
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
                            color: FlutterFlowTheme.of(context).primary,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                              child: Container(
                                width: 300.0,
                                height: 200.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(width: 1.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    _user!.profileBio ?? 'No hay nada de información',
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: FlutterFlowTheme.of(context).secondary,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentUser != null && !isAdmin)
                        Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
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
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
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
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
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
