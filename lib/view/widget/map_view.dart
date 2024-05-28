import 'package:flutter/material.dart';
import 'package:glutenvoid_app/view/widget/snackbar_messages.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/establishment_controller.dart';
import '../../controller/map_controller.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../model/establishment_model.dart';
import '../../service/user_service.dart';
import 'bottom_app_bar.dart';

class MapView extends StatefulWidget {
  final MapController mapController;
  final EstablishmentController establishmentController;

  MapView({required this.mapController, required this.establishmentController});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _addressController = TextEditingController();
  Set<Marker> markers = {};
  int _selectedIndex = 0;
  bool _glutenFreeOption = false;

  void _onMapCreated(GoogleMapController controller) {
    widget.mapController.setMapController(controller);
    loadEstablishmentMarkers();
  }

  Future<void> loadEstablishmentMarkers() async {
    var newMarkers = await widget.establishmentController.loadMarkers(openEstablishmentDetails);
    setState(() {
      markers = newMarkers;
    });
  }

  void openEstablishmentDetails(int id) {
    context.pushNamed(
      'EstablishmentDetailsView',
      queryParameters: {'id': id.toString()},
    );
  }

  void _handleTap(LatLng point) {
    if (UserService().isAdmin) {
      _showMarkerInfoDialog(point);
    }
  }

  void _showMarkerInfoDialog(LatLng point) {
    TextEditingController _name = TextEditingController();
    TextEditingController _description = TextEditingController();
    TextEditingController _telephone = TextEditingController();
    TextEditingController _address = TextEditingController();
    TextEditingController _city = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Información del Restaurante'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(controller: _name, decoration: InputDecoration(labelText: 'Nombre del Restaurante')),
                    TextField(controller: _description, decoration: InputDecoration(labelText: 'Descripción')),
                    TextField(controller: _telephone, decoration: InputDecoration(labelText: 'Teléfono')),
                    TextField(controller: _address, decoration: InputDecoration(labelText: 'Dirección')),
                    TextField(controller: _city, decoration: InputDecoration(labelText: 'Ciudad')),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0), // Add top margin
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('¿Opción Sin Gluten?'),
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
                                color: _glutenFreeOption ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12.5), // Smaller radius
                              ),
                              child: Align(
                                alignment: _glutenFreeOption ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  width: 20.0, // Smaller width
                                  height: 20.0, // Smaller height
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.circular(10.0), // Smaller radius
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
              actions: <Widget>[
                TextButton(
                  child: Text('Guardar'),
                  onPressed: () async {
                    bool glutenFree = _glutenFreeOption;
                    EstablishmentModel newEstablishment = EstablishmentModel(
                      id: 0, // ID se maneja en el backend
                      name: _name.text,
                      description: _description.text,
                      phoneNumber: int.tryParse(_telephone.text) ?? 0,
                      address: _address.text,
                      city: _city.text,
                      latitude: point.latitude,
                      longitude: point.longitude,
                      glutenFreeOption: glutenFree,
                    );

                    bool result = await widget.establishmentController.registerEstablishment(newEstablishment);
                    if (result) {
                      setState(() {
                        markers.add(
                          Marker(
                            markerId: MarkerId(point.toString()),
                            position: point,
                            infoWindow: InfoWindow(
                              title: _name.text,
                              snippet: "Pulsa para más detalles",
                              onTap: () => openEstablishmentDetails(newEstablishment.id),
                            ),
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                      SnackbarMessages.showPositiveSnackbar(context, "Establecimiento guardado con éxito");
                    } else {
                      Navigator.of(context).pop();
                      SnackbarMessages.showNegativeSnackbar(context, "Error al guardar el establecimiento");
                    }
                  },
                ),
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) => loadEstablishmentMarkers());
  }

  Future<void> loadMarkers() async {
    var newMarkers = await widget.mapController.loadMarkers();
    setState(() {
      markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = UserService().isAdmin;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Mapa de restaurantes',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Outfit',
            color: FlutterFlowTheme.of(context).secondary,
            fontSize: 22.0,
            letterSpacing: 0.0,
          ),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        actions: [
          IconButton(
            icon: Icon(Icons.list, color:FlutterFlowTheme.of(context).secondary),
            onPressed: () {
              context.go("/establishmentView");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _addressController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar dirección',
                hintStyle: TextStyle(color: Colors.black),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Borde negro
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Borde negro cuando está habilitado
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () => widget.mapController.searchAndUpdateLocation(_addressController.text),
                ),
              ),
              onSubmitted: (value) => widget.mapController.searchAndUpdateLocation(value),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(41.65606, -0.87734),
                zoom: 14,
              ),
              onTap: _handleTap,
              markers: markers,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isAdmin
          ? null
          : CommonBottomAppBar(
        selectedIndex: _selectedIndex,
        parentContext: context,
      ),
    );
  }
}
