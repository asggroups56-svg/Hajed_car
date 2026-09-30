import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/services/presentation/widgets/custom_monthly_installment_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FinancingCalculatorBottomSheet extends StatefulWidget {
  final double carPrice;
  final double initialDownPayment;
  final double initialLastPayment;
  final int initialDuration;
  final double? interestRate;
  final bool isOffer;
  final String? bankName;
  final double? firstInstallmentPct;
  final double? lastInstallmentPct;
  final double? adminFeesPct;
  final List<FinancingAdModel> offers;
  final FinancingAdModel? initialOffer;

  const FinancingCalculatorBottomSheet({
    super.key,
    required this.carPrice,
    this.initialDownPayment = 0,
    this.initialLastPayment = 0,
    this.initialDuration = 5,
    this.interestRate,
    this.isOffer = false,
    this.bankName,
    this.firstInstallmentPct,
    this.lastInstallmentPct,
    this.adminFeesPct,
    this.offers = const [],
    this.initialOffer,
  });

  @override
  State<FinancingCalculatorBottomSheet> createState() => _FinancingCalculatorBottomSheetState();
}

class _FinancingCalculatorBottomSheetState extends State<FinancingCalculatorBottomSheet> {
  late int _durationYears;
  late double _downPayment;
  late double _lastPayment;
  late TextEditingController _downPaymentCtrl;
  late TextEditingController _lastPaymentCtrl;
  FinancingAdModel? _selectedOffer;

  List<FinancingAdModel> get _availableOffers {
    if (widget.offers.isNotEmpty) return widget.offers;
    try {
      final cubitOffers = context.read<HomeCubit>().state.normalFinancingStatus.data;
      if (cubitOffers != null && cubitOffers.isNotEmpty) return cubitOffers;
    } catch (_) {}
    return const [];
  }

  static const double _defaultApr = 4.5;
  FinancingAdModel? get _activeOffer => _selectedOffer ?? widget.initialOffer;
  double get _apr => _activeOffer?.interestRate ?? widget.interestRate ?? _defaultApr;

  @override
  void initState() {
    super.initState();
    _selectedOffer = widget.initialOffer;
    _durationYears = widget.initialDuration;
    _downPayment = widget.initialDownPayment;
    _lastPayment = widget.initialLastPayment;
    _downPaymentCtrl = TextEditingController(text: _downPayment.toStringAsFixed(1));
    _lastPaymentCtrl = TextEditingController(text: _lastPayment.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _downPaymentCtrl.dispose();
    _lastPaymentCtrl.dispose();
    super.dispose();
  }

  double get _insurancePercent => double.tryParse(_activeOffer?.InsurancePct ?? '0') ?? 0;

  double get _financedAmount {
    final financed = widget.carPrice - _downPayment;
    return financed > 0 ? financed : 0;
  }

  double get _totalInterest {
    return _financedAmount * (_apr / 100) * _durationYears;
  }

  double get _totalInsurance {
    return widget.carPrice * (_insurancePercent / 100) * _durationYears;
  }

  double get _totalFinancedWithInterest {
    return _financedAmount + _totalInterest + _totalInsurance;
  }

  double get _totalPrice => widget.carPrice + _totalInterest + _totalInsurance + _adminFees;

  double get _adminFees => widget.isOffer
      ? widget.carPrice * ((_activeOffer?.adminFeesPct ?? widget.adminFeesPct ?? 0) / 100)
      : 0;

  void _selectOffer(FinancingAdModel offer) {
    setState(() {
      _selectedOffer = offer;
      _downPayment = widget.carPrice * (offer.firstInstallmentPct ?? 0) / 100;
      _lastPayment = widget.carPrice * (offer.lastInstallmentPct ?? 0) / 100;
      _downPaymentCtrl.text = _downPayment.toStringAsFixed(1);
      _lastPaymentCtrl.text = _lastPayment.toStringAsFixed(1);
    });
  }

  double get _monthlyInstallment {
    if (_totalFinancedWithInterest <= 0 || _durationYears <= 0) return 0;
    return (_totalFinancedWithInterest - _lastPayment) / (_durationYears * 12);
  }

  double get _maxDownPayment => widget.isOffer
      ? widget.carPrice *
            ((_activeOffer?.firstInstallmentPct ?? widget.firstInstallmentPct ?? 0) / 100)
      : widget.carPrice * 0.35;
  double get _maxLastPayment => widget.isOffer
      ? widget.carPrice *
            ((_activeOffer?.lastInstallmentPct ?? widget.lastInstallmentPct ?? 0) / 100)
      : widget.carPrice * 0.45;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    final monthly = _monthlyInstallment;
    final offersList = _availableOffers;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColor.greyColor(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Title row
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColor.borderColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.sp, color: AppColor.blackTextColor(context)),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      AppLocaleKey.calculatesFinancing.tr(),
                      style: AppTextStyle.titleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w900, fontSize: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomMonthlyInstallmentCardWidget(
                    fmt: fmt,
                    monthly: monthly,
                    totalPrice: _totalPrice,
                  ),
                  Gap(24.h),
                  if (offersList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppLocaleKey.bank.tr(),
                            style: AppTextStyle.bodyMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Gap(10.h),
                        SizedBox(
                          height: 54.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: offersList.length,
                            separatorBuilder: (context, index) => Gap(10.w),
                            itemBuilder: (context, index) {
                              final offer = offersList[index];
                              final isSelected =
                                  identical(_activeOffer, offer) || _selectedOffer == offer;
                              final bankTitle = offer.bankName ?? 'البنك';

                              return GestureDetector(
                                onTap: () => _selectOffer(offer),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColor.primaryColor(context).withValues(alpha: 0.12)
                                        : AppColor.cardColor(context),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColor.primaryColor(context)
                                          : AppColor.borderColor(context).withValues(alpha: 0.6),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColor.primaryColor(
                                                context,
                                              ).withValues(alpha: 0.15),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        Container(
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryColor(context),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: AppColor.whiteColor(context),
                                            size: 12.sp,
                                          ),
                                        ),
                                        Gap(8.w),
                                      ],
                                      Text(
                                        bankTitle,
                                        style: AppTextStyle.bodyMedium(context).copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w900
                                              : FontWeight.w700,
                                          color: isSelected
                                              ? AppColor.primaryColor(context)
                                              : AppColor.blackTextColor(context),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      if (offer.displayBankImageUrl?.isNotEmpty == true) ...[
                                        Gap(10.w),
                                        Container(
                                          width: 30.w,
                                          height: 30.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.whiteColor(context),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColor.primaryColor(
                                                      context,
                                                    ).withValues(alpha: 0.4)
                                                  : Colors.grey.shade200,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(2.w),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15.r),
                                            child: Image.network(
                                              offer.displayBankImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(
                                                Icons.account_balance_rounded,
                                                size: 14.sp,
                                                color: AppColor.primaryColor(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Gap(16.h),
                      ],
                    )
                  else if (widget.bankName?.isNotEmpty == true) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${AppLocaleKey.bank.tr()}: ${widget.bankName}',
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.primaryColor(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Gap(12.h),
                  ],

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      AppLocaleKey.agentYears.tr(),
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                  ),
                  Gap(12.h),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [5, 4, 3, 2, 1].map((year) {
                      final isSelected = _durationYears == year;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _durationYears = year),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(left: year != 1 ? 8.w : 0),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primaryColor(context)
                                  : AppColor.cardColor(context),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.primaryColor(context)
                                    : AppColor.borderColor(context),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$year',
                                  style: AppTextStyle.bodyLarge(context).copyWith(
                                    color: isSelected
                                        ? AppColor.whiteColor(context)
                                        : AppColor.blackTextColor(context),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  year == 1
                                      ? 'سنة'
                                      : year == 2
                                      ? 'سنتين'
                                      : 'سنوات',
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: isSelected
                                        ? AppColor.whiteColor(context)
                                        : AppColor.greyColor(context),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Gap(24.h),
                  Column(
                    children: [
                      CustomFormField(
                        title: AppLocaleKey.agentFirstPayment.tr(),
                        controller: _downPaymentCtrl,
                        readOnly: widget.isOffer,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                        hintText: '0.0',
                        onChanged: (v) {
                          setState(() {
                            _downPayment = double.tryParse(v) ?? 0;
                          });
                        },
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ValueWithCurrencyIcon(
                            text: AppLocaleKey.sar.tr(),
                            textStyle: AppTextStyle.bodyLarge(context).copyWith(
                              color: AppColor.greyColor(context),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(6.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueWithCurrencyIcon(
                      text:
                          '${AppLocaleKey.agentFirstPayment.tr()}:${fmt.format(_maxDownPayment.round())} ${AppLocaleKey.sar.tr()}',
                      textStyle: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                    ),
                  ),
                  Gap(20.h),
                  CustomFormField(
                    title: AppLocaleKey.agentLastPayment.tr(),
                    controller: _lastPaymentCtrl,
                    readOnly: widget.isOffer,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                    hintText: '0.0',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ValueWithCurrencyIcon(
                        text: AppLocaleKey.sar.tr(),
                        textStyle: AppTextStyle.bodyLarge(context).copyWith(
                          color: AppColor.greyColor(context),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _lastPayment = double.tryParse(v) ?? 0;
                      });
                    },
                  ),
                  Gap(6.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueWithCurrencyIcon(
                      text:
                          '${AppLocaleKey.agentLastPaymentDesc.tr()} : ${fmt.format(_maxLastPayment.round())} ${AppLocaleKey.sar.tr()}',
                      textStyle: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                    ),
                  ),
                  Gap(24.h),
                  // Fund now button
                  CustomButton(
                    radius: 12.r,
                    color: AppColor.greenColor(context),
                    onPressed: () {
                      if (HiveMethods.getToken() == null) {
                        CommonMethods.showLoginRequiredDialog(context);
                      } else {
                        Navigator.pop(context, {
                          'duration': _durationYears,
                          'down': _downPayment,
                          'last': _lastPayment,
                          'offer': _activeOffer,
                        });
                      }
                    },

                    child: Text(
                      AppLocaleKey.agentBuyNow.tr(),
                      style: AppTextStyle.bodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700, color: AppColor.whiteColor(context)),
                    ),
                  ),
                  Gap(8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
