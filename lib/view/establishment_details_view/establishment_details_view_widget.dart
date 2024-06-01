import 'package:flutter/material.dart';
import 'package:glutenvoid_app/view/widget/snackbar_messages.dart';
import '../../controller/establishment_controller.dart';
import '../../model/establishment_model.dart';
import '../../service/user_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'establishment_details_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

export 'establishment_details_view_model.dart';

class EstablishmentDetailsViewWidget extends StatefulWidget {
  final int establishmentId;
  final EstablishmentController establishmentController;

  const EstablishmentDetailsViewWidget(
      {Key? key,
      required this.establishmentId,
      required this.establishmentController})
      : super(key: key);

  @override
  State<EstablishmentDetailsViewWidget> createState() =>
      _EstablishmentDetailsViewWidgetState();
}

class _EstablishmentDetailsViewWidgetState
    extends State<EstablishmentDetailsViewWidget> {
  late EstablishmentDetailsViewModel _model;
  late Future<EstablishmentModel> _establishmentFuture;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _glutenFreeOption = false;
  bool _isEditingDescription = false;

  TextEditingController _descriptionController = TextEditingController();
  FocusNode _descriptionFocusNode = FocusNode();
  gmaps.GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EstablishmentDetailsViewModel());
    _establishmentFuture = widget.establishmentController
        .fetchEstablishmentDetails(widget.establishmentId);
    _establishmentFuture.then((establishment) {
      if (establishment != null) {
        _descriptionController.text = establishment.description;
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _showEditDialog(EstablishmentModel establishment) async {
    TextEditingController _name =
        TextEditingController(text: establishment.name);
    TextEditingController _telephone =
        TextEditingController(text: establishment.phoneNumber.toString());
    TextEditingController _address =
        TextEditingController(text: establishment.address);
    TextEditingController _city =
        TextEditingController(text: establishment.city);
    _glutenFreeOption = establishment.glutenFreeOption;

    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF7C4DA4),
              title: const Text(
                "Editar Restaurante",
                style: TextStyle(color: Colors.yellow),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Restaurante',
                        labelStyle: TextStyle(color: Colors.yellow),
                      ),
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary),
                    ),
                    TextField(
                      controller: _telephone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: TextStyle(color: Colors.yellow),
                      ),
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary),
                    ),
                    TextField(
                      controller: _address,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        labelStyle: TextStyle(color: Colors.yellow),
                      ),
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary),
                    ),
                    TextField(
                      controller: _city,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        labelStyle: TextStyle(color: Colors.yellow),
                      ),
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('¿Opción Sin Gluten?',
                              style: TextStyle(color: Colors.yellow)
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _glutenFreeOption = !_glutenFreeOption;
                              });
                            },
                            child: Container(
                              width: 40.0, // Smaller width
                              height: 25.0, // Smaller height
                              decoration: BoxDecoration(
                                color: _glutenFreeOption
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(
                                    12.5), // Smaller radius
                              ),
                              child: Align(
                                alignment: _glutenFreeOption
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20.0, // Smaller width
                                  height: 20.0, // Smaller height
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Smaller radius
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar',
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Guardar Cambios',
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondary)),
                  onPressed: () async {
                    Map<String, dynamic> updates = {
                      'name': _name.text,
                      'phoneNumber': int.parse(_telephone.text),
                      'address': _address.text,
                      'city': _city.text,
                      'glutenFreeOption': _glutenFreeOption,
                    };
                    bool success = await widget.establishmentController
                        .updateEstablishmentDetails(establishment.id, updates);
                    Navigator.of(context).pop(success);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _establishmentFuture = widget.establishmentController
            .fetchEstablishmentDetails(widget.establishmentId);
      });
      SnackbarMessages.showPositiveSnackbar(
          context, "Establecimiento actualizado con éxito");
    } else {
      SnackbarMessages.showNegativeSnackbar(
          context, "Error al actualizar el establecimiento");
    }
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF7C4DA4), // Color morado claro
          title: Text('Confirmar eliminación',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondary)),
          content: Text(
              '¿Estás seguro de que quieres eliminar este establecimiento?',
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

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingDescription = false;
        });
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
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
              onPressed: () async {
                context.pushNamed('EstablishmentView');
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalles del restaurante',
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
                        fillColor: FlutterFlowTheme.of(context).primary,
                        icon: Icon(
                          Icons.edit,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 24.0,
                        ),
                        onPressed: () {
                          _establishmentFuture.then((establishment) {
                            _showEditDialog(establishment);
                          });
                        },
                      ),
                    if (userService.isAdmin)
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
                            bool success = await widget.establishmentController
                                .deleteEstablishment(widget.establishmentId);
                            if (success) {
                              SnackbarMessages.showPositiveSnackbar(
                                  context, "Establecimiento borrado con éxito");
                              context.pushNamed("EstablishmentView");
                            } else {
                              SnackbarMessages.showNegativeSnackbar(context,
                                  "Error al eliminar el establecimiento");
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
            child: FutureBuilder<EstablishmentModel>(
              future: _establishmentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    EstablishmentModel establishment = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20.0),
                          // Espacio entre el AppBar y el contenido
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, -5.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      14.0, 10.0, 14.0, 5.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          establishment.name,
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                fontSize: 22.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, -5.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      14.0, 0.0, 14.0, 5.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          establishment.address,
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                fontSize: 22.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, -5.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      14.0, 0.0, 14.0, 5.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          establishment.city,
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                fontSize: 22.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, -5.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      14.0, 0.0, 14.0, 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          establishment.phoneNumber.toString(),
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                fontSize: 22.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(14.0),
                                child: _buildEditableField(
                                  context,
                                  label: 'Descripción',
                                  isEditing: _isEditingDescription,
                                  focusNode: _descriptionFocusNode,
                                  controller: _descriptionController,
                                  onTap: () {
                                    setState(() {
                                      _isEditingDescription = true;
                                      _descriptionFocusNode.requestFocus();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 6.0),
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 5.0, 0.0),
                                    child: Text(
                                      'Opción sin GLUTEN',
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
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5.0, 0.0, 0.0, 0.0),
                                    child: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: establishment.glutenFreeOption
                                            ? FlutterFlowTheme.of(context)
                                                .success
                                            : FlutterFlowTheme.of(context)
                                                .error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          establishment.glutenFreeOption
                                              ? 'SI'
                                              : 'NO',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(125.0),
                                // More circular shape
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(125.0),
                                // More circular shape
                                child: gmaps.GoogleMap(
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _mapController!.animateCamera(
                                      gmaps.CameraUpdate.newLatLngZoom(
                                        gmaps.LatLng(establishment.latitude,
                                            establishment.longitude),
                                        15,
                                      ),
                                    );
                                  },
                                  initialCameraPosition: gmaps.CameraPosition(
                                    target: gmaps.LatLng(establishment.latitude,
                                        establishment.longitude),
                                    zoom: 15,
                                  ),
                                  markers: {
                                    gmaps.Marker(
                                      markerId: gmaps.MarkerId(
                                          establishment.id.toString()),
                                      position: gmaps.LatLng(
                                          establishment.latitude,
                                          establishment.longitude),
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
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
                    Color(0xFF8E5DB2), // Un poco más claro que el fondo morado
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
              ? Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: label,
                          fillColor: FlutterFlowTheme.of(context).secondary,
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
                        };
                        bool success = await widget.establishmentController
                            .updateEstablishmentDetails(
                                widget.establishmentId, updates);
                        if (success) {
                          setState(() {
                            _isEditingDescription = false;
                          });
                          _establishmentFuture = widget.establishmentController
                              .fetchEstablishmentDetails(
                                  widget.establishmentId);
                          SnackbarMessages.showPositiveSnackbar(
                              context, "Descripción actualizada con éxito");
                        } else {
                          SnackbarMessages.showNegativeSnackbar(
                              context, "Error al actualizar la descripción");
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'No hay $label',
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
