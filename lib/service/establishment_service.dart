import 'dart:convert';
import '../model/establishment_model.dart';
import 'glutenvoid_api_service.dart';

class EstablishmentService {
  final GlutenVoidApi glutenVoidApi;

  EstablishmentService(this.glutenVoidApi);

  Future<List<EstablishmentModel>> loadEstablishments() async {
    final response = await glutenVoidApi.get('/establishments');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EstablishmentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load establishments');
    }
  }

  Future<EstablishmentModel> getEstablishmentById(int id) async {
    final response = await glutenVoidApi.get('/establishments/$id');
    if (response.statusCode == 200) {
      return EstablishmentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load establishment');
    }
  }

  Future<bool> deleteEstablishment(int id) async {
    final response = await glutenVoidApi.delete('/establishments/$id');
    return response.statusCode == 204;
  }

  Future<bool> registerEstablishment(EstablishmentModel establishment) async {
    final response = await glutenVoidApi.post(
        '/establishments', jsonEncode(establishment.toJson()));
    return response.statusCode == 201;
  }

  Future<bool> updateEstablishment(int id, Map<String, dynamic> updates) async {
    final response = await glutenVoidApi.patch('/establishments/$id', jsonEncode(updates));
    return response.statusCode == 200;
  }

}
