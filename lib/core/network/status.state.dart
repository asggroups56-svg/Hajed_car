// lib/core/network/status.state.dart

enum Status { initial, loading, success, failure }

class StatusState<T> {
  final Status status;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  const StatusState._({
    required this.status,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  const StatusState.initial() : this._(status: Status.initial);

  const StatusState.loading() : this._(status: Status.loading);

  const StatusState.success(T data, {String? message})
    : this._(status: Status.success, data: data, message: message);

  const StatusState.failure(String error, {int? statusCode})
    : this._(status: Status.failure, error: error, statusCode: statusCode);

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isFailure => status == Status.failure;
}
