import 'package:dio/dio.dart';
import '../../constants/env.dart';

class ApiClient {
  final Dio dio;

  String? token;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

  void setToken(String token) {
    this.token = token;
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearToken() {
    token = null;
    dio.options.headers.remove("Authorization");
  }

  Future<Response> post(String path, dynamic data) async {
    return await dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await dio.get(path);
  }

  Future<Response> patch(String path, dynamic data) async {
    return await dio.patch(path, data: data);
  }

  // ✅ Agregar método DELETE
  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }

  // ✅ Método auxiliar para manejar respuestas
  Map<String, dynamic> getResponseData(Response response) {
    return response.data as Map<String, dynamic>;
  }

  // ✅ Método genérico para verificar éxito
  bool isSuccess(Response response) {
    final data = response.data as Map<String, dynamic>;
    return data['success'] == true;
  }

  // ✅ Método para obtener mensaje de error
  String getErrorMessage(Response response) {
    final data = response.data as Map<String, dynamic>;
    return data['message'] ?? 'Unknown error occurred';
  }
}
