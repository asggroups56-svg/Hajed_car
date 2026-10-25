import 'dart:convert';
import 'dart:io';

import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('financing_ad_test');
    Hive.init(dir.path);
    await Hive.openBox('app');
  });

  tearDownAll(() async {
    await Hive.close();
  });
  const offerJson = {
    'ProgramID': 3,
    'ProgramName': 'Al Rajhi Bank Campaign',
    'IsActive': true,
    'BankOrProvider': '2',
    'BankName': 'Al Rajhi Bank',
    'StartDate': '2026/10/01',
    'EndDate': '2026/10/31',
    'FirstInstallmentPct': 0.0,
    'LastInstallmentPct': 50.0,
    'AdminFeesPct': 0.0,
    'FirstInstallmentPctother': 10.0,
    'LastInstallmentPctother': 40.0,
    'AdminFeesPctother': 1.5,
    'InsurancePct': 2.0,
    'InsurancePctother': 3.5,
    'InsuranceVal': 1200,
    'InsuranceValother': 1500,
    'InterestRate': 3.0,
    'InterestRate_other': 4.25,
    'PaintingsVal': 600,
    'modelName': 'MERCEDES - A - 1.3CC - H-C200',
    'ModelYear': 2023,
    'ITEM_CODE': '773',
    'ITEM_NAME': 'MERCEDES - A',
  };

  test('parses bank, other-bank, insurance and plates fields', () {
    final offer = FinancingAdModel.fromJson(offerJson);

    expect(offer.programId, 3);
    expect(offer.offerBankName, 'Al Rajhi Bank');
    expect(offer.bankIdentifier, '2');
    expect(offer.firstInstallmentPctOther, 10);
    expect(offer.lastInstallmentPctOther, 40);
    expect(offer.adminFeesPctOther, 1.5);
    expect(offer.insurancePct, 2);
    expect(offer.insurancePctOther, 3.5);
    expect(offer.insuranceAmount, 1200);
    expect(offer.insuranceAmountOther, 1500);
    expect(offer.interestRateOther, 4.25);
    expect(offer.platesCostWithVat, 600);
  });

  test(
    'uses salary-transfer (normal) terms when the salary bank is the offer bank (محول)',
    () {
      final offer = FinancingAdModel.fromJson(offerJson);

      expect(
        offer.usesNonTransferredTerms(userSalaryBank: 'Al Rajhi Bank'),
        isFalse,
      );
      expect(
        offer.isOtherBank(userSalaryBank: 'Al Rajhi Bank'),
        isFalse,
      );
      expect(
        offer.isTransferredBank(userSalaryBank: 'Al Rajhi Bank'),
        isTrue,
      );
      expect(
        offer.firstInstallmentForBank(userSalaryBank: 'Al Rajhi Bank'),
        0,
      );
      expect(offer.lastInstallmentForBank(userSalaryBank: 'Al Rajhi Bank'), 50);
      expect(offer.adminFeesForBank(userSalaryBank: 'Al Rajhi Bank'), 0);
      expect(offer.insuranceForBank(userSalaryBank: 'Al Rajhi Bank'), 2);
      expect(
        offer.insuranceValueForBank(userSalaryBank: 'Al Rajhi Bank'),
        1200,
      );
      expect(
        offer.getEffectiveInterestRate(userSalaryBank: 'Al Rajhi Bank'),
        3,
      );
    },
  );

  test('uses non-transfer (Other) terms when the salary bank differs (غير محول)', () {
    final offer = FinancingAdModel.fromJson(offerJson);

    expect(offer.usesNonTransferredTerms(userSalaryBank: 'SNB'), isTrue);
    expect(offer.isOtherBank(userSalaryBank: 'SNB'), isTrue);
    expect(offer.isTransferredBank(userSalaryBank: 'SNB'), isFalse);
    expect(offer.firstInstallmentForBank(userSalaryBank: 'SNB'), 10);
    expect(offer.lastInstallmentForBank(userSalaryBank: 'SNB'), 40);
    expect(offer.adminFeesForBank(userSalaryBank: 'SNB'), 1.5);
    expect(offer.insuranceForBank(userSalaryBank: 'SNB'), 3.5);
    expect(offer.insuranceValueForBank(userSalaryBank: 'SNB'), 1500);
    expect(offer.getEffectiveInterestRate(userSalaryBank: 'SNB'), 4.25);
  });

  test('applies admin fees and both salary-bank term sets to the monthly', () {
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)
        ..['Price'] = 100000.0
        ..['TotalMonths'] = 60,
    );

    // Total price: (100,000 + 3,000) × 1.15 + 600 plates = 119,050.
    // Salary bank is the offer bank (محول / normal terms):
    // down 0; last 50% = 59,525; profit 17,857.50;
    // insurance 11,905; admin 0.
    expect(
      offer.monthlyInstallmentForPrice(100000, userSalaryBank: 'Al Rajhi Bank'),
      closeTo(1488.125, 0.001),
    );

    // Salary bank differs from the offer bank (غير محول / non-transfer/other terms):
    // down 10% = 11,905; last 40% = 47,620; profit 22,768.3125;
    // insurance 20,833.75; admin 1,607.175.
    // (107,145 + 22,768.3125 + 20,833.75 + 1,607.175 - 47,620) / 60.
    expect(
      offer.monthlyInstallmentForPrice(100000, userSalaryBank: 'SNB'),
      closeTo(1745.570625, 0.001),
    );
  });

  test('matches the offer bank in Arabic or English', () {
    final localizedJson = Map<String, dynamic>.of(offerJson)
      ..['BankName'] = 'مصرف الراجحي'
      ..['BankNameEng'] = 'Al Rajhi Bank';
    final offer = FinancingAdModel.fromJson(localizedJson);

    expect(offer.isOfferBank('Al Rajhi Bank'), isTrue);
    expect(offer.isOfferBank('مصرف الراجحي'), isTrue);
    expect(
      offer.usesNonTransferredTerms(userSalaryBank: 'Al Rajhi Bank'),
      isFalse,
    );
    expect(
      offer.usesNonTransferredTerms(userSalaryBank: 'مصرف الراجحي'),
      isFalse,
    );
    expect(offer.usesNonTransferredTerms(userSalaryBank: 'SNB'), isTrue);
  });

  test('taxes the fee and includes plates in the financed car price', () {
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)
        ..['FirstInstallmentPct'] = 10.0
        ..['LastInstallmentPct'] = 0.0
        ..['InterestRate'] = 0.0
        ..['InsurancePct'] = 0.0
        ..['PaintingsVal'] = 1000.0
        ..['TotalMonths'] = 60,
    );

    // (100,000 + 3,000) × 1.15 + 1,000 plates = 119,450.
    // 10% down = 11,945 => (119,450 - 11,945) / 60 = 1,791.75.
    final monthly = offer.monthlyInstallmentForPrice(100000);
    expect(monthly, closeTo(1791.75, 0.001));
  });

  test('carPriceWithVat taxes the fee and adds plates after VAT', () {
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)..['PaintingsVal'] = 1000.0,
    );

    expect(offer.carPriceWithVat(basePrice: 100000), closeTo(119450, 0.001));
    expect(
      offer.carPriceWithVat(basePrice: 100000, financingFee: 0),
      closeTo(116000, 0.001),
    );
    // A car-supplied plate value overrides the offer value.
    expect(
      offer.carPriceWithVat(basePrice: 100000, platesVal: 2000),
      closeTo(120450, 0.001),
    );
  });

  test('standard car data includes plates in the percentage payments', () {
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)
        ..['Price'] = 100000
        ..['FirstInstallmentPct'] = 10.0
        ..['LastInstallmentPct'] = 0.0
        ..['InterestRate'] = 0.0
        ..['InsurancePct'] = 0.0
        ..['PaintingsVal'] = 1000.0
        ..['TotalMonths'] = 60,
    );

    // (100,000 + 3,000) × 1.15 + 1,000 = 119,450; 10% down = 11,945.
    expect(offer.toCarDataModel().monthlyInstallment, closeTo(1791.75, 0.001));
  });

  test('matches the bank table: 176,950 car price gives 2,542.18/month', () {
    const basePrice = 150000.0;
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)
        ..['Price'] = basePrice
        ..['PaintingsVal'] = 1000.0
        ..['FirstInstallmentPct'] = 20.0
        ..['LastInstallmentPct'] = 10.0
        ..['InterestRate'] = 2.8
        ..['InsurancePct'] = 1.0
        ..['TotalMonths'] = 60,
    );

    // Bank table: price incl. VAT 176,950; first 20% = 35,390; last 10% =
    // 17,695; profit 19,818; insurance 8,848.
    // (141,560 + 19,818.40 + 8,847.50 - 17,695) / 60 = 2,542.18.
    expect(offer.carPriceWithVat(basePrice: basePrice), closeTo(176950, 0.01));
    expect(offer.monthlyInstallmentForPrice(basePrice), closeTo(2542.18, 0.05));
  });

  test('selects transfer and non-transfer terms for the same 176,950 car', () {
    const basePrice = 150000.0;
    final offer = FinancingAdModel.fromJson(
      Map<String, dynamic>.of(offerJson)
        ..['Price'] = basePrice
        ..['PaintingsVal'] = 1000.0
        ..['FirstInstallmentPct'] = 20.0
        ..['LastInstallmentPct'] = 10.0
        ..['InterestRate'] = 2.8
        ..['InsurancePct'] = 1.0
        ..['TotalMonths'] = 60,
    );

    // Salary bank is the offer bank (محول): normal terms.
    expect(
      offer.monthlyInstallmentForPrice(basePrice, userSalaryBank: 'Al Rajhi Bank'),
      closeTo(2542.18, 0.05),
    );

    // Salary bank is a different bank (غير محول): non-transfer terms from the `*Other`
    // fields (10% first, 40% last, 4.25% profit, 3.5% insurance, 1.5% admin).
    // (176,950 − 17,695 + 33,841.6875 + 30,966.25 + 2,388.825 − 70,780) / 60.
    expect(
      offer.monthlyInstallmentForPrice(
        basePrice,
        userSalaryBank: 'SNB',
      ),
      closeTo(2594.529375, 0.001),
    );
  });

  test('listFromResponse accepts a JSON string', () {
    final offers = FinancingAdModel.listFromResponse(jsonEncode([offerJson]));

    expect(offers, hasLength(1));
    expect(offers.first.offerBankName, 'Al Rajhi Bank');
  });

  test('toMap carries the standard financing offer data', () {
    final map = FinancingAdModel.fromJson(offerJson).toMap();

    expect(map['bankName'], 'Al Rajhi Bank');
    expect(map['insurancePct'], 2);
    expect(map['insurancePctOther'], 3.5);
    expect(map['platesCostWithVat'], 600);
  });
}
