import '../widget/snackbar_messages.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../controller/establishment_controller.dart';
import '../../model/establishment_model.dart';
import '../../service/user_service.dart';
import 'establishment_view_model.dart';
import 'package:go_router/go_router.dart';

class EstablishmentViewWidget extends StatefulWidget {
  final EstablishmentController establishmentController;

  const EstablishmentViewWidget(
      {super.key, required this.establishmentController});

  @override
  State<EstablishmentViewWidget> createState() =>
      _EstablishmentViewWidgetState();
}

class _EstablishmentViewWidgetState extends State<EstablishmentViewWidget> {
  late EstablishmentViewModel _model;
  final List<GlobalKey<FlipCardState>> _cardKeys = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EstablishmentViewModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _navigateToDetails(int establishmentId) async {
    context.pushNamed('EstablishmentDetailsView',
        queryParameters: {'id': establishmentId.toString()});
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que quieres eliminar este establecimiento?'),
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
                'Restaurantes',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).secondary,
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
                      Icons.map,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 24.0,
                    ),
                    onPressed: () {
                      context.pushNamed("MapView");
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: FutureBuilder<List<EstablishmentModel>>(
                future: widget.establishmentController.fetchEstablishments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error al cargar los establecimientos'));
                  } else {
                    var establishments = snapshot.data ?? [];
                    _cardKeys.clear();
                    for (int i = 0; i < establishments.length; i++) {
                      _cardKeys.add(GlobalKey<FlipCardState>());
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: establishments.length,
                      itemBuilder: (context, index) {
                        var establishment = establishments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Material(
                            color: Color(0xFF8E24AA),
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
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .accent3,
                                        FlutterFlowTheme.of(context)
                                            .accent4
                                      ],
                                      stops: [0.0, 1.0],
                                      begin:
                                      AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(22.0),
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
                                            establishment.name,
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                context)
                                                .titleLarge
                                                .override(
                                              fontFamily: 'Outfit',
                                              color:
                                              FlutterFlowTheme.of(
                                                  context)
                                                  .secondary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          subtitle: Text(
                                            establishment.address,
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(
                                                context)
                                                .labelMedium
                                                .override(
                                              fontFamily:
                                              'Readex Pro',
                                              color:
                                              FlutterFlowTheme.of(
                                                  context)
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
                                      FlutterFlowTheme.of(context)
                                          .accent4,
                                      FlutterFlowTheme.of(context)
                                          .accent4Dark,
                                    ],
                                    stops: [0.0, 1.0],
                                    begin:
                                    AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(22.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                    width: 2.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    FlutterFlowIconButton(
                                      borderColor:
                                      FlutterFlowTheme.of(context)
                                          .primary,
                                      borderRadius: 20.0,
                                      borderWidth: 1.0,
                                      buttonSize: 40.0,
                                      fillColor:
                                      FlutterFlowTheme.of(context)
                                          .warning,
                                      icon: Icon(
                                        Icons.remove_red_eye,
                                        color:
                                        FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () {
                                        _navigateToDetails(
                                            establishment.id);
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
                                        color:
                                        FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        bool confirmed =
                                        await _confirmDeletion();
                                        if (confirmed) {
                                          bool success = await widget
                                              .establishmentController
                                              .deleteEstablishment(
                                              establishment.id);
                                          if (success) {
                                            setState(() {
                                              establishments
                                                  .removeAt(index);
                                            });
                                            SnackbarMessages
                                                .showPositiveSnackbar(
                                                context,
                                                "Establecimiento eliminado con éxito");
                                          } else {
                                            SnackbarMessages
                                                .showNegativeSnackbar(
                                                context,
                                                "Error al eliminar el establecimiento");
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
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6A1B9A),
                                    Color(0xFF8E24AA),
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
                              child: ListTile(
                                title: Text(
                                  establishment.name,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                    fontFamily: 'Outfit',
                                    color:
                                    FlutterFlowTheme.of(context)
                                        .secondary,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                subtitle: Text(
                                  establishment.address,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color:
                                    FlutterFlowTheme.of(context)
                                        .secondary,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                tileColor: FlutterFlowTheme.of(context)
                                    .secondary,
                                dense: false,
                                onTap: () {
                                  _navigateToDetails(establishment.id);
                                },
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
      ),
    );
  }
}
