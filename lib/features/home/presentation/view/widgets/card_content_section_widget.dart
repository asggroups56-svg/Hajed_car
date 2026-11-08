import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class CardContentSection extends StatelessWidget {
  const CardContentSection({super.key, required this.car, required this.onTap});

  final Map<String, dynamic> car;
  final VoidCallback onTap;

  /// Plate/registration fee stored on the car. It already includes VAT.
  double get _platesValue =>
      (car['PaintingsVal'] as num?)?.toDouble() ??
      (car['PAINTINGS_VAL'] as num?)?.toDouble() ??
      (car['paintingsVal'] as num?)?.toDouble() ??
      double.tryParse(car['PaintingsVal']?.toString() ?? '') ??
      double.tryParse(car['PAINTINGS_VAL']?.toString() ?? '') ??
      double.tryParse(car['paintingsVal']?.toString() ?? '') ??
      0.0;

  void _toggleComparison(BuildContext context) {
    if (HiveMethods.isInComparison(car)) {
      HiveMethods.removeFromComparison(car);
      CommonMethods.showToast(
        message: AppLocaleKey.removeFromCompare.tr(),
        type: ToastType.success,
      );
      return;
    }

    final added = HiveMethods.addToComparison(car);
    if (added) {
      CommonMethods.showToast(message: AppLocaleKey.added_to_compare.tr(), type: ToastType.success);
    }
  }

  String get formattedPriceWithVat {
    final rawPrice = car['price']?.toString();
    if (rawPrice == null || rawPrice.isEmpty || rawPrice == 'null' || rawPrice == '---') {
      return '---';
    }
    final double paintingsVal = _platesValue;

    // If price already contains commas (already formatted from formattedPriceWithVat),
    // strip commas and return formatted adding paintingsVal
    final isAlreadyFormatted = rawPrice.contains(',');
    final numericStr = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final double parsedPrice = double.tryParse(numericStr) ?? 0;
    if (parsedPrice <= 0) return rawPrice;

    final formatter = NumberFormat('#,##0', 'en_US');
    if (isAlreadyFormatted) {
      return formatter.format(parsedPrice + paintingsVal);
    }

    // Raw price without VAT - add VAT + paintings/plates value
    final vatNumber = HiveMethods.getVatNumber();
    final double vatPercentage = double.tryParse(vatNumber?.toString() ?? '') ?? 15.0;
    final double priceWithVat = parsedPrice * (1 + (vatPercentage / 100));
    final double totalCashPrice = priceWithVat + paintingsVal;
    return formatter.format(totalCashPrice);
  }

  /// Uses the same financing priority as the cars page: the row's own offer
  /// terms, a car-specific installment, its interest rate, a supplied
  /// installment string, then the lowest available bank offer and finally the
  /// standard 60-month estimate.
  String? _formattedMonthlyInstallment(List<FinancingAdModel> offers) {
    final rawPrice = car['price']?.toString() ?? '';
    final price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final formatter = NumberFormat('#,##0', 'en_US');

    // A row that carries its own offer terms is financed with those terms.
    // Standard bank offers must never replace them.
    final vehicle = GetBrandCarsDataModel.fromJson(car);
    final offerInstallment = FinancingAdModel.vehicleOfferMonthlyInstallment(
      vehicle,
      platesVal: _platesValue,
    );
    if (offerInstallment != null && offerInstallment > 0) {
      return formatter.format(offerInstallment);
    }

    if (price <= 0) return null;

    final monthlyInstallment = _numberValue(car['monthlyInstallment']);
    if (monthlyInstallment > 0) return formatter.format(monthlyInstallment);

    final interestRate = _numberValue(car['interestRate']);
    if (interestRate > 0) {
      final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
      final carPrice = (price + 3000) * (1 + vatPercentage / 100) + _platesValue;
      return formatter.format((carPrice + carPrice * (interestRate / 100) * 5) / 60);
    }

    final installments = car['installments']?.toString().trim();
    if (installments != null &&
        installments.isNotEmpty &&
        installments != '0' &&
        installments.toLowerCase() != 'null') {
      return installments;
    }

    if (offers.isNotEmpty) {
      final lowestOffer = offers.reduce(
        (a, b) =>
            a.monthlyInstallmentForPrice(price, platesVal: _platesValue) <=
                b.monthlyInstallmentForPrice(price, platesVal: _platesValue)
            ? a
            : b,
      );
      return formatter.format(
        lowestOffer.monthlyInstallmentForPrice(price, platesVal: _platesValue),
      );
    }

    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice = (price + 3000) * (1 + vatPercentage / 100) + _platesValue;
    return formatter.format((carPrice * 1.225) / 60);
  }

  double _numberValue(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

  List<Color> _parseCarColors(BuildContext context, String colorName) {
    final name = colorName.trim().toLowerCase();
    final List<Color> foundColors = [];

    final Map<List<String>, Color> colorKeywords = {
      ['أبيض', 'ابيض', 'white']: Colors.white,
      ['أسود', 'اسود', 'black']: Colors.black,
      ['فضي', 'silver']: Colors.grey.shade400,
      ['رمادي', 'رصاصي', 'grey', 'gray']: Colors.grey,
      ['أحمر', 'احمر', 'red']: Colors.red,
      ['أزرق', 'ازرق', 'كحلي', 'blue', 'navy']: Colors.blue,
      ['بيج', 'beige']: const Color(0xFFF5F5DC),
      ['بني', 'brown']: Colors.brown,
      ['أخضر', 'اخضر', 'زيتي', 'green']: AppColor.greenColor(context),
      ['أصفر', 'اصفر', 'yellow']: Colors.yellow,
      ['برتقالي', 'orange']: Colors.orange,
      ['ذهبي', 'gold']: const Color(0xFFFFD700),
      ['عنابي', 'خمري', 'maroon']: const Color(0xFF800000),
    };

    for (final entry in colorKeywords.entries) {
      for (final keyword in entry.key) {
        if (name.contains(keyword)) {
          if (!foundColors.contains(entry.value)) {
            foundColors.add(entry.value);
          }
          break;
        }
      }
    }

    return foundColors;
  }

  bool _isMultipleColors(String colorName) {
    final name = colorName.trim().toLowerCase();
    return name.contains('/') ||
        name.contains('\\') ||
        name.contains('+') ||
        name.contains('مع') ||
        name.contains('و') ||
        name.contains('two tone') ||
        name.contains('توتون') ||
        name.contains('لونين') ||
        name.contains('متعدد');
  }

  Widget _buildColorIcon(BuildContext context, String colorName) {
    final colors = _parseCarColors(context, colorName);
    final isMulti = colors.length >= 2 || _isMultipleColors(colorName);

    // إذا كان هناك لونين أو ألوان متعددة -> عرض أيقونة الألوان المتعددة (Multi-color Lens / Palette)
    if (isMulti) {
      final List<Color> gradientColors = colors.length >= 2
          ? colors
          : const [
              Color(0xFFE53935),
              Color(0xFFFB8C00),
              Color(0xFF43A047),
              Color(0xFF1E88E5),
              Color(0xFF8E24AA),
            ];

      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(Icons.color_lens_rounded, size: 15.w, color: Colors.white),
      );
    }

    // إذا كان لوناً واحداً معروفاً
    if (colors.length == 1) {
      final singleColor = colors.first;
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: singleColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: singleColor == Colors.white
                ? AppColor.greyColor(context).withValues(alpha: 0.6)
                : AppColor.blackTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: singleColor.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }

    // الحالة الافتراضية
    return Icon(Icons.palette_outlined, color: AppColor.greyColor(context), size: 14.w);
  }

  @override
  Widget build(BuildContext context) {
    final String rawColor =
        (car['color'] ?? car['Color'] ?? car['bodyColor'] ?? car['BODY_COLOR'] ?? '')
            .toString()
            .trim();
    final String displayColor = rawColor.isNotEmpty && rawColor.toLowerCase() != 'null'
        ? rawColor
        : '—';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight;
        final bool isShort = maxHeight.isFinite && maxHeight < 210;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: isShort ? 4.h : 6.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم السيارة
              Text(
                car['name']?.toString() ?? '',
                style: AppTextStyle.bodyMedium(context).copyWith(
                  color: AppColor.blackTextColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: isShort ? 11.sp : 12.sp,
                ),
                maxLines: isShort ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              // التفاصيل المصغرة (السنة واللون)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MiniDetailWidget(
                    icon: Icons.calendar_today_outlined,
                    label: car['year']?.toString() ?? '—',
                  ),
                  MiniDetailWidget(
                    customIcon: _buildColorIcon(context, displayColor),
                    label: displayColor,
                  ),
                ],
              ),

              // صف الأسعار (كاش وتقسيط)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocaleKey.cash.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.greyColor(context),
                            fontWeight: FontWeight.w900,
                            fontSize: isShort ? 9.sp : 10.sp,
                          ),
                        ),
                        Gap(2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyle.bodyMedium(context).copyWith(
                                color: AppColor.greenColor(context),
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Arial',
                                fontSize: isShort ? 12.sp : 14.sp,
                              ),
                              children: [
                                TextSpan(text: formattedPriceWithVat),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(start: 2.w),
                                    child: SvgPicture.asset(
                                      AppImages.sar,
                                      width: isShort ? 14.w : 16.w,
                                      height: isShort ? 14.h : 16.h,
                                      colorFilter: ColorFilter.mode(
                                        AppColor.greenColor(context),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.5.w,
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                    height: isShort ? 26.h : 32.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocaleKey.agentInstallments.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.greyColor(context),
                            fontWeight: FontWeight.w900,
                            fontSize: isShort ? 9.sp : 10.sp,
                          ),
                        ),
                        Gap(2.h),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            final installment = _formattedMonthlyInstallment(
                              state.normalFinancingStatus.data ?? const [],
                            );
                            if (installment == null) return const SizedBox.shrink();

                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyle.bodyMedium(context).copyWith(
                                    color: AppColor.primaryColor(context),
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Arial',
                                    fontSize: isShort ? 12.sp : 14.sp,
                                  ),
                                  children: [
                                    TextSpan(text: installment),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(start: 2.w),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppImages.sar,
                                              width: isShort ? 14.w : 16.w,
                                              height: isShort ? 14.h : 16.h,
                                              colorFilter: ColorFilter.mode(
                                                AppColor.primaryColor(context),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            Gap(2.w),
                                            Text(
                                              '/ ${AppLocaleKey.month.tr()}',
                                              style: AppTextStyle.bodySmall(context).copyWith(
                                                color: AppColor.primaryColor(context),
                                                fontWeight: FontWeight.w900,
                                                fontSize: isShort ? 8.sp : 9.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ملاحظة شامل الضريبة
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColor.greyColor(context),
                    size: isShort ? 12.w : 14.w,
                  ),
                  Gap(4.w),
                  Expanded(
                    child: Text(
                      'شامل الضريبة واللوحات، والقسط مبدئي 60 شهراً بدون دفعة أولى',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.greyColor(context),
                        fontWeight: FontWeight.w800,
                        fontSize: isShort ? 6.5.sp : 7.sp,
                      ),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // أزرار التحكم (التفاصيل والمقارنة)
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: onTap,
                      height: isShort ? 26.h : 30.h,
                      color: AppColor.primaryColor(context),
                      radius: 10.r,
                      borderColor: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocaleKey.details.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.whiteColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: CustomButton(
                      radius: 10.r,
                      onPressed: () => _toggleComparison(context),
                      color: AppColor.whiteColor(context).withValues(alpha: 0.1),
                      borderColor: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                      height: isShort ? 26.h : 30.h,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColor.blackTextColor(context),
                              size: isShort ? 13.w : 15.w,
                            ),
                            Gap(4.w),
                            Text(
                              AppLocaleKey.compare.tr(),
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.blackTextColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
