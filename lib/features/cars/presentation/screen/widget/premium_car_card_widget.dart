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
    final String rawColor = (car.bodyColor.isNotEmpty && car.bodyColor.toLowerCase() != 'null'
        ? car.bodyColor
        : (car.color.isNotEmpty && car.color.toLowerCase() != 'null' ? car.color : '')).trim();
    final String displayColor = rawColor.isNotEmpty ? rawColor : '—';
    final String displayYear = car.makeYear > 0 ? '${car.makeYear}' : '—';
    final String displayMileage = (car.kilometerReading != null &&
            car.kilometerReading!.isNotEmpty &&
            car.kilometerReading != 'null' &&
            car.kilometerReading != '0')
        ? '${car.kilometerReading} كم'
        : (car.kilometerReading == '0' ? '0 كم' : '—');

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
                  tag: heroTag ?? 'car_image_${car.itemCode}',
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
                              : AppImages.assetsImagesCar,
                          fit: BoxFit.fill,
                          height: 150.h,
                          width: double.infinity,
                        ),
                ),

                Positioned(
                  top: 10.h,
                  left: -5.w,
                  child: Container(
                    height: 25.h,
                    width: 60.w,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 15.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColor.blackColor(context).withValues(alpha: 0.1),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      car.makeYear.toString(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blackTextColor(context),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Row(
                    children: [
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final isFav = context.read<FavoritesCubit>().isFavorite(car.itemName);
                          return Container(
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: AppColor.blackColor(context).withValues(alpha: 0.1),
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
                                        style: AppTextStyle.titleMedium(context).copyWith(
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
                              const Spacer(),
                              Text(
                                AppLocaleKey.agentIncludesVat.tr(),
                                style: AppTextStyle.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        if (isOffer ||
                            (offer != null) ||
                            financingOffers.isNotEmpty ||
                            car.hasFinancing ||
                            (car.price != null && car.price!.isNotEmpty && car.price != '0')) ...[
                          VerticalDivider(color: AppColor.greyColor(context), width: 32.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
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
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Gap(12.h),
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
                          icon: Icons.speed_outlined,
                          label: displayMileage,
                        ),
                      ),
                      Gap(6.w),
                      Expanded(
                        child: MiniDetailWidget(
                          customIcon: _buildColorIcon(context, displayColor),
                          label: displayColor,
                        ),
                      ),
                      Gap(6.w),
                      _buildCompareButton(context),
                    ],
                  ),
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

      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(Icons.color_lens_rounded, size: 15.w, color: Colors.white),
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

  Widget _buildCompareButton(BuildContext context) {
    final carMap = car.toMap();
    final isInCompare = HiveMethods.isInComparison(carMap);

    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColor.blackTextColor(context).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (HiveMethods.isInComparison(carMap)) {
            HiveMethods.removeFromComparison(carMap);
            (context as Element).markNeedsBuild();
          } else {
            bool added = HiveMethods.addToComparison(carMap);
            if (added) {
              (context as Element).markNeedsBuild();
            } else {
              CommonMethods.showToast(
                message: AppLocaleKey.compare_list_full.tr(),
                type: ToastType.error,
              );
            }
          }
        },
        icon: Icon(
          isInCompare ? Icons.compare_arrows_rounded : Icons.add_chart_rounded,
          color: isInCompare
              ? AppColor.primaryColor(context)
              : AppColor.blackTextColor(context),
          size: 18.sp,
        ),
      ),
    );
  }
}
