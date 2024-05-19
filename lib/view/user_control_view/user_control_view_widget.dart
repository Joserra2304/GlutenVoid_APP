import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import '../../service/user_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'user_control_view_model.dart';
export 'user_control_view_model.dart';

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
    final users = await _userController.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
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
          title: Text('Registrar nuevo usuario'),
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
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Registrar'),
              onPressed: () async {
                UserModel newUser = UserModel(
                    id: 0,
                    name: _nameController.text,
                    surname: _surNameController.text,
                    username: _usernameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    isAdmin:
                    false);
                bool success = await _userController.registerUser(newUser);
                if (success) {
                  Navigator.of(context).pop();
                  _loadUsers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al registrar usuario.")));
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
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: <Widget>[
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

    if (result == true) {
      bool success = await _userController.deleteUser(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario eliminado con éxito')));
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar el usuario')));
      }
    }
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
              ? Center(child: Container())
              : SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._users.map((user) {
                      return Column(
                        children: [
                          FlipCard(
                            fill: Fill.fillBack,
                            direction: FlipDirection.HORIZONTAL,
                            speed: 400,
                            front: Container(
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Wrap(
                                spacing: 0.0,
                                runSpacing: 0.0,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                direction: Axis.horizontal,
                                runAlignment: WrapAlignment.start,
                                verticalDirection: VerticalDirection.down,
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 15.0, 0.0, 0.0),
                                    child: ListTile(
                                      leading: user.isAdmin
                                          ? Icon(
                                        Icons.admin_panel_settings,
                                        color: FlutterFlowTheme.of(context).tertiary,
                                        size: 30.0,
                                      )
                                          : Icon(
                                        Icons.person,
                                        color: FlutterFlowTheme.of(context).secondary,
                                        size: 30.0,
                                      ),
                                      title: Text(
                                        user.name,
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .override(
                                          fontFamily: 'Outfit',
                                          color: FlutterFlowTheme.of(context).secondary,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user.email,
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context).info,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.touch_app_outlined,
                                        color: FlutterFlowTheme.of(context).secondary,
                                        size: 30.0,
                                      ),
                                      dense: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            back: Container(
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
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  FlutterFlowIconButton(
                                    borderColor: FlutterFlowTheme.of(context).primary,
                                    borderRadius: 20.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(context).warning,
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      size: 24.0,
                                    ),
                                    onPressed: () {
                                      context.pushNamed("UserProfileView");
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: FlutterFlowTheme.of(context).primary,
                                    borderRadius: 20.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    fillColor: FlutterFlowTheme.of(context).error,
                                    icon: Icon(
                                      Icons.delete,
                                      color: FlutterFlowTheme.of(context).primaryText,
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

  void _reloadPage() {
    Navigator.pop(context);
    context.pushNamed("UserControlView");
  }
}

