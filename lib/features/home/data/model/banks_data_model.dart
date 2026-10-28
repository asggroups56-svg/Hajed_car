import 'dart:convert';

import 'package:equatable/equatable.dart';

class BANKSDATAModel extends Equatable {
  final int? bankCode;
  final String? bankName;
  final String? bankNameEng;
  final String? currencyName;
  final String? notes;
  final String? telNo1;
  final String? telNo2;
  final String? telNo3;
  final String? faxNo1;
  final String? faxNo2;
  final String? address;
  final String? collectPeriod;
  final double? bankAccNo;
  final String? currencyCode;
  final String? poBox;
  final String? sambleBox;
  final String? analLytical;
  final String? city;
  final String? email;

  const BANKSDATAModel({
    this.bankCode,
    this.bankName,
    this.bankNameEng,
    this.currencyName,
    this.notes,
    this.telNo1,
    this.telNo2,
    this.telNo3,
    this.faxNo1,
    this.faxNo2,
    this.address,
    this.collectPeriod,
    this.bankAccNo,
    this.currencyCode,
    this.poBox,
    this.sambleBox,
    this.analLytical,
    this.city,
    this.email,
  });

  factory BANKSDATAModel.fromJson(Map<String, dynamic> json) {
    return BANKSDATAModel(
      // Some deployments serialize the code as a string; parsing it keeps the
      // bank directory and the selected-bank lookups working.
      bankCode: int.tryParse(json['BANK_CODE']?.toString().trim() ?? ''),
      bankName: json['BANK_NAME'],
      bankNameEng: json['BANK_NAME_ENG'],
      currencyName: json['CURRENCY_NAME'],
      notes: json['NOTES'],
      telNo1: json['TEL_NO1'],
      telNo2: json['TEL_NO2'],
      telNo3: json['TEL_NO3'],
      faxNo1: json['FAX_NO1'],
      faxNo2: json['FAX_NO2'],
      address: json['ADDRESS'],
      collectPeriod: json['COLLECT_PERIOD'],
      bankAccNo: (json['BANK_ACC_NO'] as num?)?.toDouble(),
      currencyCode: json['CURRENCY_CODE'],
      poBox: json['P_O_BOX'],
      sambleBox: json['SAMBLE_BOX'],
      analLytical: json['ANALLYTICAL'],
      city: json['CITY'],
      email: json['EMAIL'],
    );
  }

  static List<BANKSDATAModel> listFromResponse(dynamic data) {
    if (data == null) {
      return [];
    }

    final List<dynamic> jsonList = data is String ? jsonDecode(data) : data;

    return jsonList.map((e) => BANKSDATAModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [
    bankCode,
    bankName,
    bankNameEng,
    currencyName,
    notes,
    telNo1,
    telNo2,
    telNo3,
    faxNo1,
    faxNo2,
    address,
    collectPeriod,
    bankAccNo,
    currencyCode,
    poBox,
    sambleBox,
    analLytical,
    city,
    email,
  ];
}
