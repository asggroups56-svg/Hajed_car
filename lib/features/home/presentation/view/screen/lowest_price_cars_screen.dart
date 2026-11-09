import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/view/widgets/magazine_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LowestPriceCarsScreen extends StatelessWidget {
  const LowestPriceCarsScreen({super.key, required this.cars});

  final List<GetBrandCarsDataModel> cars;

  double _priceOf(GetBrandCarsDataModel car) {
    final value = car.effectivePrice ?? '';
    final normalized = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final sortedCars = List<GetBrandCarsDataModel>.from(cars)
      ..sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: Text(AppLocaleKey.lowestPrice.tr(), style: AppTextStyle.titleMedium(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        itemCount: sortedCars.length,
        separatorBuilder: (_, __) => Gap(16.h),
        itemBuilder: (context, index) {
          final car = sortedCars[index];
          final map = car.toMap();
          final id = HiveMethods.getCarUniqueId(map);
          return MagazineCardWidget(
            car: map,
            heroTag: 'lowest_price_page_${id.isNotEmpty ? id : index}',
          );
        },
      ),
    );
  }
}
