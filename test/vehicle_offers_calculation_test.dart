import 'dart:convert';
import 'dart:io';

import 'package:car/core/utils/financing_calculator.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/data/model/salary_transfer_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Inventory row copied from `GetprandcarsData` (terms + a regular row).
const _offerCarJson = '''
{
  "GROUP_CODE": 3601114,
  "GROUP_NAME": "C200",
  "GR_NAME": "MERCEDES - A - 1.3CC - H-C200",
  "GROUP_PARENT": 360111,
  "GROUP_LEVEL": 5,
  "PRICE": 150000.0,
  "ITEM_NAME": "MERCEDES - A - 1.3CC - H - C200",
  "CAR_STATUS": 1,
  "ADD_TYPE": 1,
  "COLOR_CODE": 2,
  "MAKE_YEAR": 2023,
  "MobileShow": true,
  "BODY_COLOR": "ابيض",
  "KILOMETER_READING": "0",
  "TRANSMISSION": 1,
  "CYLINDER": "5",
  "FUEL_TYPE": "بنزين",
  "SEAT_NO": 6,
  "DOOR_NO": 4,
  "PaintingsVal": 0.0,
  "carimage": "car.png",
  "Color": "اسود",
  "AdminFeesPct": 0.00,
  "AdminFeesPctother": null,
  "BankOrProvider": "2",
  "FirstInstallmentPct": 10.00,
  "FirstInstallmentPctother": 0.00,
  "InsurancePct": 2.00,
  "InsurancePctother": 0.00,
  "LastInstallmentPct": 50.00,
  "LastInstallmentPctother": 50.00,
  "IsActive": true,
  "EndDate": "31/12/2099",
  "InterestRate": 3.00,
  "InterestRate_other": null
}
''';

const _regularCarJson = '''
{
  "GROUP_CODE": 1007101143,
  "GROUP_NAME": "DD904-DD09D SMART",
  "GR_NAME": "HYUNDAI - ACCENT - SEDAN - 1.4L",
  "PRICE": 150000.0,
  "ITEM_NAME": "HYUNDAI - ACCENT - SEDAN - 1.4L",
  "CAR_STATUS": 1,
  "MAKE_YEAR": 2023,
  "MobileShow": true,
  "BODY_COLOR": "ابيض",
  "PaintingsVal": 1000.0,
  "AdminFeesPct": null,
  "FirstInstallmentPct": null,
  "InsurancePct": null,
  "LastInstallmentPct": null,
  "IsActive": null,
  "EndDate": null,
  "InterestRate": null
}
''';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hajed_car_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  test('regular inventory rows are not offers', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_regularCarJson) as Map<String, dynamic>,
    );
    expect(car.hasOfferTerms, isFalse);
    expect(car.isVehicleOffer, isFalse);
  });

  test('offer terms follow the selected salary transfer type', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_offerCarJson) as Map<String, dynamic>,
    );

    expect(car.isVehicleOffer, isTrue);
    expect(car.firstInstallmentForType(SalaryTransferType.transferred), 10);
    expect(car.firstInstallmentForType(SalaryTransferType.nonTransferred), 0);
    expect(car.insuranceForType(SalaryTransferType.transferred), 2);
    expect(car.insuranceForType(SalaryTransferType.nonTransferred), 0);
    expect(car.lastInstallmentForType(SalaryTransferType.nonTransferred), 50);
    expect(car.interestRateForType(SalaryTransferType.nonTransferred), 3);
  });

  test(
    'offer installment includes fee, VAT, profit, insurance and residual',
    () {
      final car = GetBrandCarsDataModel.fromJson(
        jsonDecode(_offerCarJson) as Map<String, dynamic>,
      );

      expect(
        car.monthlyInstallmentForType(SalaryTransferType.transferred),
        closeTo(1862.14, 0.01),
      );
      expect(
        car.monthlyInstallmentForType(SalaryTransferType.nonTransferred),
        closeTo(1906.13, 0.01),
      );
    },
  );

  test('inactive or expired offer rows are not shown as offers', () {
    final base = jsonDecode(_offerCarJson) as Map<String, dynamic>;
    final inactive = GetBrandCarsDataModel.fromJson({
      ...base,
      'IsActive': false,
    });
    expect(inactive.hasOfferTerms, isTrue);
    expect(inactive.isVehicleOffer, isFalse);

    final expired = GetBrandCarsDataModel.fromJson({
      ...base,
      'EndDate': '31/12/2000',
    });
    expect(expired.isVehicleOffer, isFalse);

    // Some deployments return numeric flags.
    final numericActive = GetBrandCarsDataModel.fromJson({
      ...base,
      'IsActive': 1,
    });
    expect(numericActive.isVehicleOffer, isTrue);
    final numericInactive = GetBrandCarsDataModel.fromJson({
      ...base,
      'IsActive': 0,
    });
    expect(numericInactive.isVehicleOffer, isFalse);
  });

  test('the offer built from a car row keeps the row installment', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_offerCarJson) as Map<String, dynamic>,
    );
    final offer = FinancingAdModel.fromCarOffer(car);

    expect(
      offer.monthlyInstallmentForPrice(double.parse(car.effectivePrice!)),
      closeTo(
        car.monthlyInstallmentForType(SalaryTransferType.transferred),
        0.01,
      ),
    );
    expect(offer.interestRate, car.interestRate);
  });

  test('terms present only in the other-bank fields are still used', () {
    final base = jsonDecode(_offerCarJson) as Map<String, dynamic>;
    final car = GetBrandCarsDataModel.fromJson({
      ...base,
      'FirstInstallmentPct': null,
      'FirstInstallmentPctother': 5.0,
      'LastInstallmentPct': null,
      'LastInstallmentPctother': 20.0,
      'AdminFeesPct': null,
      'AdminFeesPctother': 1.0,
      'InsurancePct': null,
      'InsurancePctother': 2.0,
      'InterestRate': null,
      'InterestRate_other': 3.0,
    });

    expect(car.isVehicleOffer, isTrue);
    expect(car.firstInstallmentForType(SalaryTransferType.transferred), 5);
    expect(car.interestRateForType(SalaryTransferType.transferred), 3);

    final offer = FinancingAdModel.fromCarOffer(car);
    expect(offer.firstInstallmentPct, 5);
    expect(offer.lastInstallmentPct, 20);
    expect(offer.adminFeesPct, 1);
    expect(offer.insurancePct, 2);
    expect(offer.interestRate, 3);
  });

  test('a serialized car map keeps its offer terms', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_offerCarJson) as Map<String, dynamic>,
    );
    // Cards that pass `car.toMap()` as route arguments rebuild the car from
    // that map before opening the calculator; the offer terms must survive.
    final restored = GetBrandCarsDataModel.fromJson(car.toMap());

    expect(restored.isVehicleOffer, isTrue);
    expect(restored.interestRate, car.interestRate);
    expect(
      restored.monthlyInstallmentForType(SalaryTransferType.transferred),
      closeTo(
        car.monthlyInstallmentForType(SalaryTransferType.transferred),
        0.01,
      ),
    );
  });

  test('the home carousel card map keeps every offer term', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_offerCarJson) as Map<String, dynamic>,
    );
    // Mirrors `PopularCarsSliderWidget._carToMap`, which rebuilds the offer
    // when the card opens the details page or the comparison screen.
    final cardMap = {
      'name': car.itemName,
      'brand': car.groupName,
      'price': car.price,
      'PRICE': car.price,
      'PaintingsVal': car.paintingsVal,
      'FirstInstallmentPct': car.firstInstallmentPct,
      'FirstInstallmentPctother': car.firstInstallmentPctOther,
      'LastInstallmentPct': car.lastInstallmentPct,
      'LastInstallmentPctother': car.lastInstallmentPctOther,
      'AdminFeesPct': car.adminFeesPct,
      'AdminFeesPctother': car.adminFeesPctOther,
      'InterestRate': car.interestRate,
      'InterestRate_other': car.interestRateOther,
      'InsurancePct': car.insurancePct,
      'InsurancePctother': car.insurancePctOther,
      'InsuranceVal': car.insuranceAmount,
      'BankOrProvider': car.bankCode,
      'BankName': car.bankName,
      'IsActive': car.isActive,
      'EndDate': car.endDate,
    };

    final restored = GetBrandCarsDataModel.fromJson(cardMap);
    expect(restored.isVehicleOffer, isTrue);
    expect(restored.insurancePct, 2);
    expect(restored.interestRate, 3);
    expect(
      FinancingAdModel.vehicleOfferMonthlyInstallment(restored),
      closeTo(1862.14, 0.01),
    );
  });

  test('a program car cannot downgrade an active inventory offer', () {
    final row = GetBrandCarsDataModel.fromJson({
      ...jsonDecode(_offerCarJson) as Map<String, dynamic>,
      'EndDate': '31/12/2099',
    });
    expect(row.isVehicleOffer, isTrue);

    // Mirrors `FinancingAdModel.toCarDataModel()`: a financing-program row may
    // come back inactive/expired with zeroed terms even though the inventory
    // row itself is an active offer.
    final programCar = GetBrandCarsDataModel.fromJson({
      'GROUP_CODE': 0,
      'ITEM_NAME': row.itemName,
      'PRICE': 150000,
      'PaintingsVal': 0,
      'IsActive': false,
      'EndDate': '31/12/2000',
      'InterestRate': 0,
      'FirstInstallmentPct': 0,
      'LastInstallmentPct': 0,
      'InsurancePct': 0,
      'AdminFeesPct': 0,
    });

    // Merging in the old order would let the program row's expired flags and
    // zero terms win, turning the car back into standard financing.
    expect(programCar.merge(row).isVehicleOffer, isFalse);

    final merged = row.isVehicleOffer
        ? row.merge(programCar)
        : programCar.merge(row);
    expect(merged.isVehicleOffer, isTrue);
    expect(merged.interestRate, 3);
    expect(merged.firstInstallmentPct, 10);
    expect(merged.endDate, '31/12/2099');
    expect(
      merged.monthlyInstallmentForType(SalaryTransferType.transferred),
      closeTo(1862.14, 0.01),
    );
  });

  test('a program car still supplies terms for a regular row', () {
    final row = GetBrandCarsDataModel.fromJson(
      jsonDecode(_regularCarJson) as Map<String, dynamic>,
    );
    final programCar = GetBrandCarsDataModel.fromJson({
      'GROUP_CODE': 0,
      'ITEM_NAME': row.itemName,
      'PRICE': 150000,
      'PaintingsVal': 0,
      'IsActive': true,
      'EndDate': '31/12/2099',
      'InterestRate': 4,
      'FirstInstallmentPct': 10,
      'LastInstallmentPct': 50,
      'InsurancePct': 2,
      'AdminFeesPct': 1,
      'BankOrProvider': '2',
    });

    final merged = row.isVehicleOffer
        ? row.merge(programCar)
        : programCar.merge(row);
    expect(merged.isVehicleOffer, isTrue);
    expect(merged.interestRate, 4);
    expect(merged.adminFeesPct, 1);
    expect(merged.itemName, row.itemName);
  });

  test('regular rows never produce a vehicle offer installment', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_regularCarJson) as Map<String, dynamic>,
    );
    expect(FinancingAdModel.vehicleOfferMonthlyInstallment(car), isNull);
  });

  test('budget list uses the offer installment before bank offers', () {
    final car = GetBrandCarsDataModel.fromJson(
      jsonDecode(_offerCarJson) as Map<String, dynamic>,
    );
    final offer = FinancingAdModel.fromCarOffer(car);

    final offerInstallment = FinancingAdModel.vehicleOfferMonthlyInstallment(
      car,
      basePrice: double.parse(car.price!),
      financingFee: FinancingAdModel.defaultFinancingFee,
      platesVal: car.paintingsVal ?? 0,
    );

    expect(offerInstallment, isNotNull);
    expect(
      offerInstallment,
      closeTo(
        offer.monthlyInstallmentForPrice(
          double.parse(car.price!),
          financingFee: FinancingAdModel.defaultFinancingFee,
        ),
        0.01,
      ),
    );
    expect(offerInstallment, closeTo(1862.14, 0.01));
  });

  group('offer bank and non-transferred terms', () {
    setUp(FinancingAdModel.clearBankDirectory);
    tearDown(FinancingAdModel.clearBankDirectory);

    GetBrandCarsDataModel carWithOtherRate() {
      return GetBrandCarsDataModel.fromJson({
        ...jsonDecode(_offerCarJson) as Map<String, dynamic>,
        'BankOrProvider': '2',
        'InterestRate': 3.0,
        'InterestRate_other': 4.5,
        'FirstInstallmentPctother': 5.0,
        'InsurancePctother': 1.0,
        'LastInstallmentPctother': 40.0,
        'AdminFeesPctother': 1.0,
      });
    }

    test('the bank name is resolved from the bank id', () {
      final offer = FinancingAdModel.fromCarOffer(carWithOtherRate());

      // Only `BankOrProvider: "2"` is present, so nothing can be displayed
      // and the non-transferred terms cannot be selected yet.
      expect(offer.offerBankName, isNull);
      expect(offer.usesNonTransferredTerms(userSalaryBank: 'SNB'), isFalse);

      FinancingAdModel.registerBankDirectory([
        const BANKSDATAModel(
          bankCode: 2,
          bankName: 'مصرف الراجحي',
          bankNameEng: 'Al Rajhi Bank',
        ),
      ]);

      expect(offer.offerBankName, 'مصرف الراجحي');
      expect(offer.localizedOfferBankName(english: true), 'Al Rajhi Bank');
      expect(
        offer.resolvedBankNames,
        containsAll(<String>['مصرف الراجحي', 'Al Rajhi Bank']),
      );
    });

    test('non-transferred salaries use InterestRate_other', () {
      final offer = FinancingAdModel.fromCarOffer(carWithOtherRate());
      FinancingAdModel.registerBankDirectory([
        const BANKSDATAModel(
          bankCode: 2,
          bankName: 'مصرف الراجحي',
          bankNameEng: 'Al Rajhi Bank',
        ),
      ]);

      // Salary with the offer bank (transferred) keeps the standard terms.
      expect(
        offer.usesNonTransferredTerms(userSalaryBank: 'Al Rajhi Bank'),
        isFalse,
      );
      expect(
        offer.usesNonTransferredTerms(userSalaryBank: 'مصرف الراجحي'),
        isFalse,
      );
      expect(
        offer.getEffectiveInterestRate(userSalaryBank: 'Al Rajhi Bank'),
        3.0,
      );

      // Salary with another bank (non-transferred) must use the `*Other` set.
      expect(offer.usesNonTransferredTerms(userSalaryBank: 'SNB'), isTrue);
      expect(offer.getEffectiveInterestRate(userSalaryBank: 'SNB'), 4.5);
      expect(offer.firstInstallmentForBank(userSalaryBank: 'SNB'), 5.0);
      expect(offer.lastInstallmentForBank(userSalaryBank: 'SNB'), 40.0);
      expect(offer.insuranceForBank(userSalaryBank: 'SNB'), 1.0);
      expect(offer.adminFeesForBank(userSalaryBank: 'SNB'), 1.0);

      // The installment follows the same rate.
      expect(
        offer.monthlyInstallmentForPrice(150000, userSalaryBank: 'SNB'),
        closeTo(
          FinancingCalculator(
            carPriceWithVat: offer.carPriceWithVat(basePrice: 150000),
            firstInstallmentPct: 5,
            lastInstallmentPct: 40,
            annualInterestPct: 4.5,
            annualInsurancePct: 1,
            adminFeesPct: 1,
          ).monthlyInstallment,
          0.01,
        ),
      );
    });

    test('an explicit bank name wins over the directory', () {
      FinancingAdModel.registerBankDirectory([
        const BANKSDATAModel(
          bankCode: 2,
          bankName: 'مصرف الراجحي',
          bankNameEng: 'Al Rajhi Bank',
        ),
      ]);

      const offer = FinancingAdModel(
        bankName: 'Explicit Bank',
        bankOrProvider: '2',
        interestRate: 3,
        interestRateOther: 5,
      );

      expect(offer.offerBankName, 'Explicit Bank');
      expect(offer.usesNonTransferredTerms(userSalaryBank: 'SNB'), isTrue);
      expect(offer.getEffectiveInterestRate(userSalaryBank: 'SNB'), 5);
    });
  });

  test('calculator matches the shared price and installment formula', () {
    final price = FinancingCalculator.priceWithVat(
      priceExcludingVat: 150000,
      vatPercentage: 15,
    );
    expect(price, 175950);

    final calculator = FinancingCalculator(
      carPriceWithVat: price,
      firstInstallmentPct: 10,
      lastInstallmentPct: 50,
      annualInterestPct: 3,
      annualInsurancePct: 2,
      adminFeesPct: 0,
    );
    expect(calculator.monthlyInstallment, closeTo(1862.14, 0.01));
  });
}
