import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/technician_model.dart';

abstract class TechnicianRemoteDataSource {
  Future<List<TechnicianModel>> getTechnicians();
  Future<TechnicianModel> createTechnician(Map<String, dynamic> params);
}

class TechnicianRemoteDataSourceImpl implements TechnicianRemoteDataSource {
  final ApiClient _apiClient;

  TechnicianRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TechnicianModel>> getTechnicians() async {
    final response = await _apiClient.get('/api/providers/me/technicians');

    // response.data contiene el body de la respuesta
    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => TechnicianModel.fromJson(json)).toList();
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load technicians');
  }

  @override
  Future<TechnicianModel> createTechnician(Map<String, dynamic> params) async {
    final response = await _apiClient.post(
      '/api/providers/me/technicians',
      params,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return TechnicianModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to create technician');
  }
}
