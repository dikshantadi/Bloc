import 'package:dio/dio.dart';
import 'package:task_bloc/not_needed/network_response.dart';

enum RequestType { GET, POST, PUT, PATCH, DELETE }

class Api {
  final dio = createDio();

  Api._internal();

  static final _singleton = Api._internal();

  factory Api() => _singleton;

  static Dio createDio() {
    var dio = Dio(
      BaseOptions(
        baseUrl: "https://jsonplaceholder.typicode.com",
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(dio),
      Logging(dio),
      ErrorInterceptors(dio),
    ]);

    return dio;
  }

  Future<NetworkResponse?> apiCall(
    String url,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    RequestType requestType,
  ) async {
    late Response result;
    try {
      switch (requestType) {
        case RequestType.GET:
          {
            Options options = Options(headers: header);
            result = await dio.get(
              url,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          }
        case RequestType.POST:
          {
            Options options = Options(headers: header);
            result = await dio.post(url, data: body, options: options);
            break;
          }
        case RequestType.DELETE:
          {
            Options options = Options(headers: header);
            result = await dio.delete(
              url,
              data: queryParameters,
              options: options,
            );
            break;
          }
        case RequestType.PUT:
          // TODO: Handle this case.
          throw UnimplementedError();
        case RequestType.PATCH:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      return NetworkResponse.success(result.data);
    } on DioException catch (error) {
      return NetworkResponse.error(error.message ?? "Unknown Dio error");
    } catch (error) {
      return NetworkResponse.error(error.toString());
    }
  }
}

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var accessToken = await TokenRepository().getAccessToken();

    if (accessToken != null) {
      var expiration = await TokenRepository().getAccessTokenRemainingTime();

      if (expiration.inSeconds < 60) {
        // dio.interceptors.requestLock.lock();

        // Call the refresh endpoint to get a new token
        await UserService()
            .refresh()
            .then((response) async {
              await TokenRepository().persistAccessToken(response.accessToken);
              accessToken = response.accessToken;
            })
            .catchError((error, stackTrace) {
              handler.reject(error, true);
            });
        // .whenComplete(() => dio.interceptors.requestLock.unlock());
      }

      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }
}

class ErrorInterceptors extends Interceptor {
  final Dio dio;

  ErrorInterceptors(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeOutException(err.requestOptions);
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.requestOptions);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        throw NoInternetConnectionException(err.requestOptions);
    }

    return handler.next(err);
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class TimeOutException extends DioException {
  TimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}

class Logging extends Interceptor {
  final Dio dio;
  Logging(this.dio);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    return super.onError(err, handler);
  }
}

final Map<String, String> header = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
  'client-secret': 'xyz',
  'client-id': 'abc',
  'package-name': 'com.sasa.abc',
  'platform': 'android',
  'Authorization': "access_token",
};

class TokenRepository {
  String? _token;
  DateTime? _expiry;

  Future<String?> getAccessToken() async {
    _token ??= "mock_access_token";
    _expiry ??= DateTime.now().add(const Duration(minutes: 5));
    return _token;
  }

  Future<Duration> getAccessTokenRemainingTime() async {
    if (_expiry == null) return Duration.zero;
    return _expiry!.difference(DateTime.now());
  }

  Future<void> persistAccessToken(String token) async {
    _token = token;
    _expiry = DateTime.now().add(const Duration(minutes: 5));
  }
}

class UserService {
  Future<_RefreshResponse> refresh() async {
    print("Refreshing token...");
    await Future.delayed(const Duration(seconds: 1));
    return _RefreshResponse("new_mock_token");
  }
}

// Helper class for mock refresh response
class _RefreshResponse {
  final String accessToken;
  _RefreshResponse(this.accessToken);
}
