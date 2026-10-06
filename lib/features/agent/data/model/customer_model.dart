import 'dart:convert';

import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final int? customerNo;
  final String? address;
  final int? refCustomer;
  final int? areaNo;
  final String? fax;
  final String? notes;
  final int? repreNo;
  final int? currencyCode;
  final int? customerType;
  final double? customerAccNo;
  final double? customerAssNo;
  final int? cusVenPriceId;
  final double? creditLimit;
  final double? creditLimitLoc;
  final String? refCustomerName;
  final String? areaName;
  final String? repreName;
  final String? currencyName;
  final String? customerTypeName;
  final String? countryName;
  final String? cityName;
  final double? exchangeRate;
  final String? customerName;
  final String? customerNameEng;
  final String? tel1;
  final String? tel2;
  final String? tel3;
  final String? telex;
  final String? tradeName;
  final String? tradeRecord;
  final int? countryCode;
  final int? cityCode;
  final double? balanceLocal;
  final int? branchNo;
  final int? stopCust;
  final String? initialDate;
  final int? checkPercent;
  final int? docNature;
  final int? cusNature;
  final String? custTaxNo;
  final String? anallytical;
  final String? responsibilty;
  final String? districtName;
  final String? streetName;
  final String? buildingNo;
  final String? pOBox;
  final String? sambleBox;
  final double? openingBalance;
  final double? openingBalanceLoc;
  final double? openingBalance1;
  final double? openingBalance1Loc;
  final double? prvDbCurr;
  final double? prvCdCurr;
  final double? prvDbLoc;
  final double? prvCdLoc;
  final double? curDbCurr;
  final double? curCdCurr;
  final double? curDbLoc;
  final double? curCdLoc;
  final double? balance;
  final double? balanceLocal1;

  String get customerMobile => tel1 ?? tel2 ?? tel3 ?? '';
  String get mobile => customerMobile;

  const CustomerModel({
    this.customerNo,
    this.address,
    this.refCustomer,
    this.areaNo,
    this.fax,
    this.notes,
    this.repreNo,
    this.currencyCode,
    this.customerType,
    this.customerAccNo,
    this.customerAssNo,
    this.cusVenPriceId,
    this.creditLimit,
    this.creditLimitLoc,
    this.refCustomerName,
    this.areaName,
    this.repreName,
    this.currencyName,
    this.customerTypeName,
    this.countryName,
    this.cityName,
    this.exchangeRate,
    this.customerName,
    this.customerNameEng,
    this.tel1,
    this.tel2,
    this.tel3,
    this.telex,
    this.tradeName,
    this.tradeRecord,
    this.countryCode,
    this.cityCode,
    this.balanceLocal,
    this.branchNo,
    this.stopCust,
    this.initialDate,
    this.checkPercent,
    this.docNature,
    this.cusNature,
    this.custTaxNo,
    this.anallytical,
    this.responsibilty,
    this.districtName,
    this.streetName,
    this.buildingNo,
    this.pOBox,
    this.sambleBox,
    this.openingBalance,
    this.openingBalanceLoc,
    this.openingBalance1,
    this.openingBalance1Loc,
    this.prvDbCurr,
    this.prvCdCurr,
    this.prvDbLoc,
    this.prvCdLoc,
    this.curDbCurr,
    this.curCdCurr,
    this.curDbLoc,
    this.curCdLoc,
    this.balance,
    this.balanceLocal1,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerNo: json['CUSTOMER_NO'] as int?,
      address: json['ADDRESS'] as String?,
      refCustomer: json['REF_CUSTOMER'] as int?,
      areaNo: json['AREA_NO'] as int?,
      fax: json['FAX'] as String?,
      notes: json['NOTES'] as String?,
      repreNo: json['REPRES_NO'] as int?,
      currencyCode: json['CURRENCY_CODE'] as int?,
      customerType: json['CUSTOMER_TYPE'] as int?,
      customerAccNo: (json['CUSTOMER_ACC_NO'] as num?)?.toDouble(),
      customerAssNo: (json['CUSTOMER_ASS_NO'] as num?)?.toDouble(),
      cusVenPriceId: json['CUS_VEN_PRICE_ID'] as int?,
      creditLimit: (json['CREDIT_LIMIT'] as num?)?.toDouble(),
      creditLimitLoc: (json['CREDIT_LIMIT_LOC'] as num?)?.toDouble(),
      refCustomerName: json['REF_CUSTOMER_NAME'] as String?,
      areaName: json['AREA_NAME'] as String?,
      repreName: json['REPRES_NAME'] as String?,
      currencyName: json['CURRENCY_NAME'] as String?,
      customerTypeName: json['CUSTOMER_TYPE_Name'] as String?,
      countryName: json['COUNTRY_NAME'] as String?,
      cityName: json['CITY_NAME'] as String?,
      exchangeRate: (json['EXCHANGE_RATE'] as num?)?.toDouble(),
      customerName: json['CUSTOMER_NAME'] as String?,
      customerNameEng: json['CUSTOMER_NAME_ENG'] as String?,
      tel1: json['TEL1'] as String?,
      tel2: json['TEL2'] as String?,
      tel3: json['TEL3'] as String?,
      telex: json['TELEX'] as String?,
      tradeName: json['TRADE_NAME'] as String?,
      tradeRecord: json['TRADE_RECORD'] as String?,
      countryCode: json['COUNTRY_CODE'] as int?,
      cityCode: json['CITY_CODE'] as int?,
      balanceLocal: (json['BALANCE_LOCAL'] as num?)?.toDouble(),
      branchNo: json['BRANCH_NO'] as int?,
      stopCust: json['STOP_CUST'] as int?,
      initialDate: json['INITIAL_DATE'] as String?,
      checkPercent: json['CHECK_PERCENT'] as int?,
      docNature: json['DOC_NATURE'] as int?,
      cusNature: json['CUS_NATURE'] as int?,
      custTaxNo: json['CUST_TAX_NO'] as String?,
      anallytical: json['ANALLYTICAL'] as String?,
      responsibilty: json['RESPONSIBLTY'] as String?,
      districtName: json['DISTRICT_NAME'] as String?,
      streetName: json['STREET_NAME'] as String?,
      buildingNo: json['BUILDING_NO'] as String?,
      pOBox: json['P_O_BOX'] as String?,
      sambleBox: json['SAMBLE_BOX'] as String?,
      openingBalance: (json['OPENING_BALANCE'] as num?)?.toDouble(),
      openingBalanceLoc: (json['OPENING_BALANCE_LOC'] as num?)?.toDouble(),
      openingBalance1: (json['OPENING_BALANCE1'] as num?)?.toDouble(),
      openingBalance1Loc: (json['OPENING_BALANCE1_LOC'] as num?)?.toDouble(),
      prvDbCurr: (json['PRV_DB_CURR'] as num?)?.toDouble(),
      prvCdCurr: (json['PRV_CD_CURR'] as num?)?.toDouble(),
      prvDbLoc: (json['PRV_DB_LOC'] as num?)?.toDouble(),
      prvCdLoc: (json['PRV_CD_LOC'] as num?)?.toDouble(),
      curDbCurr: (json['CUR_DB_CURR'] as num?)?.toDouble(),
      curCdCurr: (json['CUR_CD_CURR'] as num?)?.toDouble(),
      curDbLoc: (json['CUR_DB_LOC'] as num?)?.toDouble(),
      curCdLoc: (json['CUR_CD_LOC'] as num?)?.toDouble(),
      balance: (json['BALANCE'] as num?)?.toDouble(),
      balanceLocal1: (json['BALANCE_LOCAL1'] as num?)?.toDouble(),
    );
  }

  // ✅ إضافة هذه الطريقة لتحويل قائمة JSON إلى قائمة من CustomerModel
  static List<CustomerModel> listFromResponse(dynamic data) {
    if (data == null) return [];

    dynamic parsedData = data;
    if (parsedData is String) {
      try {
        final decoded = jsonDecode(parsedData);
        parsedData = decoded;
      } catch (_) {
        return [];
      }
    }

    if (parsedData is Map<String, dynamic> && parsedData.containsKey('Data')) {
      parsedData = parsedData['Data'];
    }

    if (parsedData is! List) return [];

    if (parsedData.isEmpty) return [];

    return parsedData
        .whereType<Map<String, dynamic>>()
        .map((item) => CustomerModel.fromJson(item))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'CUSTOMER_NO': customerNo,
      'ADDRESS': address,
      'REF_CUSTOMER': refCustomer,
      'AREA_NO': areaNo,
      'FAX': fax,
      'NOTES': notes,
      'REPRES_NO': repreNo,
      'CURRENCY_CODE': currencyCode,
      'CUSTOMER_TYPE': customerType,
      'CUSTOMER_ACC_NO': customerAccNo,
      'CUSTOMER_ASS_NO': customerAssNo,
      'CUS_VEN_PRICE_ID': cusVenPriceId,
      'CREDIT_LIMIT': creditLimit,
      'CREDIT_LIMIT_LOC': creditLimitLoc,
      'REF_CUSTOMER_NAME': refCustomerName,
      'AREA_NAME': areaName,
      'REPRES_NAME': repreName,
      'CURRENCY_NAME': currencyName,
      'CUSTOMER_TYPE_Name': customerTypeName,
      'COUNTRY_NAME': countryName,
      'CITY_NAME': cityName,
      'EXCHANGE_RATE': exchangeRate,
      'CUSTOMER_NAME': customerName,
      'CUSTOMER_NAME_ENG': customerNameEng,
      'TEL1': tel1,
      'TEL2': tel2,
      'TEL3': tel3,
      'TELEX': telex,
      'TRADE_NAME': tradeName,
      'TRADE_RECORD': tradeRecord,
      'COUNTRY_CODE': countryCode,
      'CITY_CODE': cityCode,
      'BALANCE_LOCAL': balanceLocal,
      'BRANCH_NO': branchNo,
      'STOP_CUST': stopCust,
      'INITIAL_DATE': initialDate,
      'CHECK_PERCENT': checkPercent,
      'DOC_NATURE': docNature,
      'CUS_NATURE': cusNature,
      'CUST_TAX_NO': custTaxNo,
      'ANALLYTICAL': anallytical,
      'RESPONSIBLTY': responsibilty,
      'DISTRICT_NAME': districtName,
      'STREET_NAME': streetName,
      'BUILDING_NO': buildingNo,
      'P_O_BOX': pOBox,
      'SAMBLE_BOX': sambleBox,
      'OPENING_BALANCE': openingBalance,
      'OPENING_BALANCE_LOC': openingBalanceLoc,
      'OPENING_BALANCE1': openingBalance1,
      'OPENING_BALANCE1_LOC': openingBalance1Loc,
      'PRV_DB_CURR': prvDbCurr,
      'PRV_CD_CURR': prvCdCurr,
      'PRV_DB_LOC': prvDbLoc,
      'PRV_CD_LOC': prvCdLoc,
      'CUR_DB_CURR': curDbCurr,
      'CUR_CD_CURR': curCdCurr,
      'CUR_DB_LOC': curDbLoc,
      'CUR_CD_LOC': curCdLoc,
      'BALANCE': balance,
      'BALANCE_LOCAL1': balanceLocal1,
    };
  }

  @override
  List<Object?> get props => [
    customerNo,
    address,
    refCustomer,
    areaNo,
    fax,
    notes,
    repreNo,
    currencyCode,
    customerType,
    customerAccNo,
    customerAssNo,
    cusVenPriceId,
    creditLimit,
    creditLimitLoc,
    refCustomerName,
    areaName,
    repreName,
    currencyName,
    customerTypeName,
    countryName,
    cityName,
    exchangeRate,
    customerName,
    customerNameEng,
    tel1,
    tel2,
    tel3,
    telex,
    tradeName,
    tradeRecord,
    countryCode,
    cityCode,
    balanceLocal,
    branchNo,
    stopCust,
    initialDate,
    checkPercent,
    docNature,
    cusNature,
    custTaxNo,
    anallytical,
    responsibilty,
    districtName,
    streetName,
    buildingNo,
    pOBox,
    sambleBox,
    openingBalance,
    openingBalanceLoc,
    openingBalance1,
    openingBalance1Loc,
    prvDbCurr,
    prvCdCurr,
    prvDbLoc,
    prvCdLoc,
    curDbCurr,
    curCdCurr,
    curDbLoc,
    curCdLoc,
    balance,
    balanceLocal1,
  ];

  // Helper methods
  String get fullAddress {
    List<String> parts = [];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (districtName != null && districtName!.isNotEmpty) parts.add(districtName!);
    if (streetName != null && streetName!.isNotEmpty) parts.add(streetName!);
    if (buildingNo != null && buildingNo!.isNotEmpty) parts.add('مبنى $buildingNo');
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    if (countryName != null && countryName!.isNotEmpty) parts.add(countryName!);
    return parts.isNotEmpty ? parts.join(' - ') : 'لا يوجد عنوان';
  }

  String get formattedPhones {
    List<String> phones = [];
    if (tel1 != null && tel1!.isNotEmpty) phones.add(tel1!);
    if (tel2 != null && tel2!.isNotEmpty) phones.add(tel2!);
    if (tel3 != null && tel3!.isNotEmpty) phones.add(tel3!);
    return phones.isNotEmpty ? phones.join(' - ') : 'لا يوجد';
  }

  String get formattedBalance {
    if (balance != null) {
      return balance!.toStringAsFixed(2);
    }
    return '0.00';
  }

  CustomerModel copyWith({
    int? customerNo,
    String? address,
    int? refCustomer,
    int? areaNo,
    String? fax,
    String? notes,
    int? repreNo,
    int? currencyCode,
    int? customerType,
    double? customerAccNo,
    double? customerAssNo,
    int? cusVenPriceId,
    double? creditLimit,
    double? creditLimitLoc,
    String? refCustomerName,
    String? areaName,
    String? repreName,
    String? currencyName,
    String? customerTypeName,
    String? countryName,
    String? cityName,
    double? exchangeRate,
    String? customerName,
    String? customerNameEng,
    String? tel1,
    String? tel2,
    String? tel3,
    String? telex,
    String? tradeName,
    String? tradeRecord,
    int? countryCode,
    int? cityCode,
    double? balanceLocal,
    int? branchNo,
    int? stopCust,
    String? initialDate,
    int? checkPercent,
    int? docNature,
    int? cusNature,
    String? custTaxNo,
    String? anallytical,
    String? responsibilty,
    String? districtName,
    String? streetName,
    String? buildingNo,
    String? pOBox,
    String? sambleBox,
    double? openingBalance,
    double? openingBalanceLoc,
    double? openingBalance1,
    double? openingBalance1Loc,
    double? prvDbCurr,
    double? prvCdCurr,
    double? prvDbLoc,
    double? prvCdLoc,
    double? curDbCurr,
    double? curCdCurr,
    double? curDbLoc,
    double? curCdLoc,
    double? balance,
    double? balanceLocal1,
  }) {
    return CustomerModel(
      customerNo: customerNo ?? this.customerNo,
      address: address ?? this.address,
      refCustomer: refCustomer ?? this.refCustomer,
      areaNo: areaNo ?? this.areaNo,
      fax: fax ?? this.fax,
      notes: notes ?? this.notes,
      repreNo: repreNo ?? this.repreNo,
      currencyCode: currencyCode ?? this.currencyCode,
      customerType: customerType ?? this.customerType,
      customerAccNo: customerAccNo ?? this.customerAccNo,
      customerAssNo: customerAssNo ?? this.customerAssNo,
      cusVenPriceId: cusVenPriceId ?? this.cusVenPriceId,
      creditLimit: creditLimit ?? this.creditLimit,
      creditLimitLoc: creditLimitLoc ?? this.creditLimitLoc,
      refCustomerName: refCustomerName ?? this.refCustomerName,
      areaName: areaName ?? this.areaName,
      repreName: repreName ?? this.repreName,
      currencyName: currencyName ?? this.currencyName,
      customerTypeName: customerTypeName ?? this.customerTypeName,
      countryName: countryName ?? this.countryName,
      cityName: cityName ?? this.cityName,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      customerName: customerName ?? this.customerName,
      customerNameEng: customerNameEng ?? this.customerNameEng,
      tel1: tel1 ?? this.tel1,
      tel2: tel2 ?? this.tel2,
      tel3: tel3 ?? this.tel3,
      telex: telex ?? this.telex,
      tradeName: tradeName ?? this.tradeName,
      tradeRecord: tradeRecord ?? this.tradeRecord,
      countryCode: countryCode ?? this.countryCode,
      cityCode: cityCode ?? this.cityCode,
      balanceLocal: balanceLocal ?? this.balanceLocal,
      branchNo: branchNo ?? this.branchNo,
      stopCust: stopCust ?? this.stopCust,
      initialDate: initialDate ?? this.initialDate,
      checkPercent: checkPercent ?? this.checkPercent,
      docNature: docNature ?? this.docNature,
      cusNature: cusNature ?? this.cusNature,
      custTaxNo: custTaxNo ?? this.custTaxNo,
      anallytical: anallytical ?? this.anallytical,
      responsibilty: responsibilty ?? this.responsibilty,
      districtName: districtName ?? this.districtName,
      streetName: streetName ?? this.streetName,
      buildingNo: buildingNo ?? this.buildingNo,
      pOBox: pOBox ?? this.pOBox,
      sambleBox: sambleBox ?? this.sambleBox,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceLoc: openingBalanceLoc ?? this.openingBalanceLoc,
      openingBalance1: openingBalance1 ?? this.openingBalance1,
      openingBalance1Loc: openingBalance1Loc ?? this.openingBalance1Loc,
      prvDbCurr: prvDbCurr ?? this.prvDbCurr,
      prvCdCurr: prvCdCurr ?? this.prvCdCurr,
      prvDbLoc: prvDbLoc ?? this.prvDbLoc,
      prvCdLoc: prvCdLoc ?? this.prvCdLoc,
      curDbCurr: curDbCurr ?? this.curDbCurr,
      curCdCurr: curCdCurr ?? this.curCdCurr,
      curDbLoc: curDbLoc ?? this.curDbLoc,
      curCdLoc: curCdLoc ?? this.curCdLoc,
      balance: balance ?? this.balance,
      balanceLocal1: balanceLocal1 ?? this.balanceLocal1,
    );
  }
}
