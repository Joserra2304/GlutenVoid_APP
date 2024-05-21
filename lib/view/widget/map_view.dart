import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controller/establishment_controller.dart';
import '../../controller/map_controller.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../model/establishment_model.dart';
import '../../service/glutenvoid_api_service.dart';
import '../../service/user_service.dart';

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
    /*Navigator.push(context, MaterialPageRoute(
      builder: (context) => EstablishmentDetailsView(
        establishmentId: id,
        establishmentController: widget.establishmentController,
      ),
    )).then((deleted) {
      if (deleted == true) {  // Si la eliminación fue exitosa
        loadEstablishmentMarkers();  // Recarga los marcadores para reflejar la eliminación
      }
    });*/
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
    TextEditingController _rating = TextEditingController();
    TextEditingController _glutenFreeOption = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información del Restaurante'),
          content: SingleChildScrollView( // Asegura que todo el contenido sea visible cuando el teclado aparezca
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: _name, decoration: InputDecoration(labelText: 'Nombre del Restaurante')),
                TextField(controller: _description, decoration: InputDecoration(labelText: 'Descripción')),
                TextField(controller: _telephone, decoration: InputDecoration(labelText: 'Teléfono')),
                TextField(controller: _address, decoration: InputDecoration(labelText: 'Dirección')),
                TextField(controller: _city, decoration: InputDecoration(labelText: 'Ciudad')),
                TextField(controller: _rating, decoration: InputDecoration(labelText: 'Calificación')),
                TextField(controller: _glutenFreeOption, decoration: InputDecoration(labelText: '¿Opción Sin Gluten?')),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                bool glutenFree = _glutenFreeOption.text.toLowerCase() == 'sí' || _glutenFreeOption.text.toLowerCase() == 'si';
                EstablishmentModel newEstablishment = EstablishmentModel(
                  id: 0, // ID se maneja en el backend
                  name: _name.text,
                  description: _description.text,
                  phoneNumber: int.tryParse(_telephone.text) ?? 0,
                  address: _address.text,
                  city: _city.text,
                  latitude: point.latitude,
                  longitude: point.longitude,
                  rating: double.tryParse(_rating.text) ?? 0.0,
                  glutenFreeOption: glutenFree,
                );

                bool result = await widget.establishmentController.registerEstablishment(newEstablishment);
                if (result) {
                  setState(() {
                    markers.add(
                      Marker(
                        markerId: MarkerId(point.toString()),
                        position: point,
                        infoWindow: InfoWindow(title: _name.text, snippet: "pulsa para más detalles"),
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Establecimiento guardado con éxito!")));
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar el establecimiento.")));
                }
              },
            ),
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).info,
      appBar: AppBar(

        title: Text('Mapa de restaurantes',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        actions: [
          IconButton(
              icon: Icon(Icons.list, color: Color(0xFFe9d7ac)),
              onPressed: () {
                // Aquí pasas el controlador y el estado del admin al 'EstablishmentsView'
                /* Navigator.push(context, MaterialPageRoute(
                builder: (context) => EstablishmentsView(
                  establishmentController: EstablishmentController(EstablishmentService(GlutenVoidApi())),
                ),
              ));*/
              }
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
    );
  }
}




