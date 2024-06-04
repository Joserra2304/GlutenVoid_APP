import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/establishment_model.dart';
import '../service/establishment_service.dart';


class EstablishmentController {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final EstablishmentService establishmentService;
  List<EstablishmentModel> establishments = [];

  EstablishmentController(this.establishmentService);

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<Set<Marker>> loadMarkers(Function(int) onTapCallback) async {
    Set<Marker> markers = {};
    try {
      List<EstablishmentModel> establishments = await establishmentService.loadEstablishments();
      for (var establishment in establishments) {
        Marker marker = Marker(
          markerId: MarkerId(establishment.id.toString()),
          position: LatLng(establishment.latitude, establishment.longitude),
          infoWindow: InfoWindow(
              title: establishment.name,
              snippet: establishment.description,
              onTap: () => onTapCallback(establishment.id)
          ),
        );
        markers.add(marker);
      }
    } catch (e) {
      print("Error al cargar marcadores: $e");
    }
    return markers;
  }

  Future<List<EstablishmentModel>> fetchEstablishments() async {
    try {
      return await establishmentService.loadEstablishments();
    } catch (e) {
      throw Exception("Failed to load establishment details: $e");
    }
  }

  Future<EstablishmentModel> fetchEstablishmentDetails(int establishmentId) async {
    try {
      return await establishmentService.getEstablishmentById(establishmentId);
    } catch (e) {
      throw Exception("Failed to load establishment details: $e");
    }
  }

  Future<bool> registerEstablishment(EstablishmentModel establishment) async {
    return await establishmentService.registerEstablishment(establishment);
  }

  Future<bool> deleteEstablishment(int id) async {
    try {
      return await establishmentService.deleteEstablishment(id);
    } catch (e) {
      print("Failed to delete establishment: $e");
      return false;
    }
  }

  Future<bool> updateEstablishmentDetails(int id, Map<String, dynamic> updates) async {
    try {
      return await establishmentService.updateEstablishment(id, updates);
    } catch (e) {
      print('Error updating establishment: $e');
      return false;
    }
  }
}
