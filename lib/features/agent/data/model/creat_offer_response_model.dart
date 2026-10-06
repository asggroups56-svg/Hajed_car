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
    return CreatOfferResponseModel(
      success: json['success'] == true || json['success']?.toString() == '1',
      listNo: json['LISTNO']?.toString() ?? '',
      message: json['msg']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'LISTNO': listNo, 'msg': message};
  }

  @override
  List<Object?> get props => [success, listNo, message];
}
