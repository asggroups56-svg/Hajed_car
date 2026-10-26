import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/widget/feature_card_widget.dart';
import 'package:car/features/cars/presentation/widget/section_title_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FeaturesGridWidget extends StatelessWidget {
  final GetBrandCarsDataModel car;

  const FeaturesGridWidget({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [];

    final mileage = car.kilometerReading;
    if (mileage != null && mileage.isNotEmpty && mileage != '0') {
      features.add({'icon': Icons.speed_rounded, 'title': AppLocaleKey.km.tr(), 'value': mileage});
    }

    if (car.cylinder.isNotEmpty && car.cylinder != '0') {
      features.add({
        'icon': Icons.settings_rounded,
        'title': AppLocaleKey.cylinders.tr(),
        'value': car.cylinder,
      });
    }

    if (car.seatNo != 0) {
      features.add({
        'icon': Icons.event_seat_rounded,
        'title': AppLocaleKey.seats.tr(),
        'value': '${car.seatNo}',
      });
    }

    if (car.doorNo != 0) {
      features.add({
        'icon': Icons.meeting_room_rounded,
        'title': AppLocaleKey.doors.tr(),
        'value': '${car.doorNo}',
      });
    }

    if (car.fuelCapacity.isNotEmpty && car.fuelCapacity != '0') {
      features.add({
        'icon': Icons.local_gas_station_rounded,
        'title': AppLocaleKey.liter.tr(),
        'value': car.fuelCapacity,
      });
    }

    if (car.powerHourse.isNotEmpty && car.powerHourse != '0') {
      features.add({
        'icon': Icons.bolt_rounded,
        'title': AppLocaleKey.hp.tr(),
        'value': car.powerHourse,
      });
    }

    final specs = car.specificSpecifications;

    if (features.isEmpty && specs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(title: AppLocaleKey.additionalFeatures.tr()),
        Gap(16.h),
        if (features.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final item = features[index];
              return FeatureCard(icon: item['icon'], title: item['title'], value: item['value']);
            },
          ),
        if (specs.isNotEmpty) ...[
          if (features.isNotEmpty) Gap(16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: specs.length,
            separatorBuilder: (_, _) => Gap(10.h),
            itemBuilder: (context, index) {
              final spec = specs[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColor.borderColor(context).withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.blackColor(context).withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColor.primaryColor(context),
                        size: 18.sp,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        spec,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5.sp,
                          color: AppColor.blackTextColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

