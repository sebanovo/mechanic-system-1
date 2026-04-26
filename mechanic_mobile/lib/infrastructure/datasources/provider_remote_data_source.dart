import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/provider_profile_model.dart';

abstract class ProviderRemoteDataSource {
  Future<ProviderProfileModel> getProviderProfile();
  Future<ProviderProfileModel> updateProviderProfile(
    Map<String, dynamic> params,
  );
}

class ProviderRemoteDataSourceImpl implements ProviderRemoteDataSource {
  final ApiClient _apiClient;

  ProviderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProviderProfileModel> getProviderProfile() async {
    final response = await _apiClient.get('/api/providers/me/profile');

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return ProviderProfileModel.fromJson(jsonResponse['data']);
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load provider profile',
    );
  }

  @override
  Future<ProviderProfileModel> updateProviderProfile(
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.patch(
      '/api/providers/me/profile',
      params,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return ProviderProfileModel.fromJson(jsonResponse['data']);
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to update provider profile',
    );
  }
}
