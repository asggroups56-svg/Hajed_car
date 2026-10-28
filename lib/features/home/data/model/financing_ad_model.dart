import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/utils/financing_calculator.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/salary_transfer_type.dart';
import 'package:equatable/equatable.dart';

class FinancingAdModel extends Equatable {
  final int? programId;
  final String? programName;
  final bool? isActive;
  final String? bankOrProvider;
  final String? bankName;
  final String? bankNameEng;
  final String? bankPicturePath;
  final int? bankId;
  final String? bankCode;
  final String? startDate;
  final String? endDate;
  final double? firstInstallmentPct;
  final double? firstInstallmentPctOther;
  final double? lastInstallmentPct;
  final double? lastInstallmentPctOther;
  final double? adminFeesPct;
  final double? adminFeesPctOther;
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
  final double? insurancePct;
  final double? insurancePctOther;
  final double? insuranceAmount;
  final double? insuranceAmountOther;
  final double? paintingsVal;

  const FinancingAdModel({
    this.programId,
    this.programName,
    this.isActive,
    this.bankOrProvider,
    this.bankName,
    this.bankNameEng,
    this.bankPicturePath,
    this.bankId,
    this.bankCode,
    this.startDate,
    this.endDate,
    this.firstInstallmentPct,
    this.firstInstallmentPctOther,
    this.lastInstallmentPct,
    this.lastInstallmentPctOther,
    this.adminFeesPct,
    this.adminFeesPctOther,
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
    this.insurancePct,
    this.insurancePctOther,
    this.insuranceAmount,
    this.insuranceAmountOther,
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

    // The plates/registration fee can arrive under several names. The value
    // supplied by the offers endpoint is the amount the customer pays,
    // including VAT, so it must not be taxed again.
    final platesCost = _toDouble(
      json['PaintingsVal'] ??
          json['PAINTINGS_VAL'] ??
          json['paintingsVal'] ??
          json['PlatesVal'] ??
          json['PLATES_VAL'] ??
          json['platesVal'] ??
          json['PlateCost'] ??
          json['plateCost'] ??
          json['LicensePlatesCost'] ??
          json['licensePlatesCost'],
    );

    return FinancingAdModel(
      programId: (json['ProgramID'] as num?)?.toInt(),
      programName: json['ProgramName']?.toString(),
      isActive: json['IsActive'] as bool?,
      bankOrProvider: json['BankOrProvider']?.toString(),
      bankName:
          (json['BankName'] ??
                  json['BANK_NAME'] ??
                  json['BankOrProviderName'] ??
                  json['bankName'])
              ?.toString(),
      bankNameEng:
          (json['BankNameEng'] ??
                  json['BANK_NAME_ENG'] ??
                  json['BankOrProviderNameEng'] ??
                  json['bankNameEng'])
              ?.toString(),
      bankPicturePath:
          (json['PICTUREPATH'] ??
                  json['PicturePath'] ??
                  json['BankPicturePath'] ??
                  json['bankPicturePath'])
              ?.toString(),
      bankId: _toInt(
        json['BankID'] ?? json['BankId'] ?? json['BANK_ID'] ?? json['bankId'],
      ),
      bankCode:
          (json['BankCode'] ??
                  json['BANK_CODE'] ??
                  json['bankCode'] ??
                  json['BankOrProvider'])
              ?.toString(),
      startDate: json['StartDate']?.toString(),
      endDate: json['EndDate']?.toString(),
      firstInstallmentPct: _toDouble(json['FirstInstallmentPct']),
      firstInstallmentPctOther: _toDouble(
        json['FirstInstallmentPctother'] ??
            json['FirstInstallmentPctOther'] ??
            json['firstInstallmentPctOther'],
      ),
      lastInstallmentPct: _toDouble(json['LastInstallmentPct']),
      lastInstallmentPctOther: _toDouble(
        json['LastInstallmentPctother'] ??
            json['LastInstallmentPctOther'] ??
            json['lastInstallmentPctOther'],
      ),
      adminFeesPct: _toDouble(json['AdminFeesPct']),
      adminFeesPctOther: _toDouble(
        json['AdminFeesPctother'] ??
            json['AdminFeesPctOther'] ??
            json['adminFeesPctOther'],
      ),
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
      displayBankName:
          (json['BANK_NAME'] ??
                  json['DisplayBankName'] ??
                  json['displayBankName'])
              ?.toString(),
      insurancePct: _toDouble(
        json['InsurancePct'] ?? json['INSURANCE_PCT'] ?? json['insurancePct'],
      ),
      insurancePctOther: _toDouble(
        json['InsurancePctother'] ??
            json['InsurancePctOther'] ??
            json['INSURANCE_PCT_OTHER'] ??
            json['insurancePctOther'],
      ),
      insuranceAmount: _toDouble(
        json['InsuranceVal'] ??
            json['InsuranceValue'] ??
            json['InsuranceAmount'] ??
            json['INSURANCE_VAL'] ??
            json['insuranceAmount'] ??
            json['insuranceVal'],
      ),
      insuranceAmountOther: _toDouble(
        json['InsuranceValother'] ??
            json['InsuranceValOther'] ??
            json['InsuranceAmountOther'] ??
            json['insuranceAmountOther'],
      ),
      paintingsVal: platesCost,
    );
  }

  /// Builds the offer that a vehicle row carries on its own.
  ///
  /// [type] selects the standard or the non-transferred (`*Other`) terms. The
  /// selected term set is copied into the standard fields so the financing
  /// calculator and the financing screen keep using one set of terms.
  factory FinancingAdModel.fromCarOffer(
    GetBrandCarsDataModel car, [
    SalaryTransferType type = SalaryTransferType.transferred,
  ]) {
    double? price;
    // The offer endpoint's PRICE is the amount its percentages apply to.
    // SALE_PRICE/effectivePrice belongs to the regular inventory presentation.
    final rawPrice = (car.price ?? car.effectivePrice ?? '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    price = double.tryParse(rawPrice);
    price = price != null && price > 0 ? price : null;

    return FinancingAdModel(
      programName: car.groupName,
      modelName: car.itemName,
      modelYear: car.makeYear,
      price: price,
      salePrice: car.SALE_PRICE?.toDouble(),
      itemCode: car.itemCode,
      itemName: car.itemName,
      storeCode: car.storeCode,
      carStatus: car.carStatus,
      chassisNo: car.chassisNo,
      motorNo: car.motorNo,
      bodyColor: car.bodyColor,
      kilometerReading: car.kilometerReading,
      transmission: car.transmission,
      cylinder: car.cylinder,
      powerHourse: car.powerHourse,
      fuelCapacity: car.fuelCapacity,
      fuelType: car.fuelType,
      seatNo: car.seatNo,
      doorNo: car.doorNo,
      addType: car.addType,
      colorCode: car.colorCode,
      boardNo: car.boardNo,
      makeYear: car.makeYear,
      mobileShow: car.mobileShow,
      color: car.color,
      carImage: car.carImage,
      paintingsVal: car.platesCostWithVat,
      isActive: car.isActive,
      endDate: car.endDate,
      totalMonths: 60,
      bankOrProvider: car.bankCode,
      bankCode: car.bankCode,
      bankName: car.bankName,
      displayBankName: car.bankName,
      insuranceAmount: car.insuranceAmount,
      // Keep both term sets: the salary bank selected in the calculator
      // decides whether the transferred or the `*Other` (non-transferred)
      // percentages apply.
      firstInstallmentPct: car.firstInstallmentForType(type),
      firstInstallmentPctOther: car.firstInstallmentPctOther,
      lastInstallmentPct: car.lastInstallmentForType(type),
      lastInstallmentPctOther: car.lastInstallmentPctOther,
      adminFeesPct: car.adminFeesForType(type),
      adminFeesPctOther: car.adminFeesPctOther,
      insurancePct: car.insuranceForType(type),
      insurancePctOther: car.insurancePctOther,
      interestRate: car.interestRateForType(type),
      interestRateOther: car.interestRateOther,
    );
  }

  /// Monthly installment for an inventory row that carries its own offer
  /// terms, or `null` when the row is regular inventory.
  ///
  /// This is the single entry point for every surface that shows an
  /// installment taken from a vehicle row (home cards, budget list, comparison
  /// and car details), so the offer always wins over standard bank offers.
  static double? vehicleOfferMonthlyInstallment(
    GetBrandCarsDataModel car, {
    double? basePrice,
    double financingFee = defaultFinancingFee,
    double? platesVal,
  }) {
    if (!car.isVehicleOffer) return null;

    final offer = FinancingAdModel.fromCarOffer(car);
    final price = basePrice ?? offer.price ?? 0;
    if (price <= 0) return null;

    return offer.monthlyInstallmentForPrice(
      price,
      financingFee: financingFee,
      platesVal: platesVal,
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
    if (rawPic.startsWith('http://') || rawPic.startsWith('https://')) {
      return rawPic;
    }
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
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }
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
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return interestRateOther ?? interestRate ?? 0;
    }
    return interestRate ?? interestRateOther ?? 0;
  }

  /// Bank names from the banks endpoint, keyed by bank code.
  ///
  /// Vehicle rows usually expose the bank only as an id (`BankOrProvider`),
  /// so this directory is what lets such an offer show the bank name and
  /// decide whether the customer's salary bank is the offer bank (which is
  /// what selects the `*Other` terms for a non-transferred salary).
  static final Map<String, ({String? arabic, String? english})> _bankDirectory =
      <String, ({String? arabic, String? english})>{};

  static void registerBankDirectory(Iterable<BANKSDATAModel> banks) {
    _bankDirectory.clear();
    for (final bank in banks) {
      final code = bank.bankCode?.toString().trim();
      if (code == null || code.isEmpty) continue;
      _bankDirectory[code] = (
        arabic: bank.bankName?.trim(),
        english: bank.bankNameEng?.trim(),
      );
    }
  }

  static void clearBankDirectory() => _bankDirectory.clear();

  ({String? arabic, String? english})? get _directoryBank {
    final id = bankIdentifier;
    if (id == null || id.isEmpty) return null;
    return _bankDirectory[id];
  }

  /// Every name the directory knows for the offer bank (Arabic and English).
  List<String> get resolvedBankNames {
    final bank = _directoryBank;
    if (bank == null) return const [];
    return [
      if (bank.arabic != null && bank.arabic!.isNotEmpty) bank.arabic!,
      if (bank.english != null && bank.english!.isNotEmpty) bank.english!,
    ];
  }

  /// The bank attached to the offer, localized when possible.
  ///
  /// Offer responses often expose the bank only as an id (`BankOrProvider`)
  /// plus a localized name in one of these fields. When no name is supplied,
  /// it is resolved from the bank directory.
  String? localizedOfferBankName({bool english = false}) {
    final explicit = (displayBankName ?? bankName ?? bankNameEng)?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final bank = _directoryBank;
    if (bank == null) return null;
    final name = english
        ? (bank.english ?? bank.arabic)
        : (bank.arabic ?? bank.english);
    return (name == null || name.isEmpty) ? null : name;
  }

  String? get offerBankName => localizedOfferBankName();

  String? get bankIdentifier =>
      (bankCode ?? bankOrProvider ?? bankId?.toString())?.trim();

  /// True when [candidate] is the bank of this offer. Offer responses expose
  /// the bank name in Arabic or English (sometimes only one of them), while
  /// the customer picks the salary bank from a differently localized list.
  bool isOfferBank(String? candidate) {
    if (candidate == null || candidate.trim().isEmpty) return false;
    if (isSameBankName(candidate, bankName) ||
        isSameBankName(candidate, bankNameEng) ||
        isSameBankName(candidate, displayBankName)) {
      return true;
    }
    for (final name in resolvedBankNames) {
      if (isSameBankName(candidate, name)) return true;
    }
    return false;
  }

  /// True when the user's salary bank is different from the offer bank (غير محول / بنك آخر),
  /// meaning the salary is not with this bank and the API's `*Other` terms apply.
  ///
  /// When the salary bank matches the offer bank (نفس البنك), the salary is with this bank
  /// (محول), so the standard transfer terms apply.
  bool usesNonTransferredTerms({String? userSalaryBank}) {
    final salaryBank = userSalaryBank?.trim();
    if (salaryBank == null || salaryBank.isEmpty) return false;
    if (offerBankName == null) return false;
    return !isOfferBank(salaryBank);
  }

  /// True when the user's salary is with another bank (different from the offer bank / غير محول).
  bool isOtherBank({String? userSalaryBank}) =>
      usesNonTransferredTerms(userSalaryBank: userSalaryBank);

  /// True when the user's salary bank is the same as the offer bank (محول).
  bool isTransferredBank({String? userSalaryBank}) {
    final salaryBank = userSalaryBank?.trim();
    if (salaryBank == null || salaryBank.isEmpty) return false;
    if (offerBankName == null) return false;
    return isOfferBank(salaryBank);
  }

  double firstInstallmentForBank({String? userSalaryBank}) {
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return firstInstallmentPctOther ?? firstInstallmentPct ?? 0;
    }
    return firstInstallmentPct ?? firstInstallmentPctOther ?? 0;
  }

  double lastInstallmentForBank({String? userSalaryBank}) {
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return lastInstallmentPctOther ?? lastInstallmentPct ?? 0;
    }
    return lastInstallmentPct ?? lastInstallmentPctOther ?? 0;
  }

  double adminFeesForBank({String? userSalaryBank}) {
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return adminFeesPctOther ?? adminFeesPct ?? 0;
    }
    return adminFeesPct ?? adminFeesPctOther ?? 0;
  }

  double insuranceForBank({String? userSalaryBank}) {
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return insurancePctOther ?? insurancePct ?? 0;
    }
    return insurancePct ?? insurancePctOther ?? 0;
  }

  /// Absolute insurance amount when the API supplies one instead of (or in
  /// addition to) the percentage.
  double insuranceValueForBank({String? userSalaryBank}) {
    if (usesNonTransferredTerms(userSalaryBank: userSalaryBank)) {
      return insuranceAmountOther ?? insuranceAmount ?? 0;
    }
    return insuranceAmount ?? insuranceAmountOther ?? 0;
  }

  /// Plate/registration fee from the offer. It is the amount the customer
  /// pays and already includes VAT, so callers must not add VAT again.
  double get platesCostWithVat => paintingsVal ?? 0;

  /// Fixed financing fee. It is part of the taxable amount, so VAT applies to
  /// the car price plus this fee.
  static const double defaultFinancingFee =
      FinancingCalculator.defaultFinancingFee;

  double get _vatPercentage =>
      double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;

  /// Total car price used by financing:
  ///
  /// `(price excl. VAT + 3,000) × (1 + VAT%) + plates`
  ///
  /// The financing fee is added before VAT, and the plate/registration fee is
  /// added afterwards because it already includes VAT. [platesVal] lets a
  /// caller supply the car's plate fee when the offer does not carry it; a
  /// non-zero value wins over [platesCostWithVat].
  double carPriceWithVat({
    double? basePrice,
    double financingFee = defaultFinancingFee,
    double? platesVal,
  }) {
    final priceExclVat = basePrice ?? price ?? 0;
    final plates = (platesVal ?? 0) > 0 ? platesVal! : platesCostWithVat;
    return FinancingCalculator.priceWithVat(
      priceExcludingVat: priceExclVat,
      vatPercentage: _vatPercentage,
      financingFee: financingFee,
      plates: plates,
    );
  }

  /// Monthly installment for the offer terms.
  ///
  /// `((carPrice − down) + profit + insurance + admin − finalPayment) / months`
  /// where [carPriceWithVat] includes the fee and the plates, profit and admin
  /// are based on the financed amount, and insurance is based on that full
  /// car price. [userSalaryBank] selects the salary-transfer terms or the
  /// `*Other` (non-transferred) terms.
  double monthlyInstallmentForPrice(
    double basePrice, {
    double financingFee = defaultFinancingFee,
    double? platesVal,
    String? userSalaryBank,
  }) {
    final carPrice = carPriceWithVat(
      basePrice: basePrice,
      financingFee: financingFee,
      platesVal: platesVal,
    );
    return FinancingCalculator(
      carPriceWithVat: carPrice,
      firstInstallmentPct: firstInstallmentForBank(
        userSalaryBank: userSalaryBank,
      ),
      lastInstallmentPct: lastInstallmentForBank(
        userSalaryBank: userSalaryBank,
      ),
      annualInterestPct: getEffectiveInterestRate(
        userSalaryBank: userSalaryBank,
      ),
      annualInsurancePct: insuranceForBank(userSalaryBank: userSalaryBank),
      adminFeesPct: adminFeesForBank(userSalaryBank: userSalaryBank),
      months: totalMonths ?? 60,
    ).monthlyInstallment;
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
    final months = totalMonths ?? 60;
    // Vehicle offers use their own row price and terms, with the financing fee
    // that applies to both regular financing and vehicle offers.
    final monthlyInstallment = months > 0
        ? monthlyInstallmentForPrice(
            price ?? 0,
            financingFee: defaultFinancingFee,
            platesVal: platesCostWithVat,
          )
        : null;

    return GetBrandCarsDataModel(
      groupCode: 0,
      groupName: '',
      grName: '',
      groupParent: 0,
      groupLevel: 0,
      price: price?.toStringAsFixed(0),
      SALE_PRICE: salePrice ?? price,
      interestRate: getEffectiveInterestRate(),
      interestRateOther: interestRateOther,
      monthlyInstallment: monthlyInstallment,
      bankName: offerBankName,
      bankCode: bankCode,
      // Keep the offer's own payment terms on the rebuilt car: the car list,
      // details page and calculator all read them from the vehicle row.
      firstInstallmentPct: firstInstallmentPct,
      firstInstallmentPctOther: firstInstallmentPctOther,
      lastInstallmentPct: lastInstallmentPct,
      lastInstallmentPctOther: lastInstallmentPctOther,
      adminFeesPct: adminFeesPct,
      adminFeesPctOther: adminFeesPctOther,
      isActive: isActive,
      endDate: endDate,
      insurancePct: insurancePct,
      insurancePctOther: insurancePctOther,
      insuranceAmount: insuranceAmount,
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

  /// Total price with the fee, VAT and the plate/government fee. The plate fee
  /// is already included by [carPriceWithVat], so it is not added again.
  double priceWithVatAndPlates({double financingFee = 0}) {
    return carPriceWithVat(basePrice: price, financingFee: financingFee);
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
      'firstInstallmentPctOther': firstInstallmentPctOther,
      'lastInstallmentPct': lastInstallmentPct,
      'lastInstallmentPctOther': lastInstallmentPctOther,
      'adminFeesPct': adminFeesPct,
      'adminFeesPctOther': adminFeesPctOther,
      'insurancePct': insurancePct,
      'insurancePctOther': insurancePctOther,
      'insuranceAmount': insuranceAmount,
      'insuranceAmountOther': insuranceAmountOther,
      'bankName': offerBankName,
      'bankCode': bankIdentifier,
      'platesCostWithVat': platesCostWithVat,
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
    bankId,
    bankCode,
    startDate,
    endDate,
    firstInstallmentPct,
    firstInstallmentPctOther,
    lastInstallmentPct,
    lastInstallmentPctOther,
    adminFeesPct,
    adminFeesPctOther,
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
    displayBankName,
    insurancePct,
    insurancePctOther,
    insuranceAmount,
    insuranceAmountOther,
    paintingsVal,
  ];
}
