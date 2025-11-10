import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api_response<T> {
  final T? data;
  final Api_Error? error;
  final bool success;

  Api_response({this.data, this.error, required this.success});

  factory Api_response.success(T data) {
    return Api_response(data: data, success: true);
  }

  factory Api_response.error(Api_Error error) {
    return Api_response(error: error, success: false);
  }
}

class Api_Error {
  final String code;
  final String message;

  Api_Error({required this.code, required this.message});
}

enum Method_Type { get, post, put, delete, patch }

abstract class Api_client {
  Future<Api_response<T>> request<T>({
    required String path,
    required Method_Type method,
    dynamic? payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    bool requiresAuth = true,
  });

  Future<void> setToken(String token);
  Future<void> clearToken();
  Future<void> hasToken();
}

class DioApiClient implements Api_client {
  final Dio _dio;
  final SharedPreferences _preferences;
  final String _baseUrl;
  final String _tokenKey;

  DioApiClient({
    required Dio dio,
    required SharedPreferences preferences,
    required String baseUrl,
    String tokenKey = "key_token",
  }) : _dio = dio,
       _preferences = preferences,
       _baseUrl = baseUrl,
       _tokenKey = tokenKey {
    _dio.options.baseUrl = _baseUrl;
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['requiresAuth'] == true) {
            final token = _preferences.getString(_tokenKey);
            print("token from Api client $token");
            if (token != null) {
              options.headers['Authorization'] = 'Token $token';
            }
          }
          options.headers["Accept"] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _preferences.remove(_tokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  @override
  Future<Api_response<T>> request<T>({
    required String path,
    required Method_Type method,
    dynamic? payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final options = Options(extra: {"requiresAuth": requiresAuth});
      Response response;

      switch (method) {
        case Method_Type.get:
          response = await _dio.get(
            path,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case Method_Type.post:
          response = await _dio.post(
            path,
            data: payload,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case Method_Type.put:
          response = await _dio.put(
            path,
            data: payload,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case Method_Type.delete:
          response = await _dio.delete(
            path,
            data: payload,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case Method_Type.patch:
          response = await _dio.patch(
            path,
            data: payload,
            queryParameters: queryParameters,
            options: options,
          );
          break;
      }

      if (fromJson != null && response.data is Map<String, dynamic>) {
        return Api_response.success(fromJson(response.data));
      } else if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return Api_response.success(response.data as T);
      } else {
        return Api_response.error(
          Api_Error(
            code: response.statusCode.toString(),
            message: 'unknown response format',
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Unknown error occurred';
      String errorCode = e.response?.statusCode?.toString() ?? '000';

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        } else if (data.containsKey('message')) {
          errorMessage = data['message'].toString();
        } else if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return Api_response.error(
        Api_Error(code: errorCode, message: errorMessage),
      );
    } catch (e) {
      return Api_response.error(
        Api_Error(code: "000", message: 'Unexpected error: \$e'),
      );
    }
  }

  @override
  Future<void> setToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    await _preferences.remove(_tokenKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = _preferences.getString(_tokenKey);
    print("Token is ${token != null && token.isNotEmpty}");
    return token != null && token.isNotEmpty;
  }
}
