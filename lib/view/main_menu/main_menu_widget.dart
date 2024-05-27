import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:glutenvoid_app/view/register_view/register_view_widget.dart';
import 'package:glutenvoid_app/view/widget/snackbar_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/user_controller.dart';
import '../../model/user_model.dart';
import '../../service/glutenvoid_api_service.dart';
import '../../service/user_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_menu_model.dart';
export 'main_menu_model.dart';

class MainMenuWidget extends StatefulWidget {
  const MainMenuWidget({super.key});

  @override
  State<MainMenuWidget> createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  late MainMenuModel _model;
  late UserService _userService;
  late UserController _loginController;
  late GlutenVoidApi _glutenVoidApi;
  String _errorMessage = '';
  bool _isLoading = false;
  bool showRegisterPage = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainMenuModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _glutenVoidApi = GlutenVoidApi();
    _userService = UserService();
    _loginController = UserController(_userService);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTokenExpiry(context);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _login() async {
    if (_model.textController1!.text.isEmpty || _model.textController2!.text.isEmpty) {
      _showErrorMessage('Por favor ingrese usuario y contraseña');
      SnackbarMessages.showWarningSnackbar(context, "Por favor ingrese usuario y contraseña");
      return;
    }

    _showLoading(true);

    try {
      final UserModel? user = await _loginController.attemptLogin(
        _model.textController1!.text,
        _model.textController2!.text,
        context,
      );
      if (user != null) {
        navigateBasedOnUserRole(user, context);
        SnackbarMessages.showPositiveSnackbar(context, "Bienvenido/a, ${user.name}");
      } else {
        _showErrorMessage("Usuario o contraseña incorrectos");
        SnackbarMessages.showNegativeSnackbar(context, "Usuario o contraseña incorrectos");
      }
    } catch (e) {
      _showErrorMessage("Error durante el inicio de sesión: $e");
      SnackbarMessages.showNegativeSnackbar(context, "Error durante el inicio de sesión");
    } finally {
      _showLoading(false);
    }
  }

  void checkTokenExpiry(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int? expiryTime = prefs.getInt('tokenExpiryTime');
    if (expiryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo recuperar el tiempo de expiración del token."), backgroundColor: Colors.red)

      );
      print("No se pudo recuperar el tiempo de expiración del token");
      return;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int timeLeft = expiryTime - currentTime;
    if (timeLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."), backgroundColor: Colors.red)

      );
      print("Sesion expirada");
    } else {
      int minutesLeft = timeLeft ~/ 60000;
      int secondsLeft = (timeLeft % 60000) ~/ 1000;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              "Tu sesión expirará en $minutesLeft minutos y $secondsLeft segundos."), backgroundColor: Colors.blue)

      );
      print("Sesion expirará en $minutesLeft minutos y $secondsLeft segundos.");
    }
  }

  void navigateBasedOnUserRole(UserModel user, BuildContext context) {
    if (user.isAdmin) {
      context.pushNamed('AdminView');
    } else {
      context.pushNamed('UserView');
    }
  }

  Future<bool> _onWillPop() async {
    FlutterExitApp.exitApp();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            title: Text(
              'Gluten Void',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22.0,
                letterSpacing: 0.0,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 2.0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEDE7F6), Color(0xFF9575CD)], // Gradiente claro a más oscuro
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: true,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/gluten_void_logo.png',
                          width: double.infinity,
                          height: 262.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                              child: TextFormField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode1,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Usuario',
                                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                                  alignLabelWithHint: true,
                                  hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).primary,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                                textAlign: TextAlign.start,
                                validator: _model.textController1Validator.asValidator(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                              child: TextFormField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                autofocus: false,
                                obscureText: !_model.passwordVisibility,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                                  alignLabelWithHint: true,
                                  hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  suffixIcon: InkWell(
                                    onTap: () => setState(() => _model.passwordVisibility = !_model.passwordVisibility),
                                    focusNode: FocusNode(skipTraversal: true),
                                    child: Icon(
                                      _model.passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                                validator: _model.textController2Validator.asValidator(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FFButtonWidget(
                                onPressed: _login,
                                text: 'Acceder',
                                options: FFButtonOptions(
                                  width: 160.0,
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Colors.purple[700],
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                                  elevation: 20.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed("RegisterView");
                                },
                                text: 'Registrarse',
                                options: FFButtonOptions(
                                  width: 160,
                                  height: 40,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24, 0, 24, 0),
                                  iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  color: Colors.purple[700],
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    letterSpacing: 0,
                                  ),
                                  elevation: 20,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ].divide(SizedBox(height: 30.0)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}
