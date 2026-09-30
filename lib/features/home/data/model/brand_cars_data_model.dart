import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

class GetBrandCarsDataModel extends Equatable {
  final int groupCode;
  final String groupName;
  final String grName;
  final int groupParent;
  final int groupLevel;
  final String? price;
  final String itemCode;
  final int itemType;
  final String itemName;
  final String? itemEName;
  final String? itemSub;
  final String? notes;
  final int groupCode1;
  final String storeCode;
  final int carStatus;
  final int carType;
  final String? carSpecification;
  final String chassisNo;
  final String? motorNo;
  final String bodyColor;
  final String? kilometerReading;
  final int transmission;
  final String cylinder;
  final String powerHourse;
  final String fuelCapacity;
  final String fuelType;
  final int seatNo;
  final int doorNo;
  final String? usedClient;
  final int addType;
  final int colorCode;
  final String? boardNo;
  final int makeYear;
  final int notifyType;
  final String? notifyDate;
  final int supplierCd;
  final String buyDate;
  final int trNo;
  final String? customsCardNo;
  final int reasonId;
  final bool mobileShow;
  final String color;
  final List<String> extraImages;
  final String? carImage;

  // Mock/Extra fields for UI consistency
  final String? discount;
  final String? oldPrice;
  final String? installments;
  final String? cashPrice;
  final double? interestRate;
  final double? monthlyInstallment;
  final bool isFavorite;
  final bool isTamaraAvailable;
  final String videoId;

  const GetBrandCarsDataModel({
    required this.groupCode,
    required this.groupName,
    required this.grName,
    required this.groupParent,
    required this.groupLevel,
    this.price,
    required this.itemCode,
    required this.itemType,
    required this.itemName,
    this.itemEName,
    this.itemSub,
    this.notes,
    required this.groupCode1,
    required this.storeCode,
    required this.carStatus,
    required this.carType,
    this.carSpecification,
    required this.chassisNo,
    this.motorNo,
    required this.bodyColor,
    this.kilometerReading,
    required this.transmission,
    required this.cylinder,
    required this.powerHourse,
    required this.fuelCapacity,
    required this.fuelType,
    required this.seatNo,
    required this.doorNo,
    this.usedClient,
    required this.addType,
    required this.colorCode,
    this.boardNo,
    required this.makeYear,
    required this.notifyType,
    this.notifyDate,
    required this.supplierCd,
    required this.buyDate,
    required this.trNo,
    this.customsCardNo,
    required this.reasonId,
    required this.mobileShow,
    required this.carImage,
    required this.color,
    this.extraImages = const [],
    this.discount,
    this.oldPrice,
    this.installments,
    this.cashPrice,
    this.interestRate,
    this.monthlyInstallment,
    this.isFavorite = false,
    this.isTamaraAvailable = true,
    this.videoId = 'D7O8J5vVf-M',
    this.customerName,
    this.reservedName,
  });

  final String? customerName;
  final String? reservedName;

  String _sanitizeImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final cleaned = path.replaceAll('../../Img/Emp/', '');
    return Uri.parse('${Constants.baseImage}$cleaned').toString();
  }

  String get fullCarImage => _sanitizeImageUrl(carImage ?? '');

  List<String> get allImages {
    final List<String> images = [];
    if (fullCarImage.isNotEmpty) images.add(fullCarImage);
    for (var img in extraImages) {
      final full = _sanitizeImageUrl(img);
      if (full.isNotEmpty && !images.contains(full)) {
        images.add(full);
      }
    }
    return images;
  }

  String get formattedPriceWithVat {
    if (price == null || price!.isEmpty || price == 'null' || price == '---') return '---';
    final isAlreadyFormatted = price!.contains(',');
    final cleanPriceStr = price.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    final double originalPrice = double.tryParse(cleanPriceStr) ?? 0;
    if (originalPrice <= 0) return '---';

    final formatter = NumberFormat('#,##0', 'en_US');
    if (isAlreadyFormatted) {
      return formatter.format(originalPrice);
    }

    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = originalPrice * (1 + (vatPercentage / 100));

    return formatter.format(priceWithVat);
  }

  Map<String, dynamic> toMap() {
    return {
      'unique_id': '${itemCode}_$chassisNo',
      'GROUP_CODE': groupCode,
      'GROUP_NAME': groupName,
      'GR_NAME': grName,
      'GROUP_PARENT': groupParent,
      'GROUP_LEVEL': groupLevel,
      'PRICE': price,
      'ITEM_CODE': itemCode,
      'ITEM_TYPE': itemType,
      'ITEM_NAME': itemName,
      'ITEM_ENAME': itemEName,
      'ITEM_SUB': itemSub,
      'NOTES': notes,
      'GROUP_CODE1': groupCode1,
      'STORE_CODE': storeCode,
      'CAR_STATUS': carStatus,
      'CAR_TYPE': carType,
      'CAR_SPECIFICATION': carSpecification,
      'CHASSIS_NO': chassisNo,
      'MOTOR_NO': motorNo,
      'BODY_COLOR': bodyColor,
      'KILOMETER_READING': kilometerReading,
      'TRANSMISSION': transmission,
      'CYLINDER': cylinder,
      'POWER_HOURSE': powerHourse,
      'FUEL_CAPACITY': fuelCapacity,
      'FUEL_TYPE': fuelType,
      'SEAT_NO': seatNo,
      'DOOR_NO': doorNo,
      'USED_CLIENT': usedClient,
      'ADD_TYPE': addType,
      'COLOR_CODE': colorCode,
      'BOARD_NO': boardNo,
      'MAKE_YEAR': makeYear,
      'NOTIFY_TYPE': notifyType,
      'NOTIFY_DATE': notifyDate,
      'SUPPLIER_CD': supplierCd,
      'BUY_DATE': buyDate,
      'TR_NO': trNo,
      'CUSTOMS_CARD_NO': customsCardNo,
      'REASON_ID': reasonId,
      'MobileShow': mobileShow,
      'carimage': carImage,
      'Color': color,
      'extraImages': extraImages,
      'name': itemName,
      'image': fullCarImage,
      'price': price,
      'brand': groupName,
      'year': makeYear.toString(),
      'mileage': kilometerReading ?? '0',
      'engine': cylinder,
      'discount': discount,
      'oldPrice': oldPrice,
      'installments': installments,
      'cashPrice': cashPrice ?? price,
      'interestRate': interestRate,
      'monthlyInstallment': monthlyInstallment,
      'isFavorite': isFavorite,
      'isTamaraAvailable': isTamaraAvailable,
      'video_id': videoId,
    };
  }

  String get carStatusText {
    switch (carStatus) {
      case 1:
        return AppLocaleKey.agentCarAvailable.tr();
      case 2:
        return AppLocaleKey.agentCarReserved.tr();
      case 3:
        return AppLocaleKey.agentCarSold.tr();
      default:
        return '';
    }
  }

  bool get hasFinancing {
    if (monthlyInstallment != null && monthlyInstallment! > 0) return true;
    if (interestRate != null && interestRate! > 0) return true;
    if (installments != null &&
        installments!.trim().isNotEmpty &&
        installments!.trim() != '0' &&
        installments!.trim().toLowerCase() != 'null') {
      return true;
    }
    return false;
  }

  GetBrandCarsDataModel merge(GetBrandCarsDataModel other) {
    return GetBrandCarsDataModel(
      groupCode: groupCode,
      groupName: groupName,
      grName: grName,
      groupParent: groupParent,
      groupLevel: groupLevel,
      price: price ?? other.price,
      itemCode: itemCode,
      itemType: itemType,
      itemName: itemName,
      itemEName: itemEName ?? other.itemEName,
      itemSub: itemSub ?? other.itemSub,
      notes: notes ?? other.notes,
      groupCode1: groupCode1,
      storeCode: storeCode,
      carStatus: carStatus != 0 ? carStatus : other.carStatus,
      carType: carType != 0 ? carType : other.carType,
      carSpecification: carSpecification ?? other.carSpecification,
      chassisNo: chassisNo,
      motorNo: motorNo ?? other.motorNo,
      bodyColor: bodyColor.isNotEmpty ? bodyColor : other.bodyColor,
      kilometerReading: kilometerReading ?? other.kilometerReading,
      transmission: transmission != 0 ? transmission : other.transmission,
      cylinder: cylinder.isNotEmpty ? cylinder : other.cylinder,
      powerHourse: powerHourse.isNotEmpty ? powerHourse : other.powerHourse,
      fuelCapacity: fuelCapacity.isNotEmpty ? fuelCapacity : other.fuelCapacity,
      fuelType: fuelType.isNotEmpty ? fuelType : other.fuelType,
      seatNo: seatNo != 0 ? seatNo : other.seatNo,
      doorNo: doorNo != 0 ? doorNo : other.doorNo,
      usedClient: usedClient ?? other.usedClient,
      addType: addType != 0 ? addType : other.addType,
      colorCode: colorCode != 0 ? colorCode : other.colorCode,
      boardNo: boardNo ?? other.boardNo,
      makeYear: makeYear != 0 ? makeYear : other.makeYear,
      notifyType: notifyType != 0 ? notifyType : other.notifyType,
      notifyDate: notifyDate ?? other.notifyDate,
      supplierCd: supplierCd != 0 ? supplierCd : other.supplierCd,
      buyDate: buyDate.isNotEmpty ? buyDate : other.buyDate,
      trNo: trNo != 0 ? trNo : other.trNo,
      customsCardNo: customsCardNo ?? other.customsCardNo,
      reasonId: reasonId != 0 ? reasonId : other.reasonId,
      mobileShow: mobileShow || other.mobileShow,
      carImage: carImage ?? other.carImage,
      color: color.isNotEmpty ? color : other.color,
      extraImages: {...extraImages, ...other.extraImages}.toList(),
      discount: discount ?? other.discount,
      oldPrice: oldPrice ?? other.oldPrice,
      installments: installments ?? other.installments,
      cashPrice: cashPrice ?? other.cashPrice,
      interestRate: interestRate ?? other.interestRate,
      monthlyInstallment: monthlyInstallment ?? other.monthlyInstallment,
      isFavorite: isFavorite || other.isFavorite,
      isTamaraAvailable: isTamaraAvailable,
      videoId: videoId,
      customerName: customerName ?? other.customerName,
      reservedName: reservedName ?? other.reservedName,
    );
  }

  GetBrandCarsDataModel copyWith({
    List<String>? extraImages,
    bool? isFavorite,
    bool? mobileShow,
    String? price,
    String? carSpecification,
    double? interestRate,
    double? monthlyInstallment,
    String? groupName,
    String? grName,
  }) {
    return GetBrandCarsDataModel(
      groupCode: groupCode,
      groupName: groupName ?? this.groupName,
      grName: grName ?? this.grName,
      groupParent: groupParent,
      groupLevel: groupLevel,
      price: price ?? this.price,
      itemCode: itemCode,
      itemType: itemType,
      itemName: itemName,
      itemEName: itemEName,
      itemSub: itemSub,
      notes: notes,
      groupCode1: groupCode1,
      storeCode: storeCode,
      carStatus: carStatus,
      carType: carType,
      carSpecification: carSpecification ?? this.carSpecification,
      chassisNo: chassisNo,
      motorNo: motorNo,
      bodyColor: bodyColor,
      kilometerReading: kilometerReading,
      transmission: transmission,
      cylinder: cylinder,
      powerHourse: powerHourse,
      fuelCapacity: fuelCapacity,
      fuelType: fuelType,
      seatNo: seatNo,
      doorNo: doorNo,
      usedClient: usedClient,
      addType: addType,
      colorCode: colorCode,
      boardNo: boardNo,
      makeYear: makeYear,
      notifyType: notifyType,
      notifyDate: notifyDate,
      supplierCd: supplierCd,
      buyDate: buyDate,
      trNo: trNo,
      customsCardNo: customsCardNo,
      reasonId: reasonId,
      mobileShow: mobileShow ?? this.mobileShow,
      carImage: carImage,
      color: color,
      extraImages: extraImages ?? this.extraImages,
      discount: discount,
      oldPrice: oldPrice,
      installments: installments,
      cashPrice: cashPrice,
      interestRate: interestRate ?? this.interestRate,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      isFavorite: isFavorite ?? this.isFavorite,
      isTamaraAvailable: isTamaraAvailable,
      videoId: videoId,
      customerName: customerName,
      reservedName: reservedName,
    );
  }

  factory GetBrandCarsDataModel.fromJson(Map<String, dynamic> json) {
    String getString(String key1, [String? key2, String? key3]) {
      dynamic val;

      dynamic findInJson(String k) {
        if (json.containsKey(k)) return json[k];
        final normalizedK = k.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (var entry in json.entries) {
          final normalizedEntryKey = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (normalizedEntryKey == normalizedK) return entry.value;
        }
        return null;
      }

      val = findInJson(key1);
      if (val == null && key2 != null) val = findInJson(key2);
      if (val == null && key3 != null) val = findInJson(key3);

      if (val == null || val.toString().toLowerCase().trim() == 'null') return '';
      return val.toString().trim();
    }

    final List<String> extraFromMap =
        (json['extraImages'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final String rawImages = getString('carimage', 'image');
    final List<String> splitImages = rawImages.isNotEmpty
        ? rawImages.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : [];

    final Set<String> allUniqueImages = {...extraFromMap, ...splitImages};
    final List<String> finalImagesList = allUniqueImages.toList();

    double? getDouble(String key1, [String? key2, String? key3]) {
      final value = getString(key1, key2, key3).replaceAll(',', '');
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    return GetBrandCarsDataModel(
      groupCode: int.tryParse(getString('GROUP_CODE', 'groupCode')) ?? 0,
      groupName: getString('GROUP_NAME', 'brand', 'groupName'),
      grName: getString('GR_NAME', 'grName'),
      groupParent: int.tryParse(getString('GROUP_PARENT', 'groupParent')) ?? 0,
      groupLevel: int.tryParse(getString('GROUP_LEVEL', 'groupLevel')) ?? 0,
      price: json['PRICE']?.toString() ?? json['price']?.toString(),
      itemCode: getString('ITEM_CODE', 'itemCode'),
      itemType: int.tryParse(getString('ITEM_TYPE', 'itemType')) ?? 0,
      itemName: getString('ITEM_NAME', 'name', 'itemName'),
      itemEName: json['ITEM_ENAME'] ?? json['itemEName'],
      itemSub: json['ITEM_SUB'] ?? json['itemSub'],
      notes: json['NOTES'] ?? json['notes'],
      groupCode1: int.tryParse(getString('GROUP_CODE1', 'groupCode1')) ?? 0,
      storeCode: getString('STORE_CODE', 'storeCode'),
      carStatus: int.tryParse(getString('CAR_STATUS', 'carStatus')) ?? 0,
      carType: int.tryParse(getString('CAR_TYPE', 'carType')) ?? 0,
      carSpecification:
          json['CAR_SPECIFICATION']?.toString() ?? json['carSpecification']?.toString(),
      chassisNo: getString('CHASSIS_NO', 'chassisNo'),
      motorNo: json['MOTOR_NO']?.toString() ?? json['motorNo']?.toString(),
      bodyColor: getString('BODY_COLOR', 'bodyColor', 'interiorColor'),
      kilometerReading:
          json['KILOMETER_READING']?.toString() ??
          json['kilometerReading'] ??
          json['mileage']?.toString(),
      transmission: int.tryParse(getString('TRANSMISSION', 'transmission')) ?? 0,
      cylinder: getString('CYLINDER', 'cylinder', 'engine'),
      powerHourse: getString('POWER_HOURSE', 'powerHourse'),
      fuelCapacity: getString('FUEL_CAPACITY', 'fuelCapacity'),
      fuelType: getString('FUEL_TYPE', 'fuelType'),
      seatNo: int.tryParse(getString('SEAT_NO', 'seatNo')) ?? 0,
      doorNo: int.tryParse(getString('DOOR_NO', 'doorNo')) ?? 0,
      usedClient: json['USED_CLIENT']?.toString() ?? json['usedClient']?.toString(),
      addType: int.tryParse(getString('ADD_TYPE', 'addType')) ?? 0,
      colorCode: int.tryParse(getString('COLOR_CODE', 'colorCode')) ?? 0,
      boardNo: json['BOARD_NO']?.toString() ?? json['boardNo']?.toString(),
      makeYear: int.tryParse(getString('MAKE_YEAR', 'makeYear', 'year')) ?? 0,
      notifyType: int.tryParse(getString('NOTIFY_TYPE', 'notifyType')) ?? 0,
      notifyDate: json['NOTIFY_DATE']?.toString() ?? json['notifyDate']?.toString(),
      supplierCd: int.tryParse(getString('SUPPLIER_CD', 'supplierCd')) ?? 0,
      buyDate: getString('BUY_DATE', 'buyDate'),
      trNo: int.tryParse(getString('TR_NO', 'trNo')) ?? 0,
      customsCardNo: json['CUSTOMS_CARD_NO']?.toString() ?? json['customsCardNo']?.toString(),
      reasonId: int.tryParse(getString('REASON_ID', 'reasonId')) ?? 0,
      mobileShow:
          json['MobileShow'] == true ||
          json['mobileShow'] == true ||
          json['MobileShow']?.toString().toLowerCase() == 'true',
      carImage: finalImagesList.isNotEmpty ? finalImagesList.first : '',
      color: getString('Color', 'color', 'exteriorColor'),
      extraImages: finalImagesList,
      discount: json['discount']?.toString(),
      oldPrice: json['oldPrice']?.toString(),
      installments: getString('installments', 'installmentPrice', 'MonthlyInstallment'),
      cashPrice: getString('cashPrice'),
      monthlyInstallment: getDouble('monthlyInstallment', 'MonthlyInstallment', 'installmentPrice'),
      interestRate: getDouble('interestRate', 'InterestRate'),
      customerName:
          json['CUSTOMER_NAME']?.toString() ??
          json['customerName']?.toString() ??
          json['CUSTOMERNAME']?.toString(),
      reservedName:
          json['REPRES_NAME']?.toString() ??
          json['reservedName']?.toString() ??
          json['REPRESNAME']?.toString(),
    );
  }

  static List<GetBrandCarsDataModel> listFromResponse(dynamic data) {
    if (data == null) return [];

    dynamic parsedData = data;
    if (parsedData is Map<String, dynamic> && parsedData.containsKey('Data')) {
      parsedData = parsedData['Data'];
    }

    final List<dynamic> decoded;
    if (parsedData is String) {
      final result = jsonDecode(parsedData);
      if (result is List) {
        decoded = result;
      } else {
        return [];
      }
    } else if (parsedData is List) {
      decoded = parsedData;
    } else {
      return [];
    }

    final allCars = decoded.map((e) => GetBrandCarsDataModel.fromJson(e)).toList();

    final Map<String, GetBrandCarsDataModel> uniqueCars = {};

    for (final car in allCars) {
      final key = '${car.itemCode}_${car.chassisNo}';

      if (!uniqueCars.containsKey(key)) {
        uniqueCars[key] = car;
      } else {
        // Use the merge method to combine data from duplicate entries
        uniqueCars[key] = uniqueCars[key]!.merge(car);
      }
    }

    return uniqueCars.values.toList();
  }

  @override
  List<Object?> get props => [
    groupCode,
    groupName,
    grName,
    groupParent,
    groupLevel,
    price,
    itemCode,
    itemType,
    itemName,
    itemEName,
    itemSub,
    notes,
    groupCode1,
    storeCode,
    carStatus,
    carType,
    carSpecification,
    chassisNo,
    motorNo,
    bodyColor,
    kilometerReading,
    transmission,
    cylinder,
    powerHourse,
    fuelCapacity,
    fuelType,
    seatNo,
    doorNo,
    usedClient,
    addType,
    colorCode,
    boardNo,
    makeYear,
    notifyType,
    notifyDate,
    supplierCd,
    buyDate,
    trNo,
    customsCardNo,
    reasonId,
    mobileShow,
    carImage,
    color,
    extraImages,
    discount,
    oldPrice,
    installments,
    cashPrice,
    interestRate,
    monthlyInstallment,
    isFavorite,
    isTamaraAvailable,
    videoId,
  ];

  CarModel toCarModel() {
    return CarModel(
      itemCode: itemCode,
      itemName: itemName,
      groupCode: groupCode,
      storeCode: storeCode,
      carStatus: carStatus,
      carType: carType,
      chassisNo: chassisNo,
      bodyColor: bodyColor,
      transmission: transmission,
      fuelType: fuelType,
      makeYear: makeYear,
      costPrice: price != null ? double.tryParse(price!.replaceAll(RegExp(r'[^0-9.]'), '')) : null,
      colorCode: colorCode,
      mobileShow: mobileShow,
    );
  }
}
