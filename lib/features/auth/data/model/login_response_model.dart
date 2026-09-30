import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
  final String userName;
  final String userId;
  final String companyName;
  final String modName;
  final String autoCode;
  final String multiEffect;
  final String transShip;
  final String linkWithAcc;
  final String vatSerial;
  final String decimal2;
  final String viewInvoice;
  final String appInvoice;
  final String viewInvoiceTemp;
  final String taxReg;
  final String code;
  final String name;
  final String tel1;
  final String represNo;
  final String type;
  final String issued;
  final String expires;
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.userName,
    required this.userId,
    required this.companyName,
    required this.modName,
    required this.autoCode,
    required this.multiEffect,
    required this.transShip,
    required this.linkWithAcc,
    required this.vatSerial,
    required this.decimal2,
    required this.viewInvoice,
    required this.appInvoice,
    required this.viewInvoiceTemp,
    required this.taxReg,
    required this.code,
    required this.name,
    required this.tel1,
    required this.represNo,
    required this.type,
    required this.issued,
    required this.expires,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse(json['expires_in']?.toString() ?? '') ?? 0,
      refreshToken: json['refresh_token']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userId: json['userid']?.toString() ?? '',
      companyName: json['compneyname']?.toString() ?? '',
      modName: json['MOD_NAME']?.toString() ?? '',
      autoCode: json['autocode']?.toString() ?? '',
      multiEffect: json['MULTI_EFFECT']?.toString() ?? '',
      transShip: json['TRANS_SHIP']?.toString() ?? '',
      linkWithAcc: json['LINK_WITH_ACC']?.toString() ?? '',
      vatSerial: json['VAT_SERIAL']?.toString() ?? '',
      decimal2: json['DECIMAL2']?.toString() ?? '',
      viewInvoice: json['VIEW_INVOICE']?.toString() ?? '',
      appInvoice: json['APP_INVOICE']?.toString() ?? '',
      viewInvoiceTemp: json['VIEW_INVOICE_TEMP']?.toString() ?? '',
      taxReg: json['TAX_REG']?.toString() ?? '',
      code: json['Code']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      tel1: json['TEL1']?.toString() ?? '',
      represNo: json['REPRES_NO']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      issued: json['.issued']?.toString() ?? '',
      expires: json['.expires']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'userName': userName,
      'userid': userId,
      'compneyname': companyName,
      'MOD_NAME': modName,
      'autocode': autoCode,
      'MULTI_EFFECT': multiEffect,
      'TRANS_SHIP': transShip,
      'LINK_WITH_ACC': linkWithAcc,
      'VAT_SERIAL': vatSerial,
      'DECIMAL2': decimal2,
      'VIEW_INVOICE': viewInvoice,
      'APP_INVOICE': appInvoice,
      'VIEW_INVOICE_TEMP': viewInvoiceTemp,
      'TAX_REG': taxReg,
      'Code': code,
      'Name': name,
      'TEL1': tel1,
      'REPRES_NO': represNo,
      'type': type,
      '.issued': issued,
      '.expires': expires,
    };
  }

  @override
  List<Object?> get props => [
    accessToken,
    tokenType,
    expiresIn,
    refreshToken,
    userName,
    userId,
    companyName,
    modName,
    autoCode,
    multiEffect,
    transShip,
    linkWithAcc,
    vatSerial,
    decimal2,
    viewInvoice,
    appInvoice,
    viewInvoiceTemp,
    taxReg,
    code,
    name,
    tel1,
    represNo,
    type,
    issued,
    expires,
  ];
}
