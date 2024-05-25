import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/establishment_controller.dart';
import '../../model/establishment_model.dart';
import '../../service/user_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'establishment_details_view_model.dart';

export 'establishment_details_view_model.dart';

class EstablishmentDetailsViewWidget extends StatefulWidget {
  final int establishmentId;
  final EstablishmentController establishmentController;

  const EstablishmentDetailsViewWidget({Key? key, required this.establishmentId, required this.establishmentController}) : super(key: key);

  @override
  State<EstablishmentDetailsViewWidget> createState() =>
      _EstablishmentDetailsViewWidgetState();
}

class _EstablishmentDetailsViewWidgetState extends State<EstablishmentDetailsViewWidget> {
  late EstablishmentDetailsViewModel _model;
  late Future<EstablishmentModel> _establishmentFuture;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EstablishmentDetailsViewModel());
    _establishmentFuture = widget.establishmentController.fetchEstablishmentDetails(widget.establishmentId);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<bool> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este establecimiento?'),
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

  Future<void> _showEditDialog(EstablishmentModel establishment) async {
    TextEditingController _name = TextEditingController(text: establishment.name);
    TextEditingController _description = TextEditingController(text: establishment.description);
    TextEditingController _telephone = TextEditingController(text: establishment.phoneNumber.toString());
    TextEditingController _address = TextEditingController(text: establishment.address);
    TextEditingController _city = TextEditingController(text: establishment.city);
    TextEditingController _glutenFreeOption = TextEditingController(text: establishment.glutenFreeOption.toString());

    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Restaurante"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _name, decoration: InputDecoration(labelText: 'Nombre del Restaurante')),
                TextField(controller: _description, decoration: InputDecoration(labelText: 'Descripción')),
                TextField(controller: _telephone, decoration: InputDecoration(labelText: 'Teléfono')),
                TextField(controller: _address, decoration: InputDecoration(labelText: 'Dirección')),
                TextField(controller: _city, decoration: InputDecoration(labelText: 'Ciudad')),
                TextField(controller: _glutenFreeOption, decoration: InputDecoration(labelText: '¿Opción Sin Gluten?')),
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
                  'name': _name.text,
                  'description': _description.text,
                  'phoneNumber': int.parse(_telephone.text),
                  'address': _address.text,
                  'city': _city.text,
                  'glutenFreeOption': _glutenFreeOption.text.toLowerCase() == 'sí',
                };
                bool success = await widget.establishmentController.updateEstablishmentDetails(establishment.id, updates);
                Navigator.of(context).pop(success);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        _establishmentFuture = widget.establishmentController.fetchEstablishmentDetails(widget.establishmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Establecimiento actualizado con éxito")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Actualización fallida")));
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
              context.pushNamed('RecipeView');
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
                          bool success = await widget.establishmentController.deleteEstablishment(widget.establishmentId);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Establecimiento eliminado con éxito')));
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar el establecimiento')));
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
                  return Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, -5.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(14.0, 10.0, 14.0, 5.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        establishment.name,
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 5.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        establishment.address,
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 5.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        establishment.city,
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 20.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        establishment.phoneNumber.toString(),
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                                    child: Container(
                                      width: 300.0,
                                      height: 125.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(10.0),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          establishment.description,
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
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
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                  child: Text(
                                    'Opción sin GLUTEN',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        establishment.glutenFreeOption ? 'SI' : 'NO',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context).secondary,
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
    );
  }
}
