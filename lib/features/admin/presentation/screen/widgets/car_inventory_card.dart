import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/presentation/screen/widgets/card_header_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarStatusConfig {
  final String label;
  final Color bg;
  final Color textColor;
  final Color accent;
  const CarStatusConfig({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.accent,
  });
  static CarStatusConfig of(int status) => switch (status) {
    1 => const CarStatusConfig(
      label: AppLocaleKey.agentCarAvailable,
      bg: Color(0xFFEAF3DE),
      textColor: Color(0xFF3B6D11),
      accent: Color(0xFF639922),
    ),
    0 => const CarStatusConfig(
      label: AppLocaleKey.adminPendingApprovals,
      bg: Color(0xFFFAEEDA),
      textColor: Color(0xFF854F0B),
      accent: Color(0xFFEF9F27),
    ),
    3 => const CarStatusConfig(
      label: AppLocaleKey.agentCarSold,
      bg: Color(0xFFFCEBEB),
      textColor: Color(0xFFA32D2D),
      accent: Color(0xFFE24B4A),
    ),
    4 => const CarStatusConfig(
      label: AppLocaleKey.horizontal,
      bg: Color(0xFFEDE8FA),
      textColor: Color(0xFF4A2D9C),
      accent: Color(0xFF7C5CBF),
    ),
    _ => const CarStatusConfig(
      label: AppLocaleKey.agentCarAvailable,
      bg: Color(0xFFEAF3DE),
      textColor: Color(0xFF3B6D11),
      accent: Color(0xFF639922),
    ),
  };
}

class CarInventoryCard extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final VoidCallback? onEdit;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;

  const CarInventoryCard({
    super.key,
    required this.car,
    this.onEdit,
    this.onWhatsApp,
    this.onDelete,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = CarStatusConfig.of(car.carStatus);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.07)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              car.fullCarImage.isNotEmpty
                  ? CustomNetworkImage(
                      imageUrl: car.fullCarImage,
                      height: 160.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : _ImagePlaceholder(),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: cfg.bg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    cfg.label.tr(),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600, color: cfg.textColor),
                  ),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4.w, color: cfg.accent),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardHeader(car: car, cfg: cfg, showBadge: false),
                        Gap(8.h),
                        _CardMeta(car: car, context: context),
                        Gap(10.h),
                        car.customerName != null
                            ? Text(
                                ' ${AppLocaleKey.customer.tr()}: ${car.customerName ?? ''}',
                                style: AppTextStyle.bodyMedium(context).copyWith(
                                  color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                                ),
                              )
                            : Gap(0),
                        Gap(5.h),
                        car.customerName != null
                            ? Text(
                                ' ${AppLocaleKey.representative.tr()}: ${car.reservedName ?? ''}',
                                style: AppTextStyle.bodyMedium(context).copyWith(
                                  color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                                ),
                              )
                            : Gap(0),
                        Gap(10.h),
                        const Divider(height: 1),
                        Gap(10.h),
                        ValueWithCurrencyIcon(
                          text: ' ${car.formattedPriceWithVat} ${AppLocaleKey.sar.tr()}',
                          textStyle: AppTextStyle.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColor.blackTextColor(context),
                          ),
                        ),
                        // CardFooter(
                        //   car: car,
                        //   context: context,
                        //   onEdit: onEdit,
                        //   onWhatsApp: onWhatsApp,
                        //   onDelete: onDelete,
                        //   onPrint: onPrint,
                        // ),
                      ],
                    ),
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

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      width: double.infinity,
      color: AppColor.blackTextColor(context).withValues(alpha: 0.04),
      child: Icon(
        Icons.directions_car_rounded,
        size: 48.sp,
        color: AppColor.blackTextColor(context).withValues(alpha: 0.12),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final BuildContext context;

  const _CardMeta({required this.car, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaItem(icon: Icons.calendar_today_rounded, text: car.makeYear.toString()),
        Gap(14.w),
        _MetaItem(icon: Icons.speed_rounded, text: car.chassisNo),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColor.blackTextColor(context).withValues(alpha: 0.35)),
        Gap(4.w),
        Text(
          text,
          style: AppTextStyle.bodyMedium(
            context,
          ).copyWith(color: AppColor.blackTextColor(context).withValues(alpha: 0.45)),
        ),
      ],
    );
  }
}

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDanger;

  const ActionBtn({required this.icon, this.onTap, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDanger
                ? AppColor.redColor(context).withValues(alpha: 0.3)
                : AppColor.blackTextColor(context).withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: isDanger
              ? AppColor.redColor(context)
              : AppColor.blackTextColor(context).withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
