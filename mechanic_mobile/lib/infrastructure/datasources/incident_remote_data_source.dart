import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/incident_model.dart';

abstract class IncidentRemoteDataSource {
  Future<List<IncidentModel>> getMyIncidents();
  Future<IncidentModel> createIncident(Map<String, dynamic> params);
  Future<IncidentModel> updateIncident(
    String incidentId,
    Map<String, dynamic> params,
  );
  Future<void> cancelIncident(String incidentId);
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final ApiClient _apiClient;

  IncidentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<IncidentModel>> getMyIncidents() async {
    final response = await _apiClient.get('/api/incidents/me');

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => IncidentModel.fromJson(json)).toList();
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load incidents');
  }

  @override
  Future<IncidentModel> createIncident(Map<String, dynamic> params) async {
    final response = await _apiClient.post('/api/incidents', params);

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return IncidentModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to create incident');
  }

  @override
  Future<IncidentModel> updateIncident(
    String incidentId,
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.patch(
      '/api/incidents/me/$incidentId',
      params,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return IncidentModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to update incident');
  }

  @override
  Future<void> cancelIncident(String incidentId) async {
    final response = await _apiClient.post(
      '/api/incidents/me/$incidentId/cancel',
      null,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] != true) {
      throw Exception(jsonResponse['message'] ?? 'Failed to cancel incident');
    }
  }
}
