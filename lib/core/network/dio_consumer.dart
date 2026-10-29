import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../services/services_locator.dart';
import 'api_consumer.dart';
import 'app_interceptors.dart';
import 'contants.dart';

class DioConsumer implements ApiConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    client.options
      ..baseUrl = Constants.baseUrl
      ..followRedirects = false;
    client.interceptors.add(sl<AppInterceptors>());
    if (kDebugMode) {
      client.interceptors.addAll(
        kDebugMode
            ? [
                PrettyDioLogger(
                  requestHeader: true,
                  requestBody: true,
                  responseBody: true,
                  responseHeader: false,
                  compact: false,
                  error: true,
                  request: true,
                ),
              ]
            : [],
      );
    }
  }

  dynamic _processBody(dynamic body, bool? isFormData) {
    if (isFormData == true && body != null) {
      if (body is FormData) {
        return body;
      } else if (body is Map<String, dynamic>) {
        return FormData.fromMap(body);
      }
    }
    return body;
  }

  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool? asBytes,
  }) async {
    final response = await client.request(
      path,
      data: body,
      queryParameters: queryParameters,
      options: Options(
        method: 'GET',
        headers: headers,
        extra: extra,
        responseType: asBytes == true ? ResponseType.bytes : null,
      ),
    );
    return response.data;
  }

  @override
  Future post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool? isFormData,
    bool? asBytes,
  }) async {
    var response = await client.post(
      path,
      data: _processBody(body, isFormData),
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        extra: extra,
        responseType: asBytes == true ? ResponseType.bytes : null,
      ),
    );
    return response.data;
  }

  @override
  Future put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool? isFormData,
  }) async {
    final response = await client.put(
      path,
      data: _processBody(body, isFormData),
      queryParameters: queryParameters,
      options: Options(headers: headers, extra: extra),
    );
    return response.data;
  }

  @override
  Future delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool? isFormData,
  }) async {
    final response = await client.request(
      path,
      data: _processBody(body, isFormData),
      queryParameters: queryParameters,
      options: Options(method: 'DELETE', headers: headers, extra: extra),
    );
    return response.data;
  }
}
