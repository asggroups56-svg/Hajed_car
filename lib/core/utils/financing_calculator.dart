/// Pure financing math shared by every offer/installment calculation.
///
/// The inputs mirror the terms returned by the financing and vehicle-offer
/// endpoints, so the same numbers are produced on cards, on car details and
/// in the financing calculator sheet.
class FinancingCalculator {
  /// Fixed financing fee. It is part of the taxable amount, so VAT applies to
  /// the car price plus this fee.
  static const double defaultFinancingFee = 3000;

  /// VAT-inclusive car price including the financing fee and the
  /// plate/registration fee.
  final double carPriceWithVat;

  /// First payment (down payment) as a percentage of [carPriceWithVat].
  final double firstInstallmentPct;

  /// Last payment (residual) as a percentage of [carPriceWithVat].
  final double lastInstallmentPct;

  /// Flat annual profit/interest rate.
  final double annualInterestPct;

  /// Annual insurance rate charged on [carPriceWithVat].
  final double annualInsurancePct;

  /// Administrative fee charged on the financed amount.
  final double adminFeesPct;

  /// Financing duration in months.
  final int months;

  const FinancingCalculator({
    required this.carPriceWithVat,
    this.firstInstallmentPct = 0,
    this.lastInstallmentPct = 0,
    this.annualInterestPct = 0,
    this.annualInsurancePct = 0,
    this.adminFeesPct = 0,
    this.months = 60,
  });

  /// `(price excl. VAT + fee) × (1 + VAT%) + plates`
  ///
  /// The plate/registration fee already includes VAT, so it is added after
  /// applying VAT.
  static double priceWithVat({
    required double priceExcludingVat,
    required double vatPercentage,
    double financingFee = defaultFinancingFee,
    double plates = 0,
  }) {
    return (priceExcludingVat + financingFee) * (1 + vatPercentage / 100) +
        plates;
  }

  double get _years => months / 12;

  double get downPaymentAmount => carPriceWithVat * firstInstallmentPct / 100;

  double get finalPaymentAmount =>
      carPriceWithVat * lastInstallmentPct / 100;

  double get financedAmount {
    final financed = carPriceWithVat - downPaymentAmount;
    return financed > 0 ? financed : 0;
  }

  double get totalInterest => financedAmount * (annualInterestPct / 100) * _years;

  /// Insurance is charged on the full car price, not on the financed amount.
  double get totalInsurance =>
      carPriceWithVat * (annualInsurancePct / 100) * _years;

  double get totalAdminFees => financedAmount * (adminFeesPct / 100);

  double get totalFinancedWithInterest =>
      financedAmount + totalInterest + totalInsurance + totalAdminFees;

  double get totalPrice =>
      carPriceWithVat + totalInterest + totalInsurance + totalAdminFees;

  double get monthlyInstallment {
    if (months <= 0) return 0;
    final remaining = totalFinancedWithInterest - finalPaymentAmount;
    return remaining > 0 ? remaining / months : 0;
  }
}
