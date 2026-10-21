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
  final double? interestRateOther;
  final int? totalMonths;
  final String? modelName;
  final int? modelYear;
  final double? price;
  final double? salePrice;
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
  final double? paintingsVal;

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
    this.interestRateOther,
    this.totalMonths,
    this.modelName,
    this.price,
    this.salePrice,
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
    this.paintingsVal,
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
    final salePrice = _toDouble(
      json['SALE_PRICE'] ??
          json['SalePrice'] ??
          json['salePrice'] ??
          json['SALEPRICE'],
    );
    final regularPrice = _toDouble(
      json['Price'] ?? json['PRICE'] ?? json['price'],
    );

    return FinancingAdModel(
      programId: (json['ProgramID'] as num?)?.toInt(),
      programName: json['ProgramName']?.toString(),
      isActive: json['IsActive'] as bool?,
      bankOrProvider: json['BankOrProvider']?.toString(),
      bankName:
          (json['BankName'] ?? json['BANK_NAME'] ?? json['BankOrProviderName'])
              ?.toString(),
      bankNameEng:
          (json['BankNameEng'] ??
                  json['BANK_NAME_ENG'] ??
                  json['BankOrProviderNameEng'])
              ?.toString(),
      bankPicturePath:
          (json['PICTUREPATH'] ??
                  json['PicturePath'] ??
                  json['BankPicturePath'])
              ?.toString(),
      startDate: json['StartDate']?.toString(),
      endDate: json['EndDate']?.toString(),
      firstInstallmentPct: _toDouble(json['FirstInstallmentPct']),
      lastInstallmentPct: _toDouble(json['LastInstallmentPct']),
      adminFeesPct: _toDouble(json['AdminFeesPct']),
      programPic: json['programpic']?.toString(),
      interestRate: _toDouble(json['InterestRate']),
      interestRateOther: _toDouble(
        json['InterestRate_other'] ??
            json['InterestRateOther'] ??
            json['interestRateOther'] ??
            json['INTEREST_RATE_OTHER'],
      ),
      totalMonths: _toInt(
        json['TotalMonths'] ?? json['Months'] ?? json['DurationMonths'],
      ),
      modelName: json['modelName']?.toString(),
      modelYear: _toInt(json['ModelYear']),
      // Offer responses can contain only SALE_PRICE. It is the price that
      // should be shown and used in the offer calculations.
      price: salePrice != null && salePrice > 0 ? salePrice : regularPrice,
      salePrice: salePrice,
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
      paintingsVal:
          (json['PaintingsVal'] as num?)?.toDouble() ??
          (json['PAINTINGS_VAL'] as num?)?.toDouble() ??
          (json['paintingsVal'] as num?)?.toDouble() ??
          _toDouble(
            json['PaintingsVal'] ??
                json['PAINTINGS_VAL'] ??
                json['paintingsVal'],
          ),
    );
  }

  static List<FinancingAdModel> listFromResponse(dynamic data) {
    if (data == null) return [];
    final List<dynamic> jsonList = data is String ? jsonDecode(data) : data;
    return jsonList
        .map((e) => FinancingAdModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String get displayPicUrl {
    final rawPic = (programPic != null && programPic!.isNotEmpty)
        ? programPic
        : (carImage != null && carImage!.isNotEmpty
              ? carImage!.split(',').first
              : null);
    if (rawPic == null || rawPic.isEmpty) return '';
    if (rawPic.startsWith('http://') || rawPic.startsWith('https://'))
      return rawPic;
    final cleaned = rawPic
        .replaceAll('../../Img/Emp/', '')
        .replaceAll('../..', '');
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
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://'))
      return rawPath;
    final cleaned = rawPath
        .replaceAll('../../Img/Emp/', '')
        .replaceAll('../..', '');
    return '${Constants.baseImage}$cleaned';
  }

  double get monthlyInstallmentWithVat {
    return monthlyInstallmentForPrice(price ?? 0);
  }

  static bool isSameBankName(String? bank1, String? bank2) {
    if (bank1 == null || bank2 == null) return false;
    final b1 = _normalizeBankName(bank1);
    final b2 = _normalizeBankName(bank2);
    if (b1.isEmpty || b2.isEmpty) return false;
    return b1 == b2 || b1.contains(b2) || b2.contains(b1);
  }

  static String _normalizeBankName(String name) {
    return name
        .toLowerCase()
        .replaceAll('بنك', '')
        .replaceAll('مصرف', '')
        .replaceAll('شركة', '')
        .replaceAll('bank', '')
        .replaceAll('al', '')
        .replaceAll('ال', '')
        .replaceAll(RegExp(r'[^\w\u0621-\u064A]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  double getEffectiveInterestRate({String? userSalaryBank}) {
    if (userSalaryBank != null && userSalaryBank.trim().isNotEmpty) {
      final activeBank = displayBankName ?? bankName;
      if (activeBank != null && !isSameBankName(userSalaryBank, activeBank)) {
        if (interestRateOther != null && interestRateOther! > 0) {
          return interestRateOther!;
        }
      }
    }
    return interestRate ?? 0;
  }

  double monthlyInstallmentForPrice(
    double basePrice, {
    double financingFee = 3000,
    double platesVal = 0,
    String? userSalaryBank,
  }) {
    final months = totalMonths ?? 60;
    if (months <= 0) return 0;
    final vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice =
        ((basePrice + financingFee) * (1 + vatPercentage / 100)) + platesVal;
    final downPaymentPercent = firstInstallmentPct ?? 0;
    final finalPaymentPercent = lastInstallmentPct ?? 0;
    final flatRatePercent = getEffectiveInterestRate(
      userSalaryBank: userSalaryBank,
    );
    final insurancePercent = double.tryParse(InsurancePct ?? '0') ?? 0;
    final financeYears = months / 12;

    final downPaymentAmount = (carPrice * downPaymentPercent) / 100;
    final finalPaymentAmount = (carPrice * finalPaymentPercent) / 100;
    final netFinanceAmount = carPrice - downPaymentAmount;

    final totalInterest =
        netFinanceAmount * (flatRatePercent / 100) * financeYears;
    final totalInsurance =
        netFinanceAmount * (insurancePercent / 100) * financeYears;

    final totalFinancedWithInterest =
        netFinanceAmount + totalInterest + totalInsurance;
    return (totalFinancedWithInterest - finalPaymentAmount) / months;
  }

  List<String> get allCarImages {
    if (carImage == null || carImage!.isEmpty) return [];
    return carImage!.split(',').map((img) {
      if (img.startsWith('http://') || img.startsWith('https://')) return img;
      final cleaned = img
          .replaceAll('../../Img/Emp/', '')
          .replaceAll('../..', '');
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

    final totalInterest =
        netFinanceAmount * (flatRatePercent / 100) * financeYears;
    final totalInsurance =
        netFinanceAmount * (insurancePercent / 100) * financeYears;

    final totalFinancedWithInterest =
        netFinanceAmount + totalInterest + totalInsurance;
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
      SALE_PRICE: salePrice ?? price,
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
      paintingsVal: paintingsVal,
    );
  }

  double get priceWithVat {
    final vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
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
      'SALE_PRICE': salePrice,
      'year': (makeYear ?? modelYear ?? 2025).toString(),
      'mileage': kilometerReading != null ? '$kilometerReading كم' : '0 كم',
      'engine': cylinder != null ? '$cylinder Cyl' : 'V4',
      'video_id': 'D7O8J5vVf-M',
      'isFavorite': false,
      'PaintingsVal': paintingsVal,
      'PAINTINGS_VAL': paintingsVal,
      'paintingsVal': paintingsVal,
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
      'InterestRate_other': interestRateOther,
      'interestRateOther': interestRateOther,
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
    interestRateOther,
    totalMonths,
    modelName,
    modelYear,
    price,
    salePrice,
    itemCode,
    itemName,
    carImage,
  ];
}
