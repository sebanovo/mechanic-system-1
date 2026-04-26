import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image_picker/image_picker.dart';
import 'package:mechanic_mobile/core/network/api_client.dart';

import '../models/evidence_model.dart';

abstract class EvidenceRemoteDataSource {
  Future<EvidenceModel> addTextEvidence(
    String incidentId,
    Map<String, dynamic> params,
  );
  Future<EvidenceModel> addFileEvidence(
    String incidentId,
    String evidenceType,
    String description,
    XFile file,
  );
}

class EvidenceRemoteDataSourceImpl implements EvidenceRemoteDataSource {
  final ApiClient _apiClient;

  EvidenceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<EvidenceModel> addTextEvidence(
    String incidentId,
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.post(
      '/api/evidences/client/incidents/$incidentId/text',
      params,
    );

    final Map<String, dynamic> jsonResponse =
        response.data as Map<String, dynamic>;

    if (jsonResponse['success'] == true) {
      return EvidenceModel.fromJson(jsonResponse['data']);
    }
    throw Exception(jsonResponse['message'] ?? 'Failed to add text evidence');
  }

  @override
  Future<EvidenceModel> addFileEvidence(
    String incidentId,
    String evidenceType,
    String description,
    XFile file,
  ) async {
    try {
      final fileName = file.name;
      final bytes = await file.readAsBytes();

      // Determinar mime type
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = evidenceType == 'IMAGE'
          ? (extension == 'png' ? 'image/png' : 'image/jpeg')
          : 'audio/mpeg';

      debugPrint('📤 Subiendo archivo: $fileName');
      debugPrint('📤 Tipo MIME: $mimeType');
      debugPrint('📤 Tamaño: ${bytes.length} bytes');

      // ✅ Asegurar que los campos son correctos
      final additionalFields = {
        'evidence_type': evidenceType, // Debe ser "IMAGE", "TEXT" o "AUDIO"
        'description': description,
      };

      debugPrint('📤 Campos adicionales: $additionalFields');

      final response = await _apiClient.uploadFile(
        '/api/evidences/client/incidents/$incidentId/files',
        fieldName: 'upload_file',
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
        additionalFields: additionalFields,
      );

      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;
      debugPrint('📥 Respuesta del servidor: $jsonResponse');

      if (jsonResponse['success'] == true) {
        debugPrint('✅ Archivo subido exitosamente');
        return EvidenceModel.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to add file evidence');
    } catch (e) {
      debugPrint('❌ Error al subir archivo: $e');
      if (e is DioException) {
        debugPrint('❌ Respuesta del servidor: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
