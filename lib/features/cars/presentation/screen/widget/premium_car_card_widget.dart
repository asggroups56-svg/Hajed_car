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
import 'package:car/features/home/presentation/view/widgets/mini_detail_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final String rawColor =
        (car.bodyColor.isNotEmpty && car.bodyColor.toLowerCase() != 'null'
                ? car.bodyColor
                : (car.color.isNotEmpty && car.color.toLowerCase() != 'null' ? car.color : ''))
            .trim();
    final String displayColor = rawColor.isNotEmpty ? rawColor : '—';
    final String displayYear = car.makeYear > 0 ? '${car.makeYear}' : '—';


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
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTag ?? 'car_image_${HiveMethods.getCarUniqueId(car.toMap())}',
                  child: car.fullCarImage.isNotEmpty && car.fullCarImage.startsWith('http')
                      ? CustomNetworkImage(
                          imageUrl: car.fullCarImage,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: 150.h,
                        )
                      : Image.asset(
                          car.fullCarImage.isNotEmpty
                              ? car.fullCarImage
                              : AppImages.assetsImagesLogeStatic,
                          fit: BoxFit.fill,
                          height: 150.h,
                          width: double.infinity,
                        ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Row(
                    children: [
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final isFav = context.read<FavoritesCubit>().isFavorite(car.toMap());
                          return Container(
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor(context),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<FavoritesCubit>().toggleFavorite(car.toMap());
                              },
                              icon: Icon(
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
                    ],
                  ),
                ),
                if (isOffer && car.interestRate != null)
                  Positioned(
                    left: 70.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${car.interestRate}% ',
                            style: AppTextStyle.bodySmall(context).copyWith(
                              color: AppColor.whiteColor(context),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            context.locale.languageCode == 'ar' ? 'عرض' : 'Offer',
                            style: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(color: AppColor.whiteColor(context), fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.itemName,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Gap(10.w),
                  // The car details stay together above the prices, as in the
                  // supplied card reference. This makes the cash and monthly
                  // installment amounts easy to compare at a glance.
                  Row(
                    children: [
                      Expanded(
                        child: MiniDetailWidget(
                          icon: Icons.calendar_today_outlined,
                          label: displayYear,
                        ),
                      ),

                      Gap(6.w),
                      Expanded(
                        child: MiniDetailWidget(
                          customIcon: _buildColorIcon(context, displayColor),
                          label: displayColor,
                        ),
                      ),
                    ],
                  ),
                  Gap(10.h),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOffer ? AppLocaleKey.price.tr() : AppLocaleKey.cash.tr(),
                                style: AppTextStyle.bodySmall(context).copyWith(
                                  color: AppColor.blackTextColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gap(6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        car.formattedPriceWithVat,
                                        style: AppTextStyle.bodyMedium(context).copyWith(
                                          color: AppColor.greenColor(context),
                                          fontWeight: FontWeight.w900,
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
                              Gap(4.h),
                            ],
                          ),
                        ),

                        if (isOffer ||
                            (offer != null) ||
                            financingOffers.isNotEmpty ||
                            car.hasFinancing ||
                            (car.price != null && car.price!.isNotEmpty && car.price != '0')) ...[
                          //  VerticalDivider(color: AppColor.greyColor(context), width: 32.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (HiveMethods.isGuest()) return;

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
                  Gap(5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14.sp,
                        color: AppColor.greyColor(context),
                      ),
                      Gap(4.w),
                      Text(
                        AppLocaleKey.agentIncludesVat.tr(),
                        style: AppTextStyle.bodySmall(context),
                      ),
                    ],
                  ),
                  Divider(color: AppColor.greyColor(context), height: 24.h),
                  Gap(10.h),
                  _buildCardActions(context),
                ],
              ),
            ),
          ],
        ),
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

      return Container(
        width: 13.w,
        height: 13.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: gradientColors),
          border: Border.all(
            color: AppColor.blackTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }

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

    return Icon(Icons.palette_outlined, color: AppColor.greyColor(context), size: 14.w);
  }

  Widget _buildCardActions(BuildContext context) {
    final carMap = car.toMap();
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => NavigatorMethods.pushNamed(
              context,
              RoutesName.financingScreen,
              arguments: {'car': car},
            ),
            icon: Icon(Icons.calculate_outlined, size: 18.sp),
            label: Text(
              context.locale.languageCode == 'ar' ? 'احسب قسطك' : 'Calculate installment',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primaryColor(context),
              backgroundColor: AppColor.primaryColor(context).withValues(alpha: 0.15),

              minimumSize: Size.fromHeight(38.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
        Gap(10.w),
        Expanded(
          child: ValueListenableBuilder<Box>(
            valueListenable: Hive.box('app').listenable(keys: const ['comparisonList']),
            builder: (context, _, child) {
              final isInCompare = HiveMethods.isInComparison(carMap);
              final color = isInCompare
                  ? AppColor.greenColor(context)
                  : AppColor.whiteColor(context);
              final textColor = isInCompare
                  ? AppColor.whiteColor(context)
                  : AppColor.blackColor(context);
              return ElevatedButton.icon(
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
                icon: Icon(isInCompare ? Icons.check_circle_rounded : Icons.add, size: 18.sp),
                label: Text(
                  context.locale.languageCode == 'ar'
                      ? (isInCompare ? 'في المقارنة' : 'أضف للمقارنة')
                      : (isInCompare ? 'In comparison' : 'Add to comparison'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: textColor,
                  minimumSize: Size.fromHeight(38.h),
                  side: BorderSide(color: AppColor.greyColor(context), width: .2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
