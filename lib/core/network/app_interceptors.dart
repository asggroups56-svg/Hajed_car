import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/network/end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppInterceptors extends Interceptor {
  AppInterceptors();
  static bool isInternet = true;
  // Prevents infinite loop if the refresh request itself returns 401
  bool _isRefreshing = false;
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    isInternet = true;
    if (options.data is FormData) {
      options.contentType = null;
      options.headers.remove(Headers.contentTypeHeader);
      options.headers.remove('Content-Type');
      options.headers.remove('content-type');
    } else {
      options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    final lang = HiveMethods.getLang();
    options.headers['lang'] = lang == 'en' ? 'en-GB' : lang;
    final token = HiveMethods.getToken();
    if (token != null && options.extra['skipAuth'] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // Only handle 401 (Unauthorized / token expired)
    // Skip if already refreshing or if the failed request itself is the login/token endpoint
    final isTokenRequest = err.requestOptions.path.contains(EndPoints.login);
    if (statusCode == 401 && !_isRefreshing && !isTokenRequest) {
      final refreshToken = HiveMethods.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('⚠️ [TokenRefresh] 401 received but NO refresh_token is saved in Hive. User needs to login again.');
        HiveMethods.deleteToken();
        return super.onError(err, handler);
      }

      _isRefreshing = true;
      debugPrint('🔄 [TokenRefresh] 401 received. Attempting to refresh token using stored refresh_token...');

      try {
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: err.requestOptions.baseUrl.isNotEmpty
                ? err.requestOptions.baseUrl
                : Constants.baseUrl,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          ),
        );

        final refreshResponse = await refreshDio.post(
          EndPoints.refreshToken,
          data: {
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            'client_type': 'mobile',
          },
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
          ),
        );

        debugPrint('✅ [TokenRefresh] Refresh API response: ${refreshResponse.statusCode} - ${refreshResponse.data}');

        final newAccessToken = refreshResponse.data['access_token']?.toString() ?? '';
        final newRefreshToken = refreshResponse.data['refresh_token']?.toString() ?? '';

        if (newAccessToken.isNotEmpty) {
          // Update tokens in Hive
          HiveMethods.updateToken(newAccessToken);
          if (newRefreshToken.isNotEmpty) {
            HiveMethods.updateRefreshToken(newRefreshToken);
          }
          debugPrint('🔑 [TokenRefresh] Tokens updated successfully in Hive.');

          // Retry the original request with the new access token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await refreshDio.fetch(retryOptions);
          _isRefreshing = false;
          debugPrint('🚀 [TokenRefresh] Original request retried and resolved successfully.');
          return handler.resolve(retryResponse);
        } else {
          debugPrint('❌ [TokenRefresh] Failed: access_token was empty in refresh response.');
        }
      } catch (refreshError) {
        debugPrint('❌ [TokenRefresh] Exception during refresh token: $refreshError');
        HiveMethods.deleteToken();
        HiveMethods.deleteRefreshToken();
      } finally {
        _isRefreshing = false;
      }
    }

    super.onError(err, handler);
  }
}
