import 'package:flutter/material.dart';

class BankCampaign {
  final String brand;
  final String? model;
  final int? year;
  final double rate;
  final double defaultDownPayment;
  final double defaultLastPayment;

  BankCampaign({
    required this.brand,
    this.model,
    this.year,
    required this.rate,
    this.defaultDownPayment = 0,
    this.defaultLastPayment = 50,
  });

  bool matches(String brand, String model, int year) {
    if (this.brand.toLowerCase() != brand.toLowerCase()) return false;
    if (this.model != null && !model.toLowerCase().contains(this.model!.toLowerCase())) {
      return false;
    }
    if (this.year != null && this.year != year) return false;
    return true;
  }
}

class BankOffer {
  final String nameKey;
  final String logoText;
  final double baseApr;
  final Color brandColor;
  final List<String>? supportedBrands;
  final List<BankCampaign>? campaigns;

  BankOffer({
    required this.nameKey,
    required this.logoText,
    required this.baseApr,
    required this.brandColor,
    this.supportedBrands,
    this.campaigns,
  });

  bool isBrandSupported(String brand) {
    if (supportedBrands == null) return true;
    return supportedBrands!.any((b) => brand.toLowerCase().contains(b.toLowerCase()));
  }

  double getAdjustedApr(int year, String brand, String model) {
    if (campaigns != null) {
      for (var c in campaigns!) {
        if (c.matches(brand, model, year)) return c.rate;
      }
    }
    double adj = 0.0;
    if (year < 2022) {
      adj += 1.5;
    } else if (year < 2024) {
      adj += 0.5;
    }
    if (brand.toLowerCase().contains('mercedes') || brand.toLowerCase().contains('bmw')) {
      adj -= 0.2;
    }
    return baseApr + adj;
  }

  Map<String, double> calculate({
    required num carPrice,
    required num downPaymentAmount,
    required num lastPaymentAmount,
    required int durationYears,
    required int year,
    required String brand,
    required String model,
    num insurancePct = 0,
  }) {
    final apr = getAdjustedApr(year, brand, model);
    final principal = carPrice.toDouble();
    final down = downPaymentAmount.toDouble();
    final residual = lastPaymentAmount.toDouble();
    final netFinance = principal - down;
    if (netFinance <= 0) {
      return {'totalAmount': 0, 'monthlyInstallment': 0, 'apr': apr, 'lastPaymentAmount': 0};
    }
    final totalInterest = netFinance * (apr / 100) * durationYears;
    final totalInsurance = netFinance * (insurancePct / 100) * durationYears;
    final totalFinancedWithInterest = netFinance + totalInterest + totalInsurance;
    final totalMonths = durationYears * 12;
    final monthly = (totalFinancedWithInterest - residual) / totalMonths;
    return {
      'totalAmount': totalFinancedWithInterest,
      'monthlyInstallment': monthly,
      'apr': apr,
      'lastPaymentAmount': residual,
    };
  }
}
