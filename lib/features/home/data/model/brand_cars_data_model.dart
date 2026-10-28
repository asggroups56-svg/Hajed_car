import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/utils/financing_calculator.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/home/data/model/salary_transfer_type.dart';
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
  final String? specificName;

  /// Returns individual specification items parsed from [specificName].
  List<String> get specificSpecifications {
    if (specificName == null || specificName!.trim().isEmpty) return [];
    return specificName!
        .split(RegExp(r'[;\n؛]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
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
  final num? SALE_PRICE;
  final double? paintingsVal;
  final String? bankName;
  final String? bankCode;
  final double? insurancePct;
  final double? insurancePctOther;
  final double? insuranceAmount;
  final String? luxury;

  // Offer terms attached directly to the inventory row by GetprandcarsData.
  // They are the standard (salary transferred to the same bank) terms; the
  // `*Other` variants apply when the salary is transferred to another bank.
  final double? firstInstallmentPct;
  final double? firstInstallmentPctOther;
  final double? lastInstallmentPct;
  final double? lastInstallmentPctOther;
  final double? adminFeesPct;
  final double? adminFeesPctOther;
  final double? interestRateOther;
  final String? endDate;
  final bool? isActive;

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
    this.specificName,
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
    this.SALE_PRICE,
    this.paintingsVal,
    this.bankName,
    this.bankCode,
    this.insurancePct,
    this.insurancePctOther,
    this.insuranceAmount,
    this.luxury,
    this.firstInstallmentPct,
    this.firstInstallmentPctOther,
    this.lastInstallmentPct,
    this.lastInstallmentPctOther,
    this.adminFeesPct,
    this.adminFeesPctOther,
    this.interestRateOther,
    this.endDate,
    this.isActive,
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

  /// Plate/registration fee attached to the offer. It already includes VAT.
  double get platesCostWithVat => paintingsVal ?? 0;

  String get formattedPriceWithVat {
    final rawPrice = effectivePrice;
    if (rawPrice == null ||
        rawPrice.isEmpty ||
        rawPrice == 'null' ||
        rawPrice == '---') {
      return '---';
    }
    final isAlreadyFormatted = rawPrice.contains(',');
    final cleanPriceStr = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final double originalPrice = double.tryParse(cleanPriceStr) ?? 0;
    if (originalPrice <= 0) return '---';

    final formatter = NumberFormat('#,##0', 'en_US');
    // Always add paintingsVal regardless of whether price is pre-formatted or not
    final double plates = paintingsVal ?? 0;
    if (isAlreadyFormatted) {
      // Price already includes VAT — just add paintings/plates value
      return formatter.format(originalPrice + plates);
    }

    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage =
        double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = originalPrice * (1 + (vatPercentage / 100));
    // Cash price = price + VAT + plates/paintings value
    return formatter.format(priceWithVat + plates);
  }

  /// Promotional inventory can supply its customer price in SALE_PRICE
  /// without a corresponding PRICE field.
  String? get effectivePrice {
    if (SALE_PRICE != null && SALE_PRICE! > 0) return SALE_PRICE.toString();
    return price;
  }

  Map<String, dynamic> toMap() {
    final String uniqueId = chassisNo.isNotEmpty && chassisNo != 'null'
        ? 'chassis_$chassisNo'
        : '${groupCode}_${itemName}_${makeYear}_${bodyColor}_${colorCode}_${motorNo ?? ''}_${price ?? ''}';

    return {
      'unique_id': uniqueId,
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
      'SPECIFIC_NAME': specificName,
      'specificName': specificName,
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
      "SALE_PRICE": SALE_PRICE,
      'PaintingsVal': paintingsVal,
      'PAINTINGS_VAL': paintingsVal,
      'paintingsVal': paintingsVal,
      'platesCostWithVat': platesCostWithVat,
      'bankName': bankName,
      'BANK_NAME': bankName,
      'bankCode': bankCode,
      'insurancePct': insurancePct,
      'insurancePctOther': insurancePctOther,
      'insuranceAmount': insuranceAmount,
      'LUXURY': luxury,
      'luxury': luxury,
      'FirstInstallmentPct': firstInstallmentPct,
      'FirstInstallmentPctother': firstInstallmentPctOther,
      'firstInstallmentPct': firstInstallmentPct,
      'firstInstallmentPctOther': firstInstallmentPctOther,
      'LastInstallmentPct': lastInstallmentPct,
      'LastInstallmentPctother': lastInstallmentPctOther,
      'lastInstallmentPct': lastInstallmentPct,
      'lastInstallmentPctOther': lastInstallmentPctOther,
      'AdminFeesPct': adminFeesPct,
      'AdminFeesPctother': adminFeesPctOther,
      'adminFeesPct': adminFeesPct,
      'adminFeesPctOther': adminFeesPctOther,
      'InterestRate_other': interestRateOther,
      'interestRateOther': interestRateOther,
      'EndDate': endDate,
      'endDate': endDate,
      'IsActive': isActive,
      'isActive': isActive,
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
    if (isVehicleOffer) return true;
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

  /// True when the inventory row carries any offer/payment terms.
  ///
  /// Insurance alone is not treated as an offer: it can be attached to regular
  /// inventory, while at least one of the payment/profit/fee terms only comes
  /// back for actual offers. Zero placeholders do not count either, so rows
  /// that only repeat `0` values are not marked as offers.
  bool get hasOfferTerms {
    // `BankOrProvider` and `EndDate` identify an attached offer even when its
    // valid terms are explicitly zero (for example 0% profit or no admin fee).
    // Ordinary inventory may include null/zero placeholders for percentages,
    // so those values alone do not identify an offer.
    final hasOfferIdentity = (bankCode?.trim().isNotEmpty ?? false) ||
        (endDate?.trim().isNotEmpty ?? false);
    return hasOfferIdentity ||
        (firstInstallmentPct ?? 0) > 0 ||
        (firstInstallmentPctOther ?? 0) > 0 ||
        (lastInstallmentPct ?? 0) > 0 ||
        (lastInstallmentPctOther ?? 0) > 0 ||
        (adminFeesPct ?? 0) > 0 ||
        (adminFeesPctOther ?? 0) > 0 ||
        (interestRate ?? 0) > 0 ||
        (interestRateOther ?? 0) > 0;
  }

  /// True when the offer has not expired. A missing end date or a missing
  /// `IsActive` flag is treated as active, matching the server's defaults.
  bool get isOfferActive {
    if (isActive == false) return false;
    final expiry = offerExpiryDate;
    if (expiry == null) return true;
    final endOfDay = DateTime(
      expiry.year,
      expiry.month,
      expiry.day,
      23,
      59,
      59,
    );
    return endOfDay.isAfter(DateTime.now());
  }

  /// The car row is a vehicle offer that can be presented on its own.
  bool get isVehicleOffer => hasOfferTerms && isOfferActive;

  DateTime? get offerExpiryDate {
    final raw = endDate?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') return null;

    final parts = raw.split(RegExp(r'[/-]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);
      if (first != null && second != null && third != null) {
        // Accept both `dd/MM/yyyy` (the offer endpoint) and `yyyy-MM-dd`.
        if (first > 31) return DateTime(first, second, third);
        return DateTime(third, second, first);
      }
    }
    return DateTime.tryParse(raw);
  }

  // Each term prefers the field for the requested salary-transfer type and
  // falls back to the other type's field when it is missing. The endpoint does
  // not always fill both sets, and a missing field must not turn a real offer
  // term into zero (which would mix in standard financing behaviour).
  double firstInstallmentForType(SalaryTransferType type) {
    if (type == SalaryTransferType.nonTransferred) {
      return firstInstallmentPctOther ?? firstInstallmentPct ?? 0;
    }
    return firstInstallmentPct ?? firstInstallmentPctOther ?? 0;
  }

  double lastInstallmentForType(SalaryTransferType type) {
    if (type == SalaryTransferType.nonTransferred) {
      return lastInstallmentPctOther ?? lastInstallmentPct ?? 0;
    }
    return lastInstallmentPct ?? lastInstallmentPctOther ?? 0;
  }

  double adminFeesForType(SalaryTransferType type) {
    if (type == SalaryTransferType.nonTransferred) {
      return adminFeesPctOther ?? adminFeesPct ?? 0;
    }
    return adminFeesPct ?? adminFeesPctOther ?? 0;
  }

  double insuranceForType(SalaryTransferType type) {
    if (type == SalaryTransferType.nonTransferred) {
      return insurancePctOther ?? insurancePct ?? 0;
    }
    return insurancePct ?? insurancePctOther ?? 0;
  }

  double interestRateForType(SalaryTransferType type) {
    if (type == SalaryTransferType.nonTransferred) {
      return interestRateOther ?? interestRate ?? 0;
    }
    return interestRate ?? interestRateOther ?? 0;
  }

  double get _vatPercentage =>
      double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;

  /// Base customer price before VAT. `SALE_PRICE` wins when it is set.
  double get _basePrice {
    final raw = (effectivePrice ?? '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  /// Total financing price: `(price + fee) × (1 + VAT) + plates`.
  double carPriceWithVat({
    double? basePrice,
    double financingFee = FinancingCalculator.defaultFinancingFee,
    double? platesVal,
  }) {
    final plates = (platesVal ?? 0) > 0 ? platesVal! : platesCostWithVat;
    return FinancingCalculator.priceWithVat(
      priceExcludingVat: basePrice ?? _basePrice,
      vatPercentage: _vatPercentage,
      financingFee: financingFee,
      plates: plates,
    );
  }

  FinancingCalculator financingCalculatorFor(
    SalaryTransferType type, {
    int months = 60,
    double financingFee = FinancingCalculator.defaultFinancingFee,
    double? platesVal,
  }) {
    return FinancingCalculator(
      carPriceWithVat: carPriceWithVat(
        financingFee: financingFee,
        platesVal: platesVal,
      ),
      firstInstallmentPct: firstInstallmentForType(type),
      lastInstallmentPct: lastInstallmentForType(type),
      annualInterestPct: interestRateForType(type),
      annualInsurancePct: insuranceForType(type),
      adminFeesPct: adminFeesForType(type),
      months: months,
    );
  }

  /// Monthly installment for this car's own offer terms.
  double monthlyInstallmentForType(
    SalaryTransferType type, {
    int months = 60,
    double financingFee = FinancingCalculator.defaultFinancingFee,
    double? platesVal,
  }) {
    return financingCalculatorFor(
      type,
      months: months,
      financingFee: financingFee,
      platesVal: platesVal,
    ).monthlyInstallment;
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
      specificName: (specificName != null && specificName!.trim().isNotEmpty)
          ? specificName
          : other.specificName,
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
      SALE_PRICE: SALE_PRICE != null && SALE_PRICE! > 0
          ? SALE_PRICE
          : other.SALE_PRICE,
      paintingsVal: paintingsVal ?? other.paintingsVal,
      bankName: bankName ?? other.bankName,
      bankCode: bankCode ?? other.bankCode,
      insurancePct: insurancePct ?? other.insurancePct,
      insurancePctOther: insurancePctOther ?? other.insurancePctOther,
      insuranceAmount: insuranceAmount ?? other.insuranceAmount,
      luxury: luxury ?? other.luxury,
      firstInstallmentPct: firstInstallmentPct ?? other.firstInstallmentPct,
      firstInstallmentPctOther:
          firstInstallmentPctOther ?? other.firstInstallmentPctOther,
      lastInstallmentPct: lastInstallmentPct ?? other.lastInstallmentPct,
      lastInstallmentPctOther:
          lastInstallmentPctOther ?? other.lastInstallmentPctOther,
      adminFeesPct: adminFeesPct ?? other.adminFeesPct,
      adminFeesPctOther: adminFeesPctOther ?? other.adminFeesPctOther,
      interestRateOther: interestRateOther ?? other.interestRateOther,
      endDate: endDate ?? other.endDate,
      isActive: isActive ?? other.isActive,
    );
  }

  GetBrandCarsDataModel copyWith({
    List<String>? extraImages,
    bool? isFavorite,
    bool? mobileShow,
    String? price,
    String? carSpecification,
    String? specificName,
    double? interestRate,
    double? monthlyInstallment,
    double? interestRateOther,
    String? groupName,
    String? grName,
    String? luxury,
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
      specificName: specificName ?? this.specificName,
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
      SALE_PRICE: SALE_PRICE,
      paintingsVal: paintingsVal,
      bankName: bankName,
      bankCode: bankCode,
      insurancePct: insurancePct,
      insurancePctOther: insurancePctOther,
      insuranceAmount: insuranceAmount,
      luxury: luxury ?? this.luxury,
      firstInstallmentPct: firstInstallmentPct,
      firstInstallmentPctOther: firstInstallmentPctOther,
      lastInstallmentPct: lastInstallmentPct,
      lastInstallmentPctOther: lastInstallmentPctOther,
      adminFeesPct: adminFeesPct,
      adminFeesPctOther: adminFeesPctOther,
      interestRateOther: interestRateOther ?? this.interestRateOther,
      endDate: endDate,
      isActive: isActive,
    );
  }

  factory GetBrandCarsDataModel.fromJson(Map<String, dynamic> json) {
    String getString(String key1, [String? key2, String? key3]) {
      dynamic val;

      dynamic findInJson(String k) {
        if (json.containsKey(k)) return json[k];
        final normalizedK = k.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        for (var entry in json.entries) {
          final normalizedEntryKey = entry.key.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]'),
            '',
          );
          if (normalizedEntryKey == normalizedK) return entry.value;
        }
        return null;
      }

      val = findInJson(key1);
      if (val == null && key2 != null) val = findInJson(key2);
      if (val == null && key3 != null) val = findInJson(key3);

      if (val == null || val.toString().toLowerCase().trim() == 'null')
        return '';
      return val.toString().trim();
    }

    final List<String> extraFromMap =
        (json['extraImages'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final String rawImages = getString('carimage', 'image');
    final List<String> splitImages = rawImages.isNotEmpty
        ? rawImages
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
        : [];

    final Set<String> allUniqueImages = {...extraFromMap, ...splitImages};
    final List<String> finalImagesList = allUniqueImages.toList();

    double? getDouble(String key1, [String? key2, String? key3]) {
      final value = getString(key1, key2, key3).replaceAll(',', '');
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    int getInt(String key1, [String? key2, String? key3]) {
      final value = getString(key1, key2, key3).replaceAll(',', '');
      // Some inventory responses serialize numeric database fields as `12.0`.
      // int.tryParse rejects that representation and used to turn a valid
      // colour code into 0.
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }

    return GetBrandCarsDataModel(
      groupCode: getInt('GROUP_CODE', 'GROUP_CODE'),
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
          json['CAR_SPECIFICATION']?.toString() ??
          json['carSpecification']?.toString(),
      specificName: () {
        final raw = json['SPECIFIC_NAME']?.toString() ??
            json['specificName']?.toString() ??
            getString('SPECIFIC_NAME', 'specificName');
        if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
        return raw;
      }(),
      chassisNo: getString('CHASSIS_NO', 'chassisNo'),
      motorNo: json['MOTOR_NO']?.toString() ?? json['motorNo']?.toString(),
      bodyColor: getString('BODY_COLOR', 'bodyColor', 'interiorColor'),
      kilometerReading:
          json['KILOMETER_READING']?.toString() ??
          json['kilometerReading'] ??
          json['mileage']?.toString(),
      transmission:
          int.tryParse(getString('TRANSMISSION', 'transmission')) ?? 0,
      cylinder: getString('CYLINDER', 'cylinder', 'engine'),
      powerHourse: getString('POWER_HOURSE', 'powerHourse'),
      fuelCapacity: getString('FUEL_CAPACITY', 'fuelCapacity'),
      fuelType: getString('FUEL_TYPE', 'fuelType'),
      seatNo: int.tryParse(getString('SEAT_NO', 'seatNo')) ?? 0,
      doorNo: int.tryParse(getString('DOOR_NO', 'doorNo')) ?? 0,
      usedClient:
          json['USED_CLIENT']?.toString() ?? json['usedClient']?.toString(),
      addType: int.tryParse(getString('ADD_TYPE', 'addType')) ?? 0,
      // The service has returned this field using all of these spellings.
      // It is required by the booking endpoint, so never discard it merely
      // because the response uses a different casing or a decimal string.
      colorCode: getInt('COLOR_CODE', 'COLOR_CODE', 'COLOR_CODE'),
      boardNo: json['BOARD_NO']?.toString() ?? json['boardNo']?.toString(),
      makeYear: int.tryParse(getString('MAKE_YEAR', 'makeYear', 'year')) ?? 0,
      notifyType: int.tryParse(getString('NOTIFY_TYPE', 'notifyType')) ?? 0,
      notifyDate:
          json['NOTIFY_DATE']?.toString() ?? json['notifyDate']?.toString(),
      supplierCd: int.tryParse(getString('SUPPLIER_CD', 'supplierCd')) ?? 0,
      buyDate: getString('BUY_DATE', 'buyDate'),
      trNo: int.tryParse(getString('TR_NO', 'trNo')) ?? 0,
      customsCardNo:
          json['CUSTOMS_CARD_NO']?.toString() ??
          json['customsCardNo']?.toString(),
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
      installments: getString(
        'installments',
        'installmentPrice',
        'MonthlyInstallment',
      ),
      cashPrice: getString('cashPrice'),
      monthlyInstallment: getDouble(
        'monthlyInstallment',
        'MonthlyInstallment',
        'installmentPrice',
      ),
      interestRate: getDouble('interestRate', 'InterestRate'),
      paintingsVal:
          (json['PaintingsVal'] as num?)?.toDouble() ??
          (json['PAINTINGS_VAL'] as num?)?.toDouble() ??
          (json['paintingsVal'] as num?)?.toDouble() ??
          getDouble('PaintingsVal', 'PAINTINGS_VAL', 'paintingsVal'),
      bankName:
          json['BankName']?.toString() ??
          json['BANK_NAME']?.toString() ??
          json['bankName']?.toString() ??
          json['BankOrProviderName']?.toString(),
      bankCode:
          json['BankCode']?.toString() ??
          json['BANK_CODE']?.toString() ??
          json['bankCode']?.toString() ??
          json['BankOrProvider']?.toString(),
      insurancePct: getDouble(
        'InsurancePct',
        'INSURANCE_PCT',
        'insurancePct',
      ),
      insurancePctOther: getDouble(
        'InsurancePctother',
        'InsurancePctOther',
        'insurancePctOther',
      ),
      insuranceAmount: getDouble(
        'InsuranceVal',
        'InsuranceAmount',
        'insuranceAmount',
      ),
      luxury:
          json['LUXURY']?.toString() ??
          json['luxury']?.toString() ??
          json['Luxury']?.toString(),
      firstInstallmentPct: getDouble(
        'FirstInstallmentPct',
        'firstInstallmentPct',
      ),
      firstInstallmentPctOther: getDouble(
        'FirstInstallmentPctother',
        'FirstInstallmentPctOther',
        'firstInstallmentPctOther',
      ),
      lastInstallmentPct: getDouble(
        'LastInstallmentPct',
        'lastInstallmentPct',
      ),
      lastInstallmentPctOther: getDouble(
        'LastInstallmentPctother',
        'LastInstallmentPctOther',
        'lastInstallmentPctOther',
      ),
      adminFeesPct: getDouble(
        'AdminFeesPct',
        'adminFeesPct',
      ),
      adminFeesPctOther: getDouble(
        'AdminFeesPctother',
        'AdminFeesPctOther',
        'adminFeesPctOther',
      ),
      interestRateOther: getDouble(
        'InterestRate_other',
        'InterestRateOther',
        'interestRateOther',
      ),
      endDate:
          json['EndDate']?.toString() ??
          json['endDate']?.toString() ??
          json['END_DATE']?.toString(),
      isActive: () {
        final raw =
            json['IsActive'] ?? json['isActive'] ?? json['ISACTIVE'];
        if (raw == null) return null;
        if (raw is bool) return raw;
        // Some deployments send 1/0 or "true"/"false" instead of a bool.
        if (raw is num) return raw != 0;
        final normalized = raw.toString().trim().toLowerCase();
        if (normalized == '1' || normalized == 'true') return true;
        if (normalized == '0' || normalized == 'false') return false;
        return null;
      }(),
      customerName:
          json['CUSTOMER_NAME']?.toString() ??
          json['customerName']?.toString() ??
          json['CUSTOMERNAME']?.toString(),
      reservedName:
          json['REPRES_NAME']?.toString() ??
          json['reservedName']?.toString() ??
          json['REPRESNAME']?.toString(),
      SALE_PRICE: getDouble('SALE_PRICE', 'salePrice', 'PRICE') ?? 0,
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

    final allCars = decoded
        .map((e) => GetBrandCarsDataModel.fromJson(e))
        .toList();

    final Map<String, GetBrandCarsDataModel> uniqueCars = {};

    for (int i = 0; i < allCars.length; i++) {
      final car = allCars[i];
      // Build a meaningful dedup key. When itemCode & chassisNo are both
      // empty (some endpoints don't return them), fall back to a composite
      // of fields that distinguish different inventory rows.
      final String key;
      if (car.chassisNo.isNotEmpty && car.chassisNo != 'null') {
        key = 'chassis_${car.chassisNo}';
      } else {
        key =
            '${car.groupCode}_${car.itemName}_${car.bodyColor}_${car.makeYear}_${car.colorCode}_${car.motorNo ?? ''}_${car.carImage ?? ''}_$i';
      }

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
    specificName,
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
    paintingsVal,
    bankName,
    bankCode,
    insurancePct,
    insurancePctOther,
    insuranceAmount,
    luxury,
    firstInstallmentPct,
    firstInstallmentPctOther,
    lastInstallmentPct,
    lastInstallmentPctOther,
    adminFeesPct,
    adminFeesPctOther,
    interestRateOther,
    endDate,
    isActive,
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
      costPrice: price != null
          ? double.tryParse(price!.replaceAll(RegExp(r'[^0-9.]'), ''))
          : null,
      colorCode: colorCode,
      mobileShow: mobileShow,
      paintingsVal: paintingsVal,
      specificName: specificName,
      Luxury: luxury,
    );
  }
}
