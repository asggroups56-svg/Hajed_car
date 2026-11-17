import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GridCarCardWidget extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final String? heroTag;
  final bool isOffer;
  final FinancingAdModel? offer;
  final List<FinancingAdModel> financingOffers;

  const GridCarCardWidget({
    super.key,
    required this.car,
    this.heroTag,
    this.isOffer = false,
    this.offer,
    this.financingOffers = const [],
  });

  static String _formatPercentage(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  double? get _firstInstallmentPct {
    return offer?.firstInstallmentPct ??
        offer?.firstInstallmentPctOther ??
        car.firstInstallmentPct ??
        car.firstInstallmentPctOther ??
        (financingOffers.isNotEmpty
            ? (financingOffers.first.firstInstallmentPct ??
                  financingOffers.first.firstInstallmentPctOther)
            : null);
  }

  double? get _lastInstallmentPct {
    return offer?.lastInstallmentPct ??
        offer?.lastInstallmentPctOther ??
        car.lastInstallmentPct ??
        car.lastInstallmentPctOther ??
        (financingOffers.isNotEmpty
            ? (financingOffers.first.lastInstallmentPct ??
                  financingOffers.first.lastInstallmentPctOther)
            : null);
  }

  bool get _hasOfferBanner =>
      isOffer ||
      car.isVehicleOffer ||
      offer != null ||
      (_lastInstallmentPct != null && _lastInstallmentPct! > 0 && car.isOfferActive);

  String? _getInstallmentPrice(List<FinancingAdModel> cubitOffers) {
    final plates = car.paintingsVal ?? offer?.paintingsVal ?? 0.0;

    final vehicleOfferInstallment = FinancingAdModel.vehicleOfferMonthlyInstallment(
      car,
      platesVal: plates,
    );
    if (vehicleOfferInstallment != null && vehicleOfferInstallment > 0) {
      return NumberFormat('#,##0', 'en_US').format(vehicleOfferInstallment);
    }

    final priceString = (car.effectivePrice ?? car.price)?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
    final price = double.tryParse(priceString) ?? 0;
    if (price <= 0) return null;

    if (offer != null) {
      return NumberFormat(
        '#,##0',
        'en_US',
      ).format(offer!.monthlyInstallmentForPrice(price, platesVal: plates));
    }

    if (car.monthlyInstallment != null && car.monthlyInstallment! > 0) {
      return NumberFormat('#,##0', 'en_US').format(car.monthlyInstallment);
    }

    if (car.interestRate != null && car.interestRate! > 0) {
      final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
      final carPrice = (price + 3000) * (1 + vatPercentage / 100) + plates;
      return NumberFormat(
        '#,##0',
        'en_US',
      ).format((carPrice + carPrice * (car.interestRate! / 100) * 5) / 60);
    }

    final allOffers = financingOffers.isNotEmpty ? financingOffers : cubitOffers;
    if (allOffers.isNotEmpty) {
      final lowestOffer = allOffers.reduce(
        (a, b) =>
            a.monthlyInstallmentForPrice(price, platesVal: plates) <=
                b.monthlyInstallmentForPrice(price, platesVal: plates)
            ? a
            : b,
      );
      return NumberFormat(
        '#,##0',
        'en_US',
      ).format(lowestOffer.monthlyInstallmentForPrice(price, platesVal: plates));
    }

    final vatPercentage = double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final carPrice = (price + 3000) * (1 + vatPercentage / 100) + plates;
    return NumberFormat('#,##0', 'en_US').format((carPrice * 1.225) / 60);
  }

  void _toggleComparison(BuildContext context) {
    final carMap = car.toMap();
    final isInCompare = HiveMethods.isInComparison(carMap);
    if (isInCompare) {
      HiveMethods.removeFromComparison(carMap);
      CommonMethods.showToast(
        message: AppLocaleKey.removeFromCompare.tr(),
        type: ToastType.success,
      );
      return;
    }

    final added = HiveMethods.addToComparison(carMap);
    if (added) {
      CommonMethods.showToast(message: AppLocaleKey.added_to_compare.tr(), type: ToastType.success);
    }
  }

  Color _parseColor(String colorName) {
    final name = colorName.trim().toLowerCase();
    if (name.contains('أبيض') || name.contains('ابيض') || name.contains('white')) {
      return Colors.white;
    }
    if (name.contains('أسود') || name.contains('اسود') || name.contains('black')) {
      return Colors.black;
    }
    if (name.contains('فضي') || name.contains('silver')) return Colors.grey.shade400;
    if (name.contains('رمادي') ||
        name.contains('رصاصي') ||
        name.contains('grey') ||
        name.contains('gray')) {
      return Colors.grey.shade600;
    }
    if (name.contains('أحمر') || name.contains('احمر') || name.contains('red')) return Colors.red;
    if (name.contains('أزرق') ||
        name.contains('ازرق') ||
        name.contains('كحلي') ||
        name.contains('blue') ||
        name.contains('navy')) {
      return Colors.blue;
    }
    if (name.contains('بيج') || name.contains('beige')) return const Color(0xFFF5F5DC);
    if (name.contains('بني') || name.contains('brown')) return Colors.brown;
    if (name.contains('أخضر') || name.contains('اخضر') || name.contains('green')) {
      return Colors.green;
    }
    if (name.contains('ذهبي') || name.contains('gold')) return const Color(0xFFFFD700);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final String rawColor =
        (car.bodyColor.isNotEmpty && car.bodyColor.toLowerCase() != 'null'
                ? car.bodyColor
                : (car.color.isNotEmpty && car.color.toLowerCase() != 'null' ? car.color : ''))
            .trim();
    final String displayColor = rawColor.isNotEmpty ? rawColor : '—';
    final String displayYear = car.makeYear > 0 ? '${car.makeYear}' : '—';
    final Color colorDot = _parseColor(displayColor);

    return GestureDetector(
      onTap: () {
        NavigatorMethods.pushNamed(
          context,
          RoutesName.carDetailsScreen,
          arguments: {'car': car, 'heroTag': heroTag, 'offer': offer, 'offers': financingOffers},
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        color: AppColor.secondAppColor(context),
        elevation: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── صورة السيارة مع الأزرار ──
            Stack(
              children: [
                Hero(
                  tag: heroTag ?? 'grid_car_image_${HiveMethods.getCarUniqueId(car.toMap())}',
                  child: car.fullCarImage.isNotEmpty && car.fullCarImage.startsWith('http')
                      ? CustomNetworkImage(
                          imageUrl: car.fullCarImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 115.h,
                        )
                      : Image.asset(
                          car.fullCarImage.isNotEmpty
                              ? car.fullCarImage
                              : AppImages.assetsImagesLogeStatic,
                          fit: BoxFit.cover,
                          height: 115.h,
                          width: double.infinity,
                        ),
                ),

                // زر المفضلة
                PositionedDirectional(
                  top: 6.h,
                  start: 6.w,
                  child: BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final isFav = context.read<FavoritesCubit>().isFavorite(car.toMap());
                      return Container(
                        height: 28.h,
                        width: 28.h,
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            context.read<FavoritesCubit>().toggleFavorite(car.toMap());
                          },
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav
                                ? AppColor.redColor(context)
                                : AppColor.blackTextColor(context),
                            size: 16.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // شريط العرض التمويلي
                if (_hasOfferBanner)
                  PositionedDirectional(
                    top: 0,
                    end: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.r),
                          bottomRight: Radius.circular(10.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_firstInstallmentPct != null)
                            Text(
                              context.locale.languageCode == 'ar'
                                  ? 'أولى ${_formatPercentage(_firstInstallmentPct!)}%'
                                  : '1st ${_formatPercentage(_firstInstallmentPct!)}%',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.whiteColor(context),
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          if (_lastInstallmentPct != null)
                            Text(
                              context.locale.languageCode == 'ar'
                                  ? 'أخيرة ${_formatPercentage(_lastInstallmentPct!)}%'
                                  : 'Last ${_formatPercentage(_lastInstallmentPct!)}%',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.whiteColor(context),
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          Text(
                            context.locale.languageCode == 'ar' ? 'عرض تمويل' : 'Offer',
                            style: AppTextStyle.bodySmall(context).copyWith(
                              color: AppColor.whiteColor(context),
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── محتوى البطاقة ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // اسم السيارة
                    Text(
                      car.itemName,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.blackTextColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // شريط الخصائص (السنة + اللون)
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 10.sp,
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                              ),
                              Gap(3.w),
                              Text(
                                displayYear,
                                style: AppTextStyle.bodySmall(context).copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.blackTextColor(context).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(5.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: colorDot,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorDot == Colors.white
                                          ? Colors.grey.shade400
                                          : Colors.transparent,
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                Gap(3.w),
                                Expanded(
                                  child: Text(
                                    displayColor,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.blackTextColor(
                                        context,
                                      ).withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // فاصل خفيف
                    Divider(
                      color: AppColor.blackTextColor(context).withValues(alpha: 0.08),
                      height: 6.h,
                      thickness: 0.8,
                    ),

                    // سعر الكاش
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isOffer ? AppLocaleKey.price.tr() : AppLocaleKey.cash.tr(),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              car.formattedPriceWithVat,
                              style: AppTextStyle.bodyMedium(context).copyWith(
                                color: AppColor.greenColor(context),
                                fontWeight: FontWeight.w900,
                                fontSize: 12.sp,
                              ),
                            ),
                            Gap(3.w),
                            SvgPicture.asset(
                              AppImages.sar,
                              height: 12.h,
                              width: 12.w,
                              colorFilter: ColorFilter.mode(
                                AppColor.greenColor(context),
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(10.h),
                    // القسط الشهري
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        final cubitOffers = state.normalFinancingStatus.data ?? const [];
                        final installment = _getInstallmentPrice(cubitOffers);
                        if (installment == null) return const SizedBox.shrink();

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              context.locale.languageCode == 'ar' ? 'التقسيط' : 'Installment',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.blueColor(context),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  installment,
                                  style: AppTextStyle.bodyMedium(context).copyWith(
                                    color: AppColor.blueColor(context),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Gap(3.w),
                                SvgPicture.asset(
                                  AppImages.sar,
                                  height: 12.h,
                                  width: 12.w,
                                  colorFilter: ColorFilter.mode(
                                    AppColor.blueColor(context),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  context.locale.languageCode == 'ar' ? '/ شهر' : '/mo',
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: AppColor.blueColor(context),
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    Gap(5.h),
                    // صف الأزرار: احسب قسطك + زرار المقارنة
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 25.h,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
                                foregroundColor: AppColor.primaryColor(context),
                                backgroundColor: AppColor.primaryColor(
                                  context,
                                ).withValues(alpha: 0.1),
                                side: BorderSide(
                                  color: AppColor.primaryColor(context).withValues(alpha: 0.35),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onPressed: () {
                                if (HiveMethods.isGuest()) {
                                  CommonMethods.showLoginRequiredDialog(context);
                                  return;
                                }
                                NavigatorMethods.pushNamed(
                                  context,
                                  RoutesName.financingScreen,
                                  arguments: {
                                    'car': car,
                                    'offer': offer,
                                    'offers': financingOffers,
                                  },
                                );
                              },
                              icon: Icon(Icons.calculate_outlined, size: 13.sp),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.locale.languageCode == 'ar' ? 'احسب قسطك' : 'Calculate',
                                  style: AppTextStyle.bodySmall(
                                    context,
                                  ).copyWith(fontSize: 10.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Gap(5.w),
                        Expanded(
                          flex: 2,
                          child: ValueListenableBuilder<Box>(
                            valueListenable: Hive.box(
                              'app',
                            ).listenable(keys: const ['comparisonList']),
                            builder: (context, _, child) {
                              final isInCompare = HiveMethods.isInComparison(car.toMap());
                              return SizedBox(
                                height: 25.h,
                                child: InkWell(
                                  onTap: () => _toggleComparison(context),
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isInCompare
                                          ? AppColor.greenColor(context)
                                          : AppColor.blackTextColor(
                                              context,
                                            ).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: isInCompare
                                            ? AppColor.greenColor(context)
                                            : AppColor.blackTextColor(
                                                context,
                                              ).withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isInCompare ? Icons.check : Icons.add,
                                          size: 13.sp,
                                          color: isInCompare
                                              ? Colors.white
                                              : AppColor.blackTextColor(context),
                                        ),
                                        Gap(2.w),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            AppLocaleKey.compare.tr(),
                                            style: AppTextStyle.bodySmall(context).copyWith(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isInCompare
                                                  ? Colors.white
                                                  : AppColor.blackTextColor(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
