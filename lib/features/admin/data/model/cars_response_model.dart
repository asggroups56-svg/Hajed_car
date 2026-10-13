import 'dart:convert';

import 'package:car/core/network/contants.dart';
import 'package:equatable/equatable.dart';

class CarsModel extends Equatable {
  final List<CarModel> data;

  const CarsModel({required this.data});

  factory CarsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> parsedData = json['Data'] != null ? jsonDecode(json['Data']) : [];

    return CarsModel(data: parsedData.map((e) => CarModel.fromJson(e)).toList());
  }

  @override
  List<Object?> get props => [data];
}

class CarModel extends Equatable {
  final String? itemCode;
  final String? itemName;
  final int? groupCode;
  final String? storeCode;
  final int? carStatus;
  final int? carType;
  final String? chassisNo;
  final String? bodyColor;
  final int? transmission;
  final String? fuelType;
  final int? makeYear;
  final double? costPrice;
  final double? salePrice;
  final int? colorCode;
  final bool? mobileShow;
  final String? customerName;
  final String? ADVANCED_AMOUNT;
  final String? carimage;
  final String? color;

  /// LPO number returned by the reserved-cars endpoint (LPONO field).
  final String? lpoNo;
  final String? reservedName;

  const CarModel({
    this.ADVANCED_AMOUNT,
    this.itemCode,
    this.itemName,
    this.groupCode,
    this.storeCode,
    this.carStatus,
    this.carType,
    this.chassisNo,
    this.bodyColor,
    this.transmission,
    this.fuelType,
    this.makeYear,
    this.costPrice,
    this.salePrice,
    this.colorCode,
    this.mobileShow,
    this.lpoNo,
    this.reservedName,
    this.customerName,
    this.carimage,
    this.color,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      itemCode: json['ITEM_CODE'],
      itemName: json['ITEM_NAME'],
      groupCode: json['GROUP_CODE'],
      storeCode: json['STORE_CODE'],
      carStatus: json['CAR_STATUS'],
      carType: json['CAR_TYPE'],
      chassisNo: json['CHASSIS_NO'],
      bodyColor: json['BODY_COLOR'],
      transmission: json['TRANSMISSION'],
      fuelType: json['FUEL_TYPE'],
      makeYear: json['MAKE_YEAR'],
      costPrice:
          (json['COST_PRICE'] as num?)?.toDouble() ??
          double.tryParse(json['COST_PRICE']?.toString() ?? ''),
      salePrice:
          (json['SALE_PRICE'] as num?)?.toDouble() ??
          double.tryParse(json['SALE_PRICE']?.toString() ?? '') ??
          (json['Sale_Price'] as num?)?.toDouble() ??
          (json['salePrice'] as num?)?.toDouble() ??
          (json['PRICE'] as num?)?.toDouble() ??
          double.tryParse(json['PRICE']?.toString() ?? ''),
      colorCode: json['COLOR_CODE'],
      mobileShow: json['MobileShow'],
      reservedName: json['REPRES_NAME']?.toString(),
      lpoNo: json['LPONO']?.toString() ?? json['LPO_NO']?.toString(),
      customerName: json['CUSTOMER_NAME']?.toString(),
      ADVANCED_AMOUNT: json['ADVANCED_AMOUNT']?.toString(),
      carimage:
          json['carimage']?.toString() ??
          json['CAR_IMAGE']?.toString() ??
          json['carImage']?.toString(),
      color: json['Color']?.toString(),
    );
  }

  List<String> get imageUrls {
    if (carimage == null || carimage!.trim().isEmpty || carimage!.trim().toLowerCase() == 'null') {
      return const [];
    }

    return carimage!
        .split(',')
        .map((image) {
          final path = image.trim();
          if (path.isEmpty) return '';
          final url = path.startsWith('http://') || path.startsWith('https://')
              ? path
              : '${Constants.baseImage}${path.replaceFirst(RegExp(r'^[/\\]+'), '')}';
          return Uri.encodeFull(url);
        })
        .where((image) => image.isNotEmpty)
        .toList();
  }

  @override
  List<Object?> get props => [
    itemCode,
    itemName,
    groupCode,
    storeCode,
    carStatus,
    carType,
    chassisNo,
    bodyColor,
    transmission,
    fuelType,
    makeYear,
    costPrice,
    salePrice,
    colorCode,
    mobileShow,
    lpoNo,
    reservedName,
    customerName,
    ADVANCED_AMOUNT,
    carimage,
  ];
}
