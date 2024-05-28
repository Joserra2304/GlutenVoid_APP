import '../widget/snackbar_messages.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import '../../service/user_service.dart';
import 'user_control_view_model.dart';
import 'package:go_router/go_router.dart';

class UserControlViewWidget extends StatefulWidget {
  const UserControlViewWidget({super.key});

  @override
  State<UserControlViewWidget> createState() => _UserControlViewWidgetState();
}

class _UserControlViewWidgetState extends State<UserControlViewWidget> {
  late UserControlViewModel _model;
  late List<UserModel> _users;
  late UserController _userController;
  bool _isLoading = true;
  final List<GlobalKey<FlipCardState>> _cardKeys = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserControlViewModel());
    _userController = UserController(UserService());
    _loadUsers();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    final users = await _userController.getUsers(context);
    setState(() {
      _users = users;
      _isLoading = false;
      _cardKeys.clear();
      for (int i = 0; i < users.length; i++) {
        _cardKeys.add(GlobalKey<FlipCardState>());
      }
    });
  }

  void _showAddUserDialog() {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _surNameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4),
          title: const Text('Registrar nuevo usuario',
              style: TextStyle(color: Colors.yellow)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: "Nombre")),
                TextField(
                    controller: _surNameController,
                    decoration: InputDecoration(hintText: "Apellido")),
                TextField(
                    controller: _emailController,
                    decoration:
                        InputDecoration(hintText: "Correo electrónico")),
                TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(hintText: "Nombre de usuario")),
                TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(hintText: "Contraseña")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Registrar',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).secondary)),
              onPressed: () async {
                UserModel newUser = UserModel(
                    id: 0,
                    name: _nameController.text,
                    surname: _surNameController.text,
                    username: _usernameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    isAdmin: false);
                bool success = await _userController.registerUser(newUser, context);
                if (success) {
                  SnackbarMessages.showPositiveSnackbar(
                      context, "Éxito al registrar usuario");
                  Navigator.of(context).pop();
                  _loadUsers();
                } else {
                  SnackbarMessages.showNegativeSnackbar(
                      context, "Error al registrar en el registro");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeletion(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4), // Color morado claro
          title: Text('Confirmar eliminación',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          content: Text('¿Estás seguro de que quieres eliminar este usuario?',
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
      bool success = await _userController.deleteUser(id, context);
      if (success) {
        setState(() {
          _users.removeWhere((user) => user.id == id);
          _loadUsers();
        });
        SnackbarMessages.showPositiveSnackbar(
            context, "Usuario eliminado con éxito");
      } else {
        SnackbarMessages.showNegativeSnackbar(
            context, "Error al eliminar el usuario");
      }
    }
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pushNamed('AdminView');
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configurar usuarios',
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
                  if (userService.isAdmin)
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 0.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.add,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _showAddUserDialog();
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._users.map((user) {
                            int index = _users.indexOf(user);
                            return Column(
                              children: [
                                FlipCard(
                                  key: _cardKeys[index],
                                  fill: Fill.fillBack,
                                  direction: FlipDirection.HORIZONTAL,
                                  speed: 400,
                                  front: GestureDetector(
                                    onTap: () => _flipCard(index),
                                    child: Container(
                                      width: double.infinity,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6A1B9A),
                                            Color(0xFF8E24AA),
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      child: Wrap(
                                        spacing: 0.0,
                                        runSpacing: 0.0,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        runAlignment: WrapAlignment.start,
                                        verticalDirection:
                                            VerticalDirection.down,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 15.0, 0.0, 0.0),
                                            child: ListTile(
                                              leading: user.isAdmin
                                                  ? Icon(
                                                      Icons
                                                          .admin_panel_settings,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .warning,
                                                      size: 30.0,
                                                    )
                                                  : Icon(
                                                      Icons.person,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .successLight,
                                                      size: 30.0,
                                                    ),
                                              title: Text(
                                                user.name,
                                                style:
                                                    FlutterFlowTheme.of(context)
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
                                                user.email,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelMedium
                                                    .override(
                                                      fontFamily: 'Readex Pro',
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              trailing: Icon(
                                                Icons.touch_app_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                size: 30.0,
                                              ),
                                              dense: false,
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
                                          Color(0xFF7B1FA2),
                                          Color(0xFF9C27B0),
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(0.0, -1.0),
                                        end: AlignmentDirectional(0, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        FlutterFlowIconButton(
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                          borderRadius: 20.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .warning,
                                          icon: Icon(
                                            Icons.remove_red_eye,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () {
                                            GoRouter.of(context).goNamed(
                                                'UserProfileView',
                                                queryParameters: {
                                                  'id': user.id.toString()
                                                });
                                          },
                                        ),
                                        FlutterFlowIconButton(
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          borderRadius: 20.0,
                                          borderWidth: 1.0,
                                          buttonSize: 40.0,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .error,
                                          icon: Icon(
                                            Icons.delete,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () {
                                            _confirmDeletion(user.id!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
