import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logging_interceptor.dart';

class DioClient {
  final String baseUrl;
  final FirebaseAuth firebaseAuth;
  final LoggingInterceptor? loggingInterceptor;

  late Dio dio;
  final String? bypassSecret;


  DioClient._internal(
    this.baseUrl,
    this.firebaseAuth,
    this.dio,
    this.loggingInterceptor,
    this.bypassSecret,
  ) {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await firebaseAuth.currentUser?.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
          }

          if (bypassSecret != null && bypassSecret!.isNotEmpty) {
            options.headers['x-vercel-protection-bypass'] = bypassSecret;
          }

          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(loggingInterceptor ?? LoggingInterceptor());
  }

  static Future<DioClient> create(
    String baseUrl,
    FirebaseAuth firebaseAuth, {
    LoggingInterceptor? loggingInterceptor,
    String? bypassSecret,
  }) async {
    final dio = Dio();
    return DioClient._internal(
      baseUrl,
      firebaseAuth,
      dio,
      loggingInterceptor,
      bypassSecret,
    );
  }

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.get(uri, queryParameters: query);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.post(
        uri,
        data: data,
        queryParameters: query,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.put(
        uri,
        data: data,
        queryParameters: query,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.delete(
        uri,
        data: data,
        queryParameters: query,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<ResponseBody>> postStream(
    String uri, {
    dynamic data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<ResponseBody>(
        uri,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
        // SSE can run longer than the default receive timeout.
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
