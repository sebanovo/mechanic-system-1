import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/admin_incident_model.dart';

abstract class AdminIncidentRemoteDataSource {
  Future<List<AdminIncidentModel>> getAllIncidents();
  Future<AdminIncidentModel> getIncidentDetails(String incidentId);
  Future<List<CandidateModel>> getIncidentCandidates(String incidentId);
  Future<AdminIncidentModel> publishIncident(String incidentId);
}

class AdminIncidentRemoteDataSourceImpl
    implements AdminIncidentRemoteDataSource {
  final ApiClient _apiClient;

  AdminIncidentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminIncidentModel>> getAllIncidents() async {
    final response = await _apiClient.get('/api/incidents');

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => AdminIncidentModel.fromJson(json)).toList();
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load incidents');
  }

  @override
  Future<AdminIncidentModel> getIncidentDetails(String incidentId) async {
    final response = await _apiClient.get('/api/incidents/$incidentId');

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return AdminIncidentModel.fromJson(jsonResponse['data']);
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load incident details',
    );
  }

  @override
  Future<List<CandidateModel>> getIncidentCandidates(String incidentId) async {
    final response = await _apiClient.get(
      '/api/assignment/platform/incidents/$incidentId/candidates',
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => CandidateModel.fromJson(json)).toList();
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load candidates');
  }

  @override
  Future<AdminIncidentModel> publishIncident(String incidentId) async {
    final response = await _apiClient.post(
      '/api/assignment/platform/incidents/$incidentId/publish',
      null,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      // La respuesta tiene la estructura que mostraste
      // Solo necesitamos obtener el incidente actualizado
      // Usamos el incident_id de la respuesta para obtener los detalles actualizados
      final data = jsonResponse['data'];
      final publishedIncidentId = data['incident_id'] as String;

      // Obtenemos el incidente actualizado con todos los detalles
      return await getIncidentDetails(publishedIncidentId);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to publish incident');
  }
}
