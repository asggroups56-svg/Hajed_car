import 'package:equatable/equatable.dart';

class CreatOfferResponseModel extends Equatable {
  final bool success;
  final String listNo;
  final String message;

  const CreatOfferResponseModel({
    required this.success,
    required this.listNo,
    required this.message,
  });

  factory CreatOfferResponseModel.fromJson(Map<String, dynamic> json) {
    final msg = json['msg']?.toString() ??
        json['message']?.toString() ??
        json['Message']?.toString() ??
        '';
    return CreatOfferResponseModel(
      success: json['success'] == true || json['success']?.toString() == '1',
      listNo: json['LISTNO']?.toString() ?? '',
      message: msg,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'LISTNO': listNo, 'msg': message};
  }

  @override
  List<Object?> get props => [success, listNo, message];
}
