import 'package:equatable/equatable.dart';

class CreatOfferModel extends Equatable {
  final int? listNos;
  final int? listNo;
  final String listDate;
  final String? actListNo;
  final String? listDesc;
  final String? analytical;
  final int customerNo;
  final int represCode;
  final String taamedDate;
  final String lastDate;
  final int? areaNo;
  final int resType;
  final String paymentType;
  final String? taamedNo;
  final int guarPrimary;
  final int guarFinal;
  final int deliveryPeriod;
  final int listPeriod;
  final String? begDate;
  final String? endDate;
  final String? receivePlace;
  final String? notes;
  final String? terms;
  final num total;
  final List<OfferItemModel> subList;

  const CreatOfferModel({
    this.listNos,
    this.listNo,
    required this.listDate,
    this.actListNo,
    this.listDesc,
    this.analytical,
    required this.customerNo,
    required this.represCode,
    required this.taamedDate,
    required this.lastDate,
    this.areaNo,
    required this.resType,
    required this.paymentType,
    this.taamedNo,
    required this.guarPrimary,
    required this.guarFinal,
    required this.deliveryPeriod,
    required this.listPeriod,
    this.begDate,
    this.endDate,
    this.receivePlace,
    this.notes,
    this.terms,
    required this.total,
    required this.subList,
  });

  factory CreatOfferModel.fromJson(Map<String, dynamic> json) {
    return CreatOfferModel(
      listNos: json['LISTNOs'] is String ? int.tryParse(json['LISTNOs']) : json['LISTNOs'],
      listNo: json['LISTNO'] is String ? int.tryParse(json['LISTNO']) : json['LISTNO'],
      listDate: json['LISTDATE'] ?? '',
      actListNo: json['ACTLISTNO'],
      listDesc: json['LISTDESC'],
      analytical: json['ANALYTICAL'],
      customerNo: json['CUSTOMERNO'] ?? 0,
      represCode: json['REPRESCODE'] ?? 0,
      taamedDate: json['TAAMEDDATE'] ?? '',
      lastDate: json['LASTDATE'] ?? '',
      areaNo: json['AREANO'],
      resType: json['RESTYPE'] ?? 0,
      paymentType: json['PAYMENTTYPE'] ?? '',
      taamedNo: json['TAAMEDNO'],
      guarPrimary: json['GUARPRIMARY'] ?? 0,
      guarFinal: json['GUARFINAL'] ?? 0,
      deliveryPeriod: json['DELIVERYPERIOD'] ?? 0,
      listPeriod: json['LISTPERIOD'] ?? 0,
      begDate: json['BEGDATE'],
      endDate: json['ENDDATE'],
      receivePlace: json['RECEIVEPLACE'],
      notes: json['NOTES'],
      terms: json['TERMS'],
      total: json['TOTAL'] ?? 0,
      subList: (json['sub_list'] as List<dynamic>? ?? [])
          .map((e) => OfferItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LISTNOs': listNos,
      'LISTNO': listNo,
      'LISTDATE': listDate,
      'ACTLISTNO': actListNo ?? '',
      'LISTDESC': listDesc ?? '',
      'ANALYTICAL': analytical ?? '',
      'CUSTOMERNO': customerNo,
      'REPRESCODE': represCode,
      'TAAMEDDATE': taamedDate,
      'LASTDATE': lastDate,
      'AREANO': areaNo ?? 0,
      'RESTYPE': resType,
      'PAYMENTTYPE': paymentType,
      'TAAMEDNO': taamedNo ?? '',
      'GUARPRIMARY': guarPrimary,
      'GUARFINAL': guarFinal,
      'DELIVERYPERIOD': deliveryPeriod,
      'LISTPERIOD': listPeriod,
      'BEGDATE': begDate ?? '',
      'ENDDATE': endDate ?? '',
      'RECEIVEPLACE': receivePlace ?? '',
      'NOTES': notes ?? '',
      'TERMS': terms ?? '',
      'TOTAL': total,
      'sub_list': subList.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    listNos,
    listNo,
    listDate,
    actListNo,
    listDesc,
    analytical,
    customerNo,
    represCode,
    taamedDate,
    lastDate,
    areaNo,
    resType,
    paymentType,
    taamedNo,
    guarPrimary,
    guarFinal,
    deliveryPeriod,
    listPeriod,
    begDate,
    endDate,
    receivePlace,
    notes,
    terms,
    total,
    subList,
  ];
}

class OfferItemModel extends Equatable {
  final String itemName;
  final int colorCode;
  final String GROUP_CODE;
  final int makeYear;
  final int qnty;
  final num price;
  final String note;
  final num taxVal;
  final num paintingsVal;

  const OfferItemModel({
    required this.GROUP_CODE,
    required this.itemName,
    required this.colorCode,

    required this.makeYear,
    required this.qnty,
    required this.price,
    required this.note,
    required this.taxVal,
    required this.paintingsVal,
  });

  factory OfferItemModel.fromJson(Map<String, dynamic> json) {
    return OfferItemModel(
      itemName: json['ITEM_NAME'] ?? '',
      GROUP_CODE: json['GROUP_CODE'] ?? '',
      colorCode: json['COLOR_CODE'] ?? 0,

      makeYear: json['MAKE_YEAR'] ?? 0,
      qnty: json['QNTY'] ?? 0,
      price: json['PRICE'] ?? 0,
      note: json['NOTE'] ?? '',
      taxVal: json['TAX_VAL'] ?? 0,
      paintingsVal: json['PAINTINGS_VAL'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ITEM_NAME': itemName,
      'COLOR_CODE': colorCode,

      'MAKE_YEAR': makeYear,
      'QNTY': qnty,
      'PRICE': price,
      'NOTE': note,
      'TAX_VAL': taxVal,
      'PAINTINGS_VAL': paintingsVal,
      'GROUP_CODE': GROUP_CODE,
    };
  }

  @override
  List<Object?> get props => [
    itemName,
    colorCode,
    makeYear,
    qnty,
    price,
    note,
    taxVal,
    paintingsVal,
    GROUP_CODE,
  ];
}
