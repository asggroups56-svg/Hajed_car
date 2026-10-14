// lib/core/network/error_handler.dart

import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../network/status_code.dart';

/// Base class for all failures, holds an error message.
abstract class Failure {
  final String errMessage;
  final int? statusCode;

  const Failure(this.errMessage, {this.statusCode});
}

String? _extractMsgFromMap(dynamic data) {
  if (data == null) return null;
  if (data is Map) {
    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase().replaceAll('_', '').replaceAll('-', '');
      if (key == 'message' ||
          key == 'msg' ||
          key == 'messagear' ||
          key == 'messageen' ||
          key == 'errormessage' ||
          key == 'error' ||
          key == 'detail' ||
          key == 'details' ||
          key == 'title') {
        final val = entry.value;
        if (val is String && val.trim().isNotEmpty) {
          return val.trim();
        } else if (val is List && val.isNotEmpty) {
          return val.map((e) => e.toString()).join('\n');
        } else if (val != null) {
          return val.toString().trim();
        }
      }
    }
  } else if (data is List && data.isNotEmpty) {
    for (final item in data) {
      final msg = _extractMsgFromMap(item);
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } else if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      return _extractMsgFromMap(decoded);
    } catch (_) {
      final trimmed = data.trim();
      if (!trimmed.startsWith('<') && !trimmed.startsWith('{')) {
        return trimmed;
      }
    }
  }
  return null;
}

/// Represents a failure coming from Dio / the server.
class ServerFailure extends Failure {
  ServerFailure(super.errMessage, {super.statusCode});

  /// Map Dio exceptions to our ServerFailure, extracting server‑side messages when present.
  factory ServerFailure.fromDioError(DioException dioError) {
    try {
      final raw = dioError.response?.data;
      final statusCode = dioError.response?.statusCode;
      final serverMsg = _extractMsgFromMap(raw);
      if (serverMsg != null && serverMsg.isNotEmpty) {
        return ServerFailure(serverMsg, statusCode: statusCode);
      }

      // Otherwise fall back based on DioException type
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          return ServerFailure('Connection timeout with API server', statusCode: statusCode);
        case DioExceptionType.sendTimeout:
          return ServerFailure('Send timeout with API server', statusCode: statusCode);
        case DioExceptionType.receiveTimeout:
          return ServerFailure('Receive timeout with API server', statusCode: statusCode);
        case DioExceptionType.cancel:
          return ServerFailure('Request to API server was cancelled', statusCode: statusCode);
        case DioExceptionType.connectionError:
          return ServerFailure('No internet connection', statusCode: statusCode);
        case DioExceptionType.unknown:
          return ServerFailure('Unexpected error, please try again!', statusCode: statusCode);
        case DioExceptionType.badResponse:
          return ServerFailure.fromResponse(dioError.response?.statusCode, raw);
        default:
          return ServerFailure(
            'Oops! There was an error, please try again.',
            statusCode: statusCode,
          );
      }
    } catch (e, stack) {
      log('ServerFailure.fromDioError error: $e\n$stack');
      return ServerFailure('An unknown error occurred');
    }
  }

  /// Handle different status codes, but always prefer the server‑sent "message" if available.
  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    try {
      final serverMsg = _extractMsgFromMap(response);
      if (serverMsg != null && serverMsg.isNotEmpty) {
        return ServerFailure(serverMsg, statusCode: statusCode);
      }

      switch (statusCode) {
        case StatusCode.badRequest:
        case StatusCode.unauthorized:
        case StatusCode.forbidden:
          return ServerFailure('Invalid request, please check your input', statusCode: statusCode);
        case StatusCode.notFound:
          return ServerFailure('Requested resource not found', statusCode: statusCode);
        case StatusCode.internalServerError:
          return ServerFailure('Internal server error, please try later', statusCode: statusCode);
        default:
          return ServerFailure('Request failed with status $statusCode', statusCode: statusCode);
      }
    } catch (e) {
      return ServerFailure('Failed to parse server response');
    }
  }
}

/// Executes any Dio request and returns either the parsed data or a Failure.
Future<Either<Failure, T>> handleDioRequest<T>({required Future<T> Function() request}) async {
  try {
    final response = await request();
    return Right(response);
  } on DioException catch (e) {
    // Debug logs
    log('[DioException] ➜ ${e.message}');
    if (e.response?.data != null) {
      final serverMsg = _extractServerMessage(e.response!.data);
      log('[Server message] ➜ $serverMsg');
    }
    return Left(ServerFailure.fromDioError(e));
  } catch (e, stack) {
    log('[Unknown Error] ➜ $e');
    log('[StackTrace] ➜ $stack');
    return Left(ServerFailure(e.toString()));
  }
}

/// Helper to grab "message" from raw response data for logging.
String? _extractServerMessage(dynamic rawData) {
  try {
    if (rawData is Map<String, dynamic>) {
      return _extractMsgFromMap(rawData);
    }
    if (rawData is String) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) {
        return _extractMsgFromMap(decoded);
      }
    }
  } catch (_) {}
  return null;
}
