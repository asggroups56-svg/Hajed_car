import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:equatable/equatable.dart';

class FinancingAdModel extends Equatable {
  final int? programId;
  final String? programName;
  final bool? isActive;
  final String? bankOrProvider;
  final String? bankName;
  final String? bankNameEng;
  final String? bankPicturePath;
  final String? startDate;
  final String? endDate;
  final double? firstInstallmentPct;
  final double? lastInstallmentPct;
  final double? adminFeesPct;
  final String? programPic;
  final double? interestRate;
  final int? totalMonths;
  final String? modelName;
  final int? modelYear;
  final double? price;
  final String? itemCode;
  final String? itemName;
  final String? storeCode;
  final int? carStatus;
  final String? chassisNo;
  final String? motorNo;
  final String? bodyColor;
  final String? kilometerReading;
  final dynamic transmission;
  final dynamic cylinder;
  final dynamic powerHourse;
  final dynamic fuelCapacity;
  final dynamic fuelType;
  final int? seatNo;
  final int? doorNo;
  final dynamic usedClient;
  final int? addType;
  final int? colorCode;
  final String? boardNo;
  final int? makeYear;
  final bool? mobileShow;
  final String? color;
  final String? carImage;
  final String? displayBankName;
  final String? InsurancePct;

  const FinancingAdModel({
    this.programId,
    this.programName,
    this.isActive,
    this.bankOrProvider,
    this.bankName,
    this.bankNameEng,
    this.bankPicturePath,
    this.startDate,
    this.endDate,
    this.firstInstallmentPct,
    this.lastInstallmentPct,
    this.adminFeesPct,
    this.programPic,
    this.interestRate,
    this.totalMonths,
    this.modelName,
    this.price,
    this.itemCode,
    this.itemName,
    this.storeCode,
    this.carStatus,
    this.chassisNo,
    this.motorNo,
    this.bodyColor,
    this.kilometerReading,
    this.transmission,
    this.cylinder,
    this.powerHourse,
    this.fuelCapacity,
    this.fuelType,
    this.seatNo,
    this.doorNo,
    this.usedClient,
    this.addType,
    this.colorCode,
    this.boardNo,
    this.makeYear,
    this.modelYear,
    this.mobileShow,
    this.color,
    this.carImage,
    this.displayBankName,
    this.InsurancePct,
  });

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '');
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  factory FinancingAdModel.fromJson(Map<String, dynamic> json) {
    return FinancingAdModel(
      programId: (json['ProgramID'] as num?)?.toInt(),
      programName: json['ProgramName']?.toString(),
      isActive: json['IsActive'] as bool?,
      bankOrProvider: json['BankOrProvider']?.toString(),
      bankName: (json['BankName'] ?? json['BANK_NAME'] ?? json['BankOrProviderName'])?.toString(),
      bankNameEng: (json['BankNameEng'] ?? json['BANK_NAME_ENG'] ?? json['BankOrProviderNameEng'])
          ?.toString(),
      bankPicturePath: (json['PICTUREPATH'] ?? json['PicturePath'] ?? json['BankPicturePath'])
          ?.toString(),
      startDate: json['StartDate']?.toString(),
      endDate: json['EndDate']?.toString(),
      firstInstallmentPct: _toDouble(json['FirstInstallmentPct']),
      lastInstallmentPct: _toDouble(json['LastInstallmentPct']),
      adminFeesPct: _toDouble(json['AdminFeesPct']),
      programPic: json['programpic']?.toString(),
      interestRate: _toDouble(json['InterestRate']),
      totalMonths: _toInt(json['TotalMonths'] ?? json['Months'] ?? json['DurationMonths']),
      modelName: json['modelName']?.toString(),
      modelYear: _toInt(json['ModelYear']),
      price: _toDouble(json['Price']),
      itemCode: json['ITEM_CODE']?.toString(),
      itemName: json['ITEM_NAME']?.toString(),
      storeCode: json['STORE_CODE']?.toString(),
      carStatus: (json['CAR_STATUS'] as num?)?.toInt(),
      chassisNo: json['CHASSIS_NO']?.toString(),
      motorNo: json['MOTOR_NO']?.toString(),
      bodyColor: json['BODY_COLOR']?.toString(),
      kilometerReading: json['KILOMETER_READING']?.toString(),
      transmission: json['TRANSMISSION'],
      cylinder: json['CYLINDER'],
      powerHourse: json['POWER_HOURSE'],
      fuelCapacity: json['FUEL_CAPACITY'],
      fuelType: json['FUEL_TYPE'],
      seatNo: (json['SEAT_NO'] as num?)?.toInt(),
      doorNo: (json['DOOR_NO'] as num?)?.toInt(),
      usedClient: json['USED_CLIENT'],
      addType: (json['ADD_TYPE'] as num?)?.toInt(),
      colorCode: (json['COLOR_CODE'] as num?)?.toInt(),
      boardNo: json['BOARD_NO']?.toString(),
      makeYear: (json['MAKE_YEAR'] as num?)?.toInt(),
      mobileShow: json['MobileShow'] as bool?,
      color: json['Color']?.toString(),
      carImage: json['carimage']?.toString(),
      displayBankName: json['BANK_NAME']?.toString(),
      InsurancePct: (json['InsurancePct'] as num?)?.toString(),
    );
  }

  static List<FinancingAdModel> listFromResponse(dynamic data) {
    if (data == null) return [];
    final List<dynamic> jsonList = data is String ? jsonDecode(data) : data;
    return jsonList.map((e) => FinancingAdModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  String get displayPicUrl {
    final rawPic = (programPic != null && programPic!.isNotEmpty)
        ? programPic
        : (carImage != null && carImage!.isNotEmpty ? carImage!.split(',').first : null);
    if (rawPic == null || rawPic.isEmpty) return '';
    if (rawPic.startsWith('http://') || rawPic.startsWith('https://')) return rawPic;
    final cleaned = rawPic.replaceAll('../../Img/Emp/', '').replaceAll('../..', '');
    return '${Constants.baseImage}$cleaned';
  }

  // String? get displayBankName {
  //   final apiName = bankName?.trim();
  //   if (apiName != null && apiName.isNotEmpty) return apiName;

  //   final provider = bankOrProvider?.trim();
  //   const bankNames = displayBankNames;
  //   return bankNames[provider] ??
  //       (provider != null && provider.isNotEmpty && double.tryParse(provider) == null
  //           ? provider
  //           : null);
  // }

  String? get displayBankImageUrl {
    final rawPath = bankPicturePath?.trim();
    if (rawPath == null || rawPath.isEmpty) return null;
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) return rawPath;
    final cleaned = rawPath.replaceAll('../../Img/Emp/', '').replaceAll('../..', '');
    return '${Constants.baseImage}$cleaned';
  }

  double get monthlyInstallmentWithVat {
    return monthlyInstallmentForPrice(price ?? 0);
  }

  double monthlyInstallmentForPrice(double basePrice) {
    final months = totalMonths ?? 60;
    if (months <= 0) return 0;
    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice = basePrice * (1 + vatPercentage / 100);
    final downPaymentPercent = firstInstallmentPct ?? 0;
    final finalPaymentPercent = lastInstallmentPct ?? 0;
    final flatRatePercent = interestRate ?? 0;
    final insurancePercent = double.tryParse(InsurancePct ?? '0') ?? 0;
    final financeYears = months / 12;

    final downPaymentAmount = (carPrice * downPaymentPercent) / 100;
    final finalPaymentAmount = (carPrice * finalPaymentPercent) / 100;
    final netFinanceAmount = carPrice - downPaymentAmount;

    final totalInterest = netFinanceAmount * (flatRatePercent / 100) * financeYears;
    final totalInsurance = carPrice * (insurancePercent / 100) * financeYears;

    final totalFinancedWithInterest = netFinanceAmount + totalInterest + totalInsurance;
    return (totalFinancedWithInterest - finalPaymentAmount) / months;
  }

  List<String> get allCarImages {
    if (carImage == null || carImage!.isEmpty) return [];
    return carImage!.split(',').map((img) {
      if (img.startsWith('http://') || img.startsWith('https://')) return img;
      final cleaned = img.replaceAll('../../Img/Emp/', '').replaceAll('../..', '');
      return '${Constants.baseImage}$cleaned';
    }).toList();
  }

  GetBrandCarsDataModel toCarDataModel() {
    final images = allCarImages;
    final carPrice = priceWithVat;
    final months = totalMonths ?? 60;
    final downPaymentPercent = firstInstallmentPct ?? 0;
    final finalPaymentPercent = lastInstallmentPct ?? 0;
    final flatRatePercent = interestRate ?? 0;
    final insurancePercent = double.tryParse(InsurancePct ?? '0') ?? 0;
    final financeYears = months / 12;

    final downPaymentAmount = (carPrice * downPaymentPercent) / 100;
    final finalPaymentAmount = (carPrice * finalPaymentPercent) / 100;
    final netFinanceAmount = carPrice - downPaymentAmount;

    final totalInterest = netFinanceAmount * (flatRatePercent / 100) * financeYears;
    final totalInsurance = carPrice * (insurancePercent / 100) * financeYears;

    final totalFinancedWithInterest = netFinanceAmount + totalInterest + totalInsurance;
    final monthlyInstallment = months > 0
        ? (totalFinancedWithInterest - finalPaymentAmount) / months
        : null;

    return GetBrandCarsDataModel(
      groupCode: 0,
      groupName: '',
      grName: '',
      groupParent: 0,
      groupLevel: 0,
      price: price?.toStringAsFixed(0),
      interestRate: interestRate,
      monthlyInstallment: monthlyInstallment,
      itemCode: itemCode ?? '',
      itemType: 0,
      itemName: itemName ?? modelName ?? '',
      groupCode1: 0,
      storeCode: storeCode ?? '1',
      carStatus: carStatus ?? 1,
      carType: 0,
      chassisNo: chassisNo ?? '',
      motorNo: motorNo,
      bodyColor: bodyColor ?? color ?? '',
      kilometerReading: kilometerReading,
      transmission: (transmission is int)
          ? transmission
          : (int.tryParse(transmission?.toString() ?? '1') ?? 1),
      cylinder: cylinder?.toString() ?? '4',
      powerHourse: powerHourse?.toString() ?? '',
      fuelCapacity: fuelCapacity?.toString() ?? '',
      fuelType: fuelType?.toString() ?? 'بنزين',
      seatNo: seatNo ?? 5,
      doorNo: doorNo ?? 4,
      usedClient: usedClient?.toString(),
      addType: addType ?? 1,
      colorCode: colorCode ?? 1,
      boardNo: boardNo,
      makeYear: makeYear ?? modelYear ?? 2025,
      notifyType: 0,
      notifyDate: null,
      supplierCd: 0,
      buyDate: '',
      trNo: 0,
      customsCardNo: null,
      reasonId: 0,
      mobileShow: mobileShow ?? true,
      color: color ?? bodyColor ?? '',
      extraImages: images,
      carImage: images.isNotEmpty ? images.first : null,
    );
  }

  double get priceWithVat {
    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    return (price ?? 0) * (1 + vatPercentage / 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': itemName ?? modelName ?? programName ?? 'سيارة',
      'groupCode': '0',
      'itemCode': itemCode ?? '0',
      'chassisNo': chassisNo ?? '',
      'image': displayPicUrl,
      'extraImages': allCarImages,
      'brand': programName ?? 'برنامج تمويلي',
      'price': price != null ? price!.toStringAsFixed(0) : '0',
      'year': (makeYear ?? modelYear ?? 2025).toString(),
      'mileage': kilometerReading != null ? '$kilometerReading كم' : '0 كم',
      'engine': cylinder != null ? '$cylinder Cyl' : 'V4',
      'video_id': 'D7O8J5vVf-M',
      'isFavorite': false,
      'carStatus': carStatus ?? 1,
      'carStatusText': '',
      'CHASSIS_NO': chassisNo ?? '',
      'MOTOR_NO': motorNo,
      'KILOMETER_READING': kilometerReading,
      'CYLINDER': cylinder,
      'POWER_HOURSE': powerHourse,
      'FUEL_CAPACITY': fuelCapacity,
      'SEAT_NO': seatNo,
      'DOOR_NO': doorNo,
      'Color': color ?? bodyColor ?? '',
      'BODY_COLOR': bodyColor ?? color ?? '',
      'FUEL_TYPE': fuelType ?? 'بنزين',
      'CUSTOMS_CARD_NO': null,
      'TRANSMISSION': transmission ?? 1,
      'MAKE_YEAR': makeYear ?? modelYear ?? 2025,
      'GR_NAME': programName ?? '',
      'GROUP_NAME': programName ?? '',
      'interestRate': interestRate,
      'firstInstallmentPct': firstInstallmentPct,
      'lastInstallmentPct': lastInstallmentPct,
      'adminFeesPct': adminFeesPct,
    };
  }

  @override
  List<Object?> get props => [
    programId,
    programName,
    isActive,
    bankOrProvider,
    bankName,
    bankNameEng,
    bankPicturePath,
    startDate,
    endDate,
    firstInstallmentPct,
    lastInstallmentPct,
    adminFeesPct,
    programPic,
    interestRate,
    totalMonths,
    modelName,
    modelYear,
    price,
    itemCode,
    itemName,
    carImage,
  ];
}
