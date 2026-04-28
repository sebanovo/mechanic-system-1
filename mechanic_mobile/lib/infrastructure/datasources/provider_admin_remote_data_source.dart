import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/provider_summary_model.dart';

abstract class ProviderAdminRemoteDataSource {
  Future<List<ProviderSummaryModel>> getProviders({
    int limit = 50,
    int offset = 0,
  });
}

class ProviderAdminRemoteDataSourceImpl
    implements ProviderAdminRemoteDataSource {
  final ApiClient _apiClient;

  ProviderAdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProviderSummaryModel>> getProviders({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/api/providers?limit=$limit&offset=$offset',
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => ProviderSummaryModel.fromJson(json)).toList();
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load providers');
  }
}
