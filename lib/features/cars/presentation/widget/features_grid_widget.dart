import 'package:car/core/custom_widgets/additional_specs/additional_specs_section.dart';
import 'package:car/core/localization/app_locale_keys.dart';
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

    if (features.isEmpty) {
      return AdditionalSpecsSection(
        title: AppLocaleKey.additionalFeatures.tr(),
        specs: specs,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(title: AppLocaleKey.additionalFeatures.tr()),
        Gap(16.h),
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
          Gap(20.h),
          AdditionalSpecsSection(
            title: AppLocaleKey.carSpecsNotes.tr(),
            specs: specs,
          ),
        ],
      ],
    );
  }
}

