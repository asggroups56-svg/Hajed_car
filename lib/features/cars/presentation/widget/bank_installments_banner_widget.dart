import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/services/presentation/screen/financing_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class BankInstallmentsBannerWidget extends StatefulWidget {
  final GetBrandCarsDataModel car;
  final bool isOffer;
  final FinancingAdModel? offer;
  final List<FinancingAdModel> offers;

  /// Uses the small, side-by-side price treatment used on vehicle cards.
  final bool compact;

  const BankInstallmentsBannerWidget({
    super.key,
    required this.car,
    this.isOffer = false,
    this.offer,
    this.offers = const [],
    this.compact = false,
  });

  @override
  State<BankInstallmentsBannerWidget> createState() =>
      _BankInstallmentsBannerWidgetState();
}

class _BankInstallmentsBannerWidgetState
    extends State<BankInstallmentsBannerWidget> {
  /// Fixed fee that is part of the taxable car price.
  static const double _financingFee = FinancingAdModel.defaultFinancingFee;

  /// Matches the pre-VAT amount used by [FinancingScreen]. An explicit offer
  /// carries its own price; otherwise the car's effective price is used.
  double get _financingBasePrice {
    final offerPrice = (_vehicleOffer ?? widget.offer)?.price ?? 0;
    if (offerPrice > 0) return offerPrice;

    final priceString =
        (widget.car.effectivePrice ?? widget.car.price)?.replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        ) ??
        '';
    return double.tryParse(priceString) ?? 0;
  }

  /// Plate/registration fee (already VAT-inclusive). The explicit offer wins
  /// over the car so the installment matches the offer's own terms.
  double get _plates {
    final offerPlates = (_vehicleOffer ?? widget.offer)?.platesCostWithVat ?? 0;
    return offerPlates > 0 ? offerPlates : widget.car.platesCostWithVat;
  }

  /// The offer attached to the car row, when the row itself is an offer.
  FinancingAdModel? get _vehicleOffer => widget.car.isVehicleOffer
      ? FinancingAdModel.fromCarOffer(widget.car)
      : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.offers.isEmpty &&
          widget.offer == null &&
          !widget.car.isVehicleOffer) {
        try {
          final homeCubit = context.read<HomeCubit>();
          if (homeCubit.state.normalFinancingStatus.data == null ||
              homeCubit.state.normalFinancingStatus.data!.isEmpty) {
            homeCubit.getNormalFinancing();
          }
        } catch (_) {}
      }
    });
  }

  FinancingAdModel? _getLowestOffer(List<FinancingAdModel> cubitOffers) {
    final vehicleOffer = _vehicleOffer;
    // A vehicle row that carries its own terms is the only valid source; the
    // standard bank offers must never replace it.
    final List<FinancingAdModel> candidates = vehicleOffer != null
        ? <FinancingAdModel>[vehicleOffer]
        : (widget.offers.isNotEmpty
              ? widget.offers
              : (widget.offer != null ? <FinancingAdModel>[widget.offer!] : cubitOffers));

    if (candidates.isEmpty) return null;

    final price = _financingBasePrice;
    if (price > 0) {
      return candidates.reduce(
        (a, b) =>
            a.monthlyInstallmentForPrice(
                  price,
                  platesVal: _plates,
                ) <=
                b.monthlyInstallmentForPrice(
                  price,
                  platesVal: _plates,
                )
            ? a
            : b,
      );
    }

    return candidates.reduce(
      (a, b) =>
          (a.interestRate ?? double.infinity) <=
              (b.interestRate ?? double.infinity)
          ? a
          : b,
    );
  }

  /// Returns null when no financing data exists from API — caller should hide the widget.
  String? _getInstallmentPrice(List<FinancingAdModel> cubitOffers) {
    final price = _financingBasePrice;

    // No valid price → hide financing entirely
    if (price <= 0) return null;

    // 1. Direct explicit offer passed to the car
    if (widget.offers.isNotEmpty || widget.offer != null || _vehicleOffer != null) {
      final lowestOffer = _getLowestOffer(cubitOffers);
      if (lowestOffer != null) {
        return NumberFormat('#,##0', 'en_US').format(
          lowestOffer.monthlyInstallmentForPrice(
            price,
            platesVal: _plates,
          ),
        );
      }
    }

    // 2. Explicit monthly installment from API
    if (widget.car.monthlyInstallment != null &&
        widget.car.monthlyInstallment! > 0) {
      return NumberFormat(
        '#,##0',
        'en_US',
      ).format(widget.car.monthlyInstallment);
    }

    // 3. Explicit interest rate from API
    if (widget.car.interestRate != null && widget.car.interestRate! > 0) {
      final vatPercentage =
          double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
      final carPrice =
          (price + _financingFee) * (1 + vatPercentage / 100) +
          widget.car.platesCostWithVat;
      const years = 5;
      const months = 60;
      final totalInterest = carPrice * (widget.car.interestRate! / 100) * years;
      final insurancePct = widget.car.insurancePct ?? 0;
      final totalInsurance = carPrice * (insurancePct / 100) * years;
      final monthly = (carPrice + totalInterest + totalInsurance) / months;
      return NumberFormat('#,##0', 'en_US').format(monthly);
    }

    // 4. Pre-set installments string from API
    if (widget.car.installments != null &&
        widget.car.installments!.trim().isNotEmpty &&
        widget.car.installments!.trim() != '0' &&
        widget.car.installments!.trim().toLowerCase() != 'null') {
      return widget.car.installments!.trim();
    }

    // 5. Fallback to normal bank financing offers from cubit
    if (cubitOffers.isNotEmpty) {
      final lowestOffer = _getLowestOffer(cubitOffers);
      if (lowestOffer != null) {
        return NumberFormat('#,##0', 'en_US').format(
          lowestOffer.monthlyInstallmentForPrice(
            price,
            platesVal: _plates,
          ),
        );
      }
    }

    // 6. Generic calculation fallback if price is present
    final vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice =
        (price + _financingFee) * (1 + vatPercentage / 100) +
        widget.car.platesCostWithVat;
    final estimatedMonthly = (carPrice * 1.225) / 60;
    if (estimatedMonthly > 0) {
      return NumberFormat('#,##0', 'en_US').format(estimatedMonthly);
    }

    // No financing data from API -> Hide
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubitOffers =
            state.normalFinancingStatus.data ?? const <FinancingAdModel>[];
        final installmentPrice = _getInstallmentPrice(cubitOffers);

        // Hide financing widget entirely when price is zero or unavailable
        if (installmentPrice == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            if (HiveMethods.isGuest()) return;

            FinancingAdModel? selectedOffer = _getLowestOffer(cubitOffers);
            final vehicleOffer = _vehicleOffer;
            List<FinancingAdModel> selectedOffers = vehicleOffer != null
                ? [vehicleOffer]
                : (widget.offers.isNotEmpty
                      ? widget.offers
                      : (widget.offer != null ? [widget.offer!] : cubitOffers));
            if (selectedOffers.isEmpty) {
              final homeCubit = context.read<HomeCubit>();
              await homeCubit.getNormalFinancing();
              if (!context.mounted) return;
              selectedOffers =
                  homeCubit.state.normalFinancingStatus.data ?? const [];
              selectedOffer = _getLowestOffer(selectedOffers);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FinancingScreen(
                  car: widget.car,
                  offer: selectedOffer,
                  offers: selectedOffers,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.locale.languageCode == 'ar'
                    ? 'القسط الشهري'
                    : 'Monthly installment',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.blueColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      installmentPrice,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.blueColor(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Gap(4.w),
                  Flexible(
                    child: ValueWithCurrencyIcon(
                      text:
                          '${AppLocaleKey.aed.tr()} / ${AppLocaleKey.agentAppointment.tr() == context.locale.languageCode || context.locale.languageCode == "en" ? "Month" : "شهرياً"}',
                      textStyle: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blueColor(context),
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),

              // if (!widget.compact && plates > 0) ...[
              //   Gap(6.h),
              //   _OfferInfoText(
              //     label: AppLocaleKey.adPlatesFee.tr(),
              //     value: NumberFormat('#,##0', 'en_US').format(plates),
              //   ),
              // ],
              if (!widget.compact) ...[
                Gap(20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.blueColor(context).withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocaleKey.agentCalculateFinancing.tr(),
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppColor.blueColor(context),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Kept for the optional plates line, currently commented out in the banner.
// ignore: unused_element
class _OfferInfoText extends StatelessWidget {
  const _OfferInfoText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyle.bodySmall(
          context,
        ).copyWith(color: AppColor.blueColor(context), fontSize: 10.sp),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
