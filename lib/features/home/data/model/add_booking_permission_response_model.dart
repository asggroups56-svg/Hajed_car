import 'dart:convert';

import 'package:equatable/equatable.dart';

class AddBookingPermissionResponseModel extends Equatable {
  final bool success;
  final String lpoNo;
  final String msg;

  const AddBookingPermissionResponseModel({
    required this.success,
    required this.lpoNo,
    required this.msg,
  });

  static Map<String, dynamic> _normalize(dynamic json) {
    var source = <String, dynamic>{};

    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          source = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
      return source;
    }

    if (json is Map) {
      source = Map<String, dynamic>.from(json);

      // The backend usually wraps the actual payload in a `Data` field
      // (sometimes as a JSON-encoded string, sometimes as a nested map).
      final data = source['Data'] ?? source['data'];
      if (data is String && data.trim().isNotEmpty && data.trim() != 'null') {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            source = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else if (data is Map) {
        source = Map<String, dynamic>.from(data);
      }
    }

    return source;
  }

  factory AddBookingPermissionResponseModel.fromJson(dynamic json) {
    final source = _normalize(json);

    final successRaw =
        source['success'] ??
        source['Success'] ??
        source['STATUS'] ??
        source['status'] ??
        source['Result'] ??
        source['result'];

    // Some endpoints return only a message on failure or only a payload on
    // success. Treat a non-empty payload (Data/lpono/LPO_NO) without an
    // error message as a success in that case.
    final rawData = json is Map ? (json['Data'] ?? json['data']) : null;
    final payloadText = rawData is String ? rawData.trim() : rawData?.toString().trim();
    final hasPayload = payloadText != null &&
        payloadText.isNotEmpty &&
        payloadText != 'null' &&
        payloadText != '0';

    final msgRaw =
        source['msg'] ??
        source['Message'] ??
        source['message'] ??
        source['MESSAGE'] ??
        source['error'];

    final msgText = msgRaw?.toString().trim() ?? '';

    final explicitSuccess = successRaw == true ||
        successRaw?.toString().toLowerCase() == '1' ||
        successRaw?.toString().toLowerCase() == 'true' ||
        successRaw?.toString().toLowerCase() == 'success';

    final impliedSuccess =
        successRaw == null && hasPayload && msgText.isEmpty;

    final success = explicitSuccess || impliedSuccess;

    final lpoNoRaw =
        source['lpono'] ??
        source['LPONO'] ??
        source['lpoNo'] ??
        source['LPO_NO'] ??
        source['bookingNo'] ??
        source['BookingNo'] ??
        (hasPayload && int.tryParse(payloadText) != null ? payloadText : null);

    return AddBookingPermissionResponseModel(
      success: success,
      lpoNo: lpoNoRaw?.toString() ?? '',
      msg: msgText,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'lpono': lpoNo, 'msg': msg};
  }

  AddBookingPermissionResponseModel copyWith({bool? success, String? lpoNo, String? msg}) {
    return AddBookingPermissionResponseModel(
      success: success ?? this.success,
      lpoNo: lpoNo ?? this.lpoNo,
      msg: msg ?? this.msg,
    );
  }

  @override
  List<Object?> get props => [success, lpoNo, msg];
}
