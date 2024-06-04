import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/establishment_model.dart';
import '../service/establishment_service.dart';


class MapController {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final EstablishmentService establishmentService;

  MapController(this.establishmentService);

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<Set<Marker>> loadMarkers() async {
    try {
      List<EstablishmentModel> establishments = await establishmentService.loadEstablishments();

      _markers.clear();

      for (var establishment in establishments) {
        Marker marker = Marker(
          markerId: MarkerId(establishment.id.toString()),
          position: LatLng(establishment.latitude, establishment.longitude),
          infoWindow: InfoWindow(title: establishment.name, snippet: establishment.description),
        );
        _markers.add(marker);
      }
    } catch (e) {
      print("Error al cargar marcadores: $e");
    }

    return _markers;
  }


  Future<void> searchAndUpdateLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty && _mapController != null) {
        Location location = locations.first;
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 20.0,
          ),
        ));
      }
    } catch (e) {
      print("Error al buscar la dirección: $e");
    }
  }
}






