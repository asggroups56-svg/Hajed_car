import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class BankOffer {
  final String nameKey;
  final String logoText; // Placeholder for logo representation
  final double apr;
  final Color brandColor;
  final double firstInstallmentPct;
  final double lastInstallmentPct;
  final double adminFeesPct;
  final String? imageUrl;

  BankOffer({
    required this.nameKey,
    required this.logoText,
    required this.apr,
    required this.brandColor,
    this.firstInstallmentPct = 0,
    this.lastInstallmentPct = 0,
    this.adminFeesPct = 0,
    this.insurancePct = 0,
    this.imageUrl,
  });

  final double insurancePct;

  // Calculate monthly installment and total amount based on user inputs
  Map<String, double> calculate(num carPrice, num downPayment, int durationYears) {
    final downPaymentAmount = downPayment > 0 ? downPayment.toDouble() : carPrice.toDouble() * (firstInstallmentPct / 100);
    final finalPaymentAmount = carPrice.toDouble() * (lastInstallmentPct / 100);
    final netFinanceAmount = carPrice.toDouble() - downPaymentAmount;
    if (netFinanceAmount <= 0) {
      return {'totalAmount': 0, 'monthlyInstallment': 0};
    }
    final totalInterest = netFinanceAmount * (apr / 100) * durationYears;
    final totalInsurance = netFinanceAmount * (insurancePct / 100) * durationYears;
    final totalFinancedWithInterest = netFinanceAmount + totalInterest + totalInsurance;
    final totalMonths = durationYears * 12;
    final monthlyInstallment = (totalFinancedWithInterest - finalPaymentAmount) / totalMonths;

    return {
      'totalAmount': totalFinancedWithInterest,
      'monthlyInstallment': monthlyInstallment,
      'lastPaymentAmount': finalPaymentAmount,
    };
  }
}

class BankOfferCardWidget extends StatelessWidget {
  final BankOffer offer;
  final num carPrice;
  final num downPayment;
  final int durationYears;
  final VoidCallback? onTap;

  const BankOfferCardWidget({
    super.key,
    required this.offer,
    required this.carPrice,
    required this.downPayment,
    required this.durationYears,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final calculations = offer.calculate(carPrice, downPayment, durationYears);
    final totalAmount = calculations['totalAmount'] ?? 0.0;
    final monthlyInstallment = calculations['monthlyInstallment'] ?? 0.0;

    // Number format for currency
    final formatter = NumberFormat('#,##0', 'en_US');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColor.secondAppColor(context),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor(context).withValues(alpha: (0.05)),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: (0.1))),
        ),
        child: Column(
          children: [
            // Header: Bank Logo/Name and Profit Margin
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: offer.brandColor.withValues(alpha: (0.1)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        offer.imageUrl?.isNotEmpty == true
                            ? CircleAvatar(
                                radius: 20.r,
                                backgroundImage: NetworkImage(offer.imageUrl!),
                              )
                            : CircleAvatar(
                                backgroundColor: offer.brandColor,
                                radius: 20.r,
                                child: Text(
                                  offer.logoText,
                                  style: AppTextStyle.bodyMedium(context).copyWith(
                                    color: AppColor.whiteColor(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            offer.nameKey.tr(),
                            style: AppTextStyle.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColor.blackTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body: Calculations
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKey.monthlyInstallment.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600]),
                        ),
                        Gap(4.h),
                        Text(
                          '${formatter.format(monthlyInstallment)} SAR',
                          style: AppTextStyle.bodyLarge(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.w, height: 40.h, color: Colors.grey.withValues(alpha: 0.2)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKey.totalAmount.tr(),
                            style: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(color: Colors.grey[600]),
                          ),
                          Gap(4.h),
                          Text(
                            '${formatter.format(totalAmount)} SAR',
                            style: AppTextStyle.bodyLarge(context).copyWith(
                              color: AppColor.blackTextColor(context),

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
