import 'package:equatable/equatable.dart';

String formatSaudiPhoneNumber(String phone) {
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00966')) {
    digits = digits.substring(5);
  } else if (digits.startsWith('966')) {
    digits = digits.substring(3);
  }
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return '966$digits';
}

class SendWhatsAppModel extends Equatable {
  final String toNumber;
  final String tempname;
  final String text;
  final String? fileUrl;
  final String? fileName;

  const SendWhatsAppModel({
    required this.toNumber,
    this.tempname = 'utility',
    required this.text,
    this.fileUrl,
    this.fileName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'ToNumber': formatSaudiPhoneNumber(toNumber),
      'tempname': tempname,
      'Text': text.replaceAll('\n', ' - ').replaceAll(RegExp(r'\s+'), ' ').trim(),
    };
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      map['fileurl'] = fileUrl;
    }
    if (fileName != null && fileName!.isNotEmpty) {
      map['Filename'] = fileName;
    }
    return map;
  }

  @override
  List<Object?> get props => [toNumber, tempname, text, fileUrl, fileName];
}



class SendWhatsAppResponseModel extends Equatable {
  final String status;
  final String message;

  const SendWhatsAppResponseModel({
    required this.status,
    required this.message,
  });

  factory SendWhatsAppResponseModel.fromJson(Map<String, dynamic> json) {
    return SendWhatsAppResponseModel(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';

  @override
  List<Object?> get props => [status, message];
}
