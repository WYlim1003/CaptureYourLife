import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.authRegister,
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        ApiConfig.imagesUpload,
        data: formData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSticker(String imageId) async {
    try {
      final response = await _dio.post(
        ApiConfig.generateSticker,
        data: {
          'image_id': imageId,
          'style': 'sticker',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateAvatar(
    String imageId,
    String style,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.generateAvatar,
        data: {
          'image_id': imageId,
          'style': style,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGenerationHistory() async {
    try {
      final response = await _dio.get(ApiConfig.generateHistory);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
