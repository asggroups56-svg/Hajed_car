import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CashPackage {
  final String titleKey;
  final String descKey;
  final double extraPrice;
  final List<String> featuresKeys;
  final Color themeColor;

  CashPackage({
    required this.titleKey,
    required this.descKey,
    required this.extraPrice,
    required this.featuresKeys,
    required this.themeColor,
  });
}

class CashPackagesWidget extends StatefulWidget {
  final GetBrandCarsDataModel car;

  const CashPackagesWidget({super.key, required this.car});

  @override
  State<CashPackagesWidget> createState() => _CashPackagesWidgetState();
}

class _CashPackagesWidgetState extends State<CashPackagesWidget> {
  int _selectedIndex = 0;
  late double _baseCarPrice;
  late double _vatPercentage;

  @override
  void initState() {
    super.initState();
    final priceRawString = widget.car.price ?? '0';
    final priceString = priceRawString.replaceAll(RegExp(r'[^0-9.]'), '');
    _baseCarPrice = double.tryParse(priceString) ?? 0.0;
    _vatPercentage = _getVatPercentage();
  }

  double _getVatPercentage() {
    return 15.0;
  }

  double _getPriceWithVat(double price) {
    return price * (1 + (_vatPercentage / 100));
  }

  final List<CashPackage> _packages = [
    CashPackage(
      titleKey: AppLocaleKey.packageBasic,
      descKey: AppLocaleKey.packageBasicDesc,
      extraPrice: 0,
      themeColor: const Color(0xFF64748B),
      featuresKeys: [AppLocaleKey.featureComprehensiveCheck, AppLocaleKey.featureAgencyWarranty],
    ),
    CashPackage(
      titleKey: AppLocaleKey.packageGold,
      descKey: AppLocaleKey.packageGoldDesc,
      extraPrice: 2000,
      themeColor: const Color(0xFFD4AF37),
      featuresKeys: [
        AppLocaleKey.featureComprehensiveCheck,
        AppLocaleKey.featureAgencyWarranty,
        AppLocaleKey.featureTinting,
        AppLocaleKey.featureFrontPPF,
        AppLocaleKey.featureRoadsideAssistance,
      ],
    ),
    CashPackage(
      titleKey: AppLocaleKey.packagePlatinum,
      descKey: AppLocaleKey.packagePlatinumDesc,
      extraPrice: 5000,
      themeColor: const Color(0xFF2B2D42),
      featuresKeys: [
        AppLocaleKey.featureComprehensiveCheck,
        AppLocaleKey.featureAgencyWarranty,
        AppLocaleKey.featureFullPPF,
        AppLocaleKey.featureTinting,
        AppLocaleKey.featureFreeMaintenance,
        AppLocaleKey.featureExtendedWarranty,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_baseCarPrice <= 0) return const SizedBox.shrink();
    final formatter = NumberFormat('#,##0', 'en_US');
    final selectedPackage = _packages[_selectedIndex];
    final double plates = widget.car.paintingsVal ?? 0.0;
    final basePriceWithVat = _getPriceWithVat(_baseCarPrice) + plates;
    final extraPriceWithVat = _getPriceWithVat(selectedPackage.extraPrice);
    final currentTotalWithVat = basePriceWithVat + extraPriceWithVat;
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocaleKey.cashPackagesTitle.tr(),
            style: AppTextStyle.titleLarge(context).copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.blackTextColor(context),
            ),
          ),
          Gap(4.h),
          Text(
            AppLocaleKey.cashPackagesSubtitle.tr(),
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          Gap(8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14.sp,
                  color: AppColor.primaryColor(context),
                ),
                Gap(6.w),
                Text(
                  '${AppLocaleKey.vat_inclusive.tr()} (${_vatPercentage.toStringAsFixed(0)}%)',
                  style: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Gap(16.h),
          SizedBox(
            height: 280.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                final isSelected = index == _selectedIndex;
                final packageExtraWithVat = _getPriceWithVat(package.extraPrice);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 240.w,
                    margin: EdgeInsets.only(right: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? package.themeColor.withValues(alpha: 0.05)
                          : AppColor.secondAppColor(context),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? package.themeColor : Colors.grey.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: package.themeColor.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              package.titleKey.tr(),
                              style: AppTextStyle.bodyLarge(context).copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? package.themeColor
                                    : AppColor.blackTextColor(context),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: package.themeColor,
                                size: 24.sp,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: Colors.grey.withValues(alpha: 0.3),
                                size: 24.sp,
                              ),
                          ],
                        ),
                        Gap(8.h),
                        Text(
                          package.descKey.tr(),
                          style: AppTextStyle.bodySmall(
                            context,
                          ).copyWith(color: Colors.grey[600], height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap(16.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: package.themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ValueWithCurrencyIcon(
                            text: package.extraPrice == 0
                                ? '${AppLocaleKey.sar.tr()} 0'
                                : '+ ${formatter.format(packageExtraWithVat)} ${AppLocaleKey.sar.tr()}',
                            textStyle: AppTextStyle.bodyMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold, color: package.themeColor),
                          ),
                        ),
                        if (package.extraPrice > 0)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              AppLocaleKey.taxIncluded.tr(),
                              style: AppTextStyle.bodySmall(
                                context,
                              ).copyWith(fontSize: 9.sp, color: Colors.grey[500]),
                            ),
                          ),
                        Gap(16.h),
                        Text(
                          AppLocaleKey.includedFeatures.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColor.blackTextColor(context),
                          ),
                        ),
                        Gap(8.h),
                        Expanded(
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: package.featuresKeys.length,
                            separatorBuilder: (context, _) => Gap(6.h),
                            itemBuilder: (context, featureIndex) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 14.sp,
                                      color: AppColor.greenColor(context),
                                    ),
                                  ),
                                  Gap(6.w),
                                  Expanded(
                                    child: Text(
                                      package.featuresKeys[featureIndex].tr(),
                                      style: AppTextStyle.bodySmall(
                                        context,
                                      ).copyWith(fontSize: 11.sp, color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.primaryColor(context).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocaleKey.totalWithPackage.tr(),
                      style: AppTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: AppColor.blackTextColor(context)),
                    ),
                    ValueWithCurrencyIcon(
                      text: '${formatter.format(currentTotalWithVat)} ${AppLocaleKey.sar.tr()}',
                      textStyle: AppTextStyle.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColor.primaryColor(context),
                      ),
                    ),
                  ],
                ),
                Gap(8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppLocaleKey.baseCarPriceWithVat.tr()}',
                            style: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(color: Colors.grey[600], fontSize: 11.sp),
                          ),
                          ValueWithCurrencyIcon(
                            text:
                                '${formatter.format(basePriceWithVat)}   ${AppLocaleKey.sar.tr()}',
                            textStyle: AppTextStyle.bodySmall(context).copyWith(
                              color: Colors.grey[600],
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (selectedPackage.extraPrice > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLocaleKey.extraPackageValueWithVat.tr()}',
                              style: AppTextStyle.bodySmall(
                                context,
                              ).copyWith(color: Colors.grey[600], fontSize: 11.sp),
                            ),
                            ValueWithCurrencyIcon(
                              text:
                                  '+ ${formatter.format(extraPriceWithVat)} ${AppLocaleKey.sar.tr()}',
                              textStyle: AppTextStyle.bodySmall(context).copyWith(
                                color: selectedPackage.themeColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Divider(height: 12.h, color: Colors.grey.withValues(alpha: 0.2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppLocaleKey.vat_inclusive.tr()} (${_vatPercentage.toStringAsFixed(0)}%)',
                            style: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(color: Colors.grey[600], fontSize: 11.sp),
                          ),
                          ValueWithCurrencyIcon(
                            text:
                                '+ ${formatter.format(currentTotalWithVat - (_baseCarPrice + selectedPackage.extraPrice))} ${AppLocaleKey.sar.tr()}',
                            textStyle: AppTextStyle.bodySmall(context).copyWith(
                              color: Colors.grey[600],
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
