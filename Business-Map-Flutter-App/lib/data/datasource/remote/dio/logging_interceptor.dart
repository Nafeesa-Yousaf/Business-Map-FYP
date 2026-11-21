import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  static const _sensitiveHeaderKeys = {
    'authorization',
    'x-vercel-protection-bypass',
    'cookie',
    'set-cookie',
  };

  static const _sensitiveQueryKeys = {
    'key',
    'api_key',
    'apikey',
    'access_token',
    'token',
    'id_token',
  };

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      log('--> ${options.method} ${options.baseUrl}${options.path}');
      log('Headers: ${_redactMap(options.headers, _sensitiveHeaderKeys)}');
      log('Params: ${_safeData(options.data)}');
      log(
        'queryParams: ${_redactMap(options.queryParameters, _sensitiveQueryKeys)}',
      );
      log('<-- END HTTP');
    }
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      log(
        '<-- ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      );
      log('<-- END HTTP');
    }
    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      log(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} '
        'msg: ${err.message}',
      );
    }
    return super.onError(err, handler);
  }

  static Map<String, dynamic> _redactMap(
    Map<dynamic, dynamic> source,
    Set<String> sensitiveKeys,
  ) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      final keyStr = key.toString();
      if (sensitiveKeys.contains(keyStr.toLowerCase())) {
        result[keyStr] = '***';
      } else {
        result[keyStr] = value;
      }
    });
    return result;
  }

  static Object? _safeData(dynamic data) {
    if (data == null) return null;
    if (data is FormData) return '[FormData]';
    if (data is Map) {
      return _redactMap(data, {
        ..._sensitiveQueryKeys,
        'password',
        'currentpassword',
        'newpassword',
      });
    }
    return data.toString();
  }
}
