import 'package:equatable/equatable.dart';

class AddBookingPermissionModel extends Equatable {
  final String lpoNos;
  final String lpono;
  final int listNo;
  final String analytical;
  final int customerNo;
  final int represCode;
  final String fDate;
  final String lDate;
  final String lpoDate;
  final int storeCode;
  final String taamedNo;
  final String payCond;
  final int guarFinal;
  final String notes;
  final String userAdd;
  final String requiredDoc;
  final List<SubLpoModel> subLpo;

  const AddBookingPermissionModel({
    required this.lpoNos,
    required this.lpono,
    required this.listNo,
    required this.analytical,
    required this.customerNo,
    required this.represCode,
    required this.fDate,
    required this.lDate,
    required this.lpoDate,
    required this.storeCode,
    required this.taamedNo,
    required this.payCond,
    required this.guarFinal,
    required this.notes,
    required this.userAdd,
    required this.requiredDoc,
    required this.subLpo,
  });

  factory AddBookingPermissionModel.fromJson(Map<String, dynamic> json) {
    return AddBookingPermissionModel(
      lpoNos: json['LPONOs']?.toString() ?? '',
      lpono: json['LPONO']?.toString() ?? '',
      listNo: int.tryParse(json['LISTNO']?.toString() ?? '') ?? 0,
      analytical: json['ANALYTICAL']?.toString() ?? '',
      customerNo: int.tryParse(json['CUSTOMERNO']?.toString() ?? '') ?? 0,
      represCode: int.tryParse(json['REPRESCODE']?.toString() ?? '') ?? 0,
      fDate: json['RESERVBEGIN']?.toString() ?? '',
      lDate: json['RESERVEND']?.toString() ?? '',
      lpoDate: json['LPODATE']?.toString() ?? '',
      storeCode: int.tryParse(json['STORECODE']?.toString() ?? '') ?? 0,
      taamedNo: json['TAAMEDNO']?.toString() ?? '',
      payCond: json['PAYCOND']?.toString() ?? '',
      guarFinal: int.tryParse(json['GUARFINAL']?.toString() ?? '') ?? 0,
      notes: json['NOTES']?.toString() ?? '',
      userAdd: json['USERADD']?.toString() ?? '',
      requiredDoc: json['REQUIREDDOC']?.toString() ?? '',
      subLpo:
          (json['sub_lpo'] as List<dynamic>?)
              ?.map((e) => SubLpoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "LPONOs": lpoNos,
      "LPONO": lpono,
      "LISTNO": listNo,
      "ANALYTICAL": analytical,
      "CUSTOMERNO": customerNo,
      "REPRESCODE": represCode,
      "RESERVBEGIN": fDate,
      "RESERVEND": lDate,
      "LPODATE": lpoDate,
      "STORECODE": storeCode,
      "TAAMEDNO": taamedNo,
      "PAYCOND": payCond,
      "GUARFINAL": guarFinal,
      "NOTES": notes,
      "USERADD": userAdd,
      "REQUIREDDOC": requiredDoc,
      "sub_lpo": subLpo.map((e) => e.toJson()).toList(),
    };
  }

  AddBookingPermissionModel copyWith({
    String? lpoNos,
    String? lpono,
    int? listNo,
    String? analytical,
    int? customerNo,
    int? represCode,
    String? fDate,
    String? lDate,
    String? lpoDate,
    int? storeCode,
    String? taamedNo,
    String? payCond,
    int? guarFinal,
    String? notes,
    String? userAdd,
    String? requiredDoc,
    List<SubLpoModel>? subLpo,
  }) {
    return AddBookingPermissionModel(
      lpoNos: lpoNos ?? this.lpoNos,
      lpono: lpono ?? this.lpono,
      listNo: listNo ?? this.listNo,
      analytical: analytical ?? this.analytical,
      customerNo: customerNo ?? this.customerNo,
      represCode: represCode ?? this.represCode,
      fDate: fDate ?? this.fDate,
      lDate: lDate ?? this.lDate,
      lpoDate: lpoDate ?? this.lpoDate,
      storeCode: storeCode ?? this.storeCode,
      taamedNo: taamedNo ?? this.taamedNo,
      payCond: payCond ?? this.payCond,
      guarFinal: guarFinal ?? this.guarFinal,
      notes: notes ?? this.notes,
      userAdd: userAdd ?? this.userAdd,
      requiredDoc: requiredDoc ?? this.requiredDoc,
      subLpo: subLpo ?? this.subLpo,
    );
  }

  @override
  List<Object?> get props => [
    lpoNos,
    lpono,
    listNo,
    analytical,
    customerNo,
    represCode,
    fDate,
    lDate,
    lpoDate,
    storeCode,
    taamedNo,
    payCond,
    guarFinal,
    notes,
    userAdd,
    requiredDoc,
    subLpo,
  ];
}

class SubLpoModel extends Equatable {
  // final String itemCode;
  final String itemName;
  final String chassisNo;
  final double price;
  final double advancedAmount;
  final int storeCode;
  final num TAX_VAL;
  final String GROUP_CODE;

  const SubLpoModel({
    // required this.itemCode,
    required this.itemName,
    required this.chassisNo,
    required this.price,
    required this.advancedAmount,
    required this.storeCode,
    required this.TAX_VAL,
    required this.GROUP_CODE,
  });

  factory SubLpoModel.fromJson(Map<String, dynamic> json) {
    return SubLpoModel(
      GROUP_CODE: json['GROUP_CODE']?.toString() ?? '',
      // itemCode: json['ITEM_CODE']?.toString() ?? '',
      itemName: json['ITEM_NAME']?.toString() ?? '',
      chassisNo: json['CHASSIS_NO']?.toString() ?? '',
      price: double.tryParse(json['PRICE']?.toString() ?? '') ?? 0.0,
      advancedAmount: double.tryParse(json['ADVANCED_AMOUNT']?.toString() ?? '') ?? 0.0,
      storeCode: int.tryParse(json['STORE_CODE']?.toString() ?? '') ?? 0,
      TAX_VAL: num.tryParse(json['TAX_VAL']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // "ITEM_CODE": itemCode,
      "ITEM_NAME": itemName,
      "CHASSIS_NO": chassisNo,
      "PRICE": price,
      "ADVANCED_AMOUNT": advancedAmount,
      "STORE_CODE": storeCode,
      "TAX_VAL": TAX_VAL,
      "GROUP_CODE": GROUP_CODE,
    };
  }

  SubLpoModel copyWith({
    String? itemCode,
    String? itemName,
    String? chassisNo,
    double? price,
    double? advancedAmount,
    int? storeCode,
    num? TAX_VAL,
    String? GROUP_CODE,
  }) {
    return SubLpoModel(
      // itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      chassisNo: chassisNo ?? this.chassisNo,
      price: price ?? this.price,
      advancedAmount: advancedAmount ?? this.advancedAmount,
      storeCode: storeCode ?? this.storeCode,
      TAX_VAL: TAX_VAL ?? this.TAX_VAL,
      GROUP_CODE: GROUP_CODE ?? this.GROUP_CODE,
    );
  }

  @override
  List<Object?> get props => [
    // itemCode,
    itemName,
    chassisNo,
    price,
    advancedAmount,
    storeCode,
    TAX_VAL,
    GROUP_CODE,
  ];
}
