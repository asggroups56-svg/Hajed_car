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
import 'package:car/features/cars/presentation/widget/bank_installments_banner_widget.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PremiumCarCardWidget extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final String? heroTag;
  final bool isOffer;
  final FinancingAdModel? offer;
  final List<FinancingAdModel> financingOffers;
  const PremiumCarCardWidget({
    super.key,
    required this.car,
    this.heroTag,
    this.isOffer = false,
    this.offer,
    this.financingOffers = const [],
  });

  /// Renders percentages without changing their precision.
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

  bool get _showInstallmentBlock =>
      isOffer ||
      (offer != null) ||
      financingOffers.isNotEmpty ||
      car.hasFinancing ||
      (car.price != null && car.price!.isNotEmpty && car.price != '0');

  void _openDetails(BuildContext context) {
    NavigatorMethods.pushNamed(
      context,
      RoutesName.carDetailsScreen,
      arguments: {'car': car, 'heroTag': heroTag, 'offer': offer, 'offers': financingOffers},
    );
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
    final String brand = car.groupName.trim();
    final bool hasFuel = car.fuelType.isNotEmpty && car.fuelType.toLowerCase() != 'null';
    final bool isAr = context.locale.languageCode == 'ar';
    final textColor = AppColor.blackTextColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColor.dividerColor(context).withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDetails(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── الصورة ─────────
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroTag ?? 'car_image_${HiveMethods.getCarUniqueId(car.toMap())}',
                        child: car.fullCarImage.isNotEmpty && car.fullCarImage.startsWith('http')
                            ? CustomNetworkImage(
                                imageUrl: car.fullCarImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200.h,
                              )
                            : Image.asset(
                                car.fullCarImage.isNotEmpty
                                    ? car.fullCarImage
                                    : AppImages.assetsImagesLogeStatic,
                                fit: BoxFit.cover,
                                height: 200.h,
                                width: double.infinity,
                              ),
                      ),
                      // تدرج سفلي ناعم لقراءة الشارات
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 80.h,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // المفضلة
                      PositionedDirectional(
                        top: 12.h,
                        start: 12.w,
                        child: BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, state) {
                            final isFav = context.read<FavoritesCubit>().isFavorite(car.toMap());
                            return GestureDetector(
                              onTap: () =>
                                  context.read<FavoritesCubit>().toggleFavorite(car.toMap()),
                              child: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: AppColor.whiteColor(context),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav
                                      ? AppColor.redColor(context)
                                      : AppColor.blackTextColor(context),
                                  size: 20.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // شارة العرض التمويلي
                      if (_hasOfferBanner)
                        PositionedDirectional(
                          top: 0,
                          end: 16.w,
                          child: _buildOfferRibbon(context, isAr),
                        ),
                      // الماركة + السنة
                      PositionedDirectional(
                        bottom: 12.h,
                        start: 12.w,
                        child: brand.isNotEmpty && brand.toLowerCase() != 'null'
                            ? _glassChip(brand, icon: Icons.verified_rounded)
                            : const SizedBox.shrink(),
                      ),
                      PositionedDirectional(
                        bottom: 12.h,
                        end: 12.w,
                        child: _glassChip(displayYear, icon: Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ),

                // ───────── المحتوى ─────────
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.itemName,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _specChip(
                            context,
                            leading: _buildColorIcon(context, displayColor),
                            label: displayColor,
                          ),
                          if (hasFuel)
                            _specChip(
                              context,
                              leading: Icon(
                                Icons.local_gas_station_outlined,
                                size: 14.sp,
                                color: textColor.withValues(alpha: 0.65),
                              ),
                              label: car.fuelType,
                            ),
                        ],
                      ),
                      Gap(14.h),

                      // ───── لوحة الأسعار ─────
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.035),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: AppColor.dividerColor(context).withValues(alpha: 0.6),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isOffer ? AppLocaleKey.price.tr() : AppLocaleKey.cash.tr(),
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        color: textColor.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Gap(6.h),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              car.formattedPriceWithVat,
                                              style: AppTextStyle.bodyMedium(context).copyWith(
                                                color: AppColor.greenColor(context),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 17.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Gap(4.w),
                                        SvgPicture.asset(
                                          AppImages.sar,
                                          height: 16.h,
                                          width: 16.w,
                                          colorFilter: ColorFilter.mode(
                                            AppColor.greenColor(context),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (_showInstallmentBlock) ...[
                                Container(
                                  width: 1,
                                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                                  color: AppColor.dividerColor(context),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (HiveMethods.isGuest()) {
                                        CommonMethods.showLoginRequiredDialog(context);
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BankInstallmentsBannerWidget(
                                            car: car,
                                            isOffer: isOffer,
                                            offer: offer,
                                            offers: financingOffers,
                                          ),
                                        ),
                                      );
                                    },
                                    child: BankInstallmentsBannerWidget(
                                      car: car,
                                      isOffer: isOffer,
                                      offer: offer,
                                      offers: financingOffers,
                                      compact: true,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Gap(8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13.sp,
                            color: AppColor.greyColor(context),
                          ),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              AppLocaleKey.agentIncludesVat.tr(),
                              style: AppTextStyle.bodySmall(
                                context,
                              ).copyWith(color: AppColor.greyColor(context)),
                            ),
                          ),
                        ],
                      ),
                      Gap(14.h),
                      _buildCardActions(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── مكونات مساعدة ─────────────────

  Widget _glassChip(String label, {required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          Gap(5.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specChip(BuildContext context, {required Widget leading, required String label}) {
    final textColor = AppColor.blackTextColor(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          Gap(6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150.w),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: textColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                fontSize: 11.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferRibbon(BuildContext context, bool isAr) {
    final first = _firstInstallmentPct;
    final last = _lastInstallmentPct;
    final primary = AppColor.primaryColor(context);
    final hsl = HSLColor.fromColor(primary);
    final deep = hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();

    TextStyle pctStyle() => AppTextStyle.bodySmall(context).copyWith(
      color: AppColor.whiteColor(context),
      fontSize: 11.5.sp,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary, deep],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_rounded, size: 11.sp, color: const Color(0xFFFFD966)),
              Gap(4.w),
              Text(
                isAr ? 'عرض تمويل' : 'Financing Offer',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.whiteColor(context),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
          if (first != null || last != null) ...[
            Gap(5.h),
            Container(height: 1, width: 56.w, color: Colors.white.withValues(alpha: 0.35)),
            Gap(5.h),
          ],
          if (first != null)
            Text(
              isAr ? 'أولى ${_formatPercentage(first)}%' : '1st ${_formatPercentage(first)}%',
              style: pctStyle(),
            ),
          if (last != null)
            Text(
              isAr ? 'أخيرة ${_formatPercentage(last)}%' : 'Last ${_formatPercentage(last)}%',
              style: pctStyle(),
            ),
        ],
      ),
    );
  }

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

  /// NOTE: the Arabic conjunction "و" and "مع" are matched only as standalone
  /// words. Matching them as substrings flagged every colour containing the
  /// letter و (e.g. "أسود") as multi-colour.
  bool _isMultipleColors(String colorName) {
    final name = colorName.trim().toLowerCase();
    return name.contains('/') ||
        name.contains('\\') ||
        name.contains('+') ||
        name.contains(' مع ') ||
        name.contains(' و ') ||
        name.contains('two tone') ||
        name.contains('توتون') ||
        name.contains('لونين') ||
        name.contains('متعدد');
  }

  Widget _buildColorIcon(BuildContext context, String colorName) {
    final colors = _parseCarColors(context, colorName);
    final isMulti = colors.length >= 2 || _isMultipleColors(colorName);

    if (isMulti) {
      final List<Color> gradientColors = colors.length >= 2
          ? [...colors, colors.first]
          : const [
              Color(0xFFE53935),
              Color(0xFFFB8C00),
              Color(0xFF43A047),
              Color(0xFF1E88E5),
              Color(0xFF8E24AA),
              Color(0xFFE53935),
            ];

      return Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: gradientColors),
          border: Border.all(
            color: AppColor.blackTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      );
    }

    if (colors.length == 1) {
      final singleColor = colors.first;
      return Container(
        width: 14.w,
        height: 14.w,
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
              color: singleColor.withValues(alpha: 0.3),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }

    return Icon(Icons.palette_outlined, color: AppColor.greyColor(context), size: 14.sp);
  }

  Widget _buildCardActions(BuildContext context) {
    final carMap = car.toMap();
    final primary = AppColor.primaryColor(context).withValues(alpha: 0.1);
    final bool isAr = context.locale.languageCode == 'ar';

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: ElevatedButton.icon(
            onPressed: () {
              if (HiveMethods.isGuest()) {
                CommonMethods.showLoginRequiredDialog(context);
                return;
              }
              NavigatorMethods.pushNamed(
                context,
                RoutesName.financingScreen,
                arguments: {'car': car, 'offer': offer, 'offers': financingOffers},
              );
            },
            icon: Icon(
              Icons.calculate_outlined,
              size: 18.sp,
              color: AppColor.primaryColor(context),
            ),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isAr ? 'احسب قسطك' : 'Calculate installment',
                maxLines: 1,
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w800, color: AppColor.primaryColor(context)),
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: primary,
              minimumSize: Size.fromHeight(35.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        Gap(10.w),
        Expanded(
          flex: 4,
          child: ValueListenableBuilder<Box>(
            valueListenable: Hive.box('app').listenable(keys: const ['comparisonList']),
            builder: (context, _, child) {
              final isInCompare = HiveMethods.isInComparison(carMap);
              final green = AppColor.greenColor(context);
              final textColor = AppColor.blackTextColor(context);
              return OutlinedButton.icon(
                onPressed: () {
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
                    CommonMethods.showToast(
                      message: AppLocaleKey.added_to_compare.tr(),
                      type: ToastType.success,
                    );
                  }
                },
                icon: Icon(
                  isInCompare ? Icons.check_circle_rounded : Icons.add_rounded,
                  size: 18.sp,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isAr
                        ? (isInCompare ? 'في المقارنة' : 'أضف للمقارنة')
                        : (isInCompare ? 'In comparison' : 'Add to comparison'),
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isInCompare ? Colors.white : textColor,
                  backgroundColor: isInCompare ? green : Colors.transparent,
                  side: BorderSide(
                    color: isInCompare ? green : AppColor.dividerColor(context),
                    width: 1.2,
                  ),
                  minimumSize: Size.fromHeight(35.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
