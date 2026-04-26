import 'package:mechanic_mobile/core/network/api_client.dart';
import '../models/tracking_model.dart';

abstract class TrackingRemoteDataSource {
  Future<TrackingDataModel> reportLocation(
    String incidentId,
    Map<String, dynamic> params,
  );
  Future<TrackingDataModel> refreshRoute(String incidentId);
  Future<TrackingDataModel> getLiveTracking(String incidentId);
  Future<List<TrackingHistoryItemModel>> getTrackingHistory(String incidentId);
  Future<TrackingDataModel> getClientLiveTracking(String incidentId);
  Future<List<TrackingHistoryItemModel>> getClientTrackingHistory(
    String incidentId,
  );
  Future<TrackingDataModel> getPlatformLiveTracking(String incidentId);
  Future<List<TrackingHistoryItemModel>> getPlatformTrackingHistory(
    String incidentId,
  );
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final ApiClient _apiClient;

  TrackingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<TrackingDataModel> reportLocation(
    String incidentId,
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.post(
      '/api/tracking/provider/incidents/$incidentId/location',
      params,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return TrackingDataModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to report location');
  }

  @override
  Future<TrackingDataModel> refreshRoute(String incidentId) async {
    final response = await _apiClient.post(
      '/api/tracking/provider/incidents/$incidentId/refresh-route',
      null,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return TrackingDataModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to refresh route');
  }

  @override
  Future<TrackingDataModel> getLiveTracking(String incidentId) async {
    final response = await _apiClient.get(
      '/api/tracking/provider/incidents/$incidentId/live',
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return TrackingDataModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to load live tracking');
  }

  @override
  Future<List<TrackingHistoryItemModel>> getTrackingHistory(
    String incidentId,
  ) async {
    final response = await _apiClient.get(
      '/api/tracking/provider/incidents/$incidentId/history',
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data
          .map((json) => TrackingHistoryItemModel.fromJson(json))
          .toList();
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load tracking history',
    );
  }

  @override
  Future<TrackingDataModel> getClientLiveTracking(String incidentId) async {
    final response = await _apiClient.get(
      '/api/tracking/client/incidents/$incidentId/live',
    );
    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;
    if (jsonResponse['success'] == true) {
      return TrackingDataModel.fromJson(jsonResponse['data']);
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load client live tracking',
    );
  }

  @override
  Future<List<TrackingHistoryItemModel>> getClientTrackingHistory(
    String incidentId,
  ) async {
    final response = await _apiClient.get(
      '/api/tracking/client/incidents/$incidentId/history',
    );
    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;
    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data
          .map((json) => TrackingHistoryItemModel.fromJson(json))
          .toList();
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load client tracking history',
    );
  }

  @override
  Future<TrackingDataModel> getPlatformLiveTracking(String incidentId) async {
    final response = await _apiClient.get(
      '/api/tracking/platform/incidents/$incidentId/live',
    );
    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;
    if (jsonResponse['success'] == true) {
      return TrackingDataModel.fromJson(jsonResponse['data']);
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load platform live tracking',
    );
  }

  @override
  Future<List<TrackingHistoryItemModel>> getPlatformTrackingHistory(
    String incidentId,
  ) async {
    final response = await _apiClient.get(
      '/api/tracking/platform/incidents/$incidentId/history',
    );
    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;
    if (jsonResponse['success'] == true) {
      final List<dynamic> data = jsonResponse['data'];
      return data
          .map((json) => TrackingHistoryItemModel.fromJson(json))
          .toList();
    }
    throw Exception(
      jsonResponse['message'] ?? 'Failed to load platform tracking history',
    );
  }
}
