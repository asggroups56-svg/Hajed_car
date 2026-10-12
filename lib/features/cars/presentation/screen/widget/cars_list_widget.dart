import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/screen/widget/premium_car_card_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CarsList extends StatelessWidget {
  const CarsList({
    super.key,
    required this.cars,
    this.localizeCarData,
    this.isOffer = false,
    this.offersByItemCode = const {},
    this.normalOffer,
    this.normalOffers = const [],
  });

  final List<GetBrandCarsDataModel> cars;
  final GetBrandCarsDataModel Function(GetBrandCarsDataModel)? localizeCarData;
  final bool isOffer;
  final Map<String, FinancingAdModel> offersByItemCode;
  final FinancingAdModel? normalOffer;
  final List<FinancingAdModel> normalOffers;

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(20),
              Icon(
                Icons.directions_car_outlined,
                size: 80.sp,
                color: AppColor.hintColor(context).withValues(alpha: 0.4),
              ),
              const Gap(12),
              Text(
                AppLocaleKey.noCars.tr(),
                style: AppTextStyle.bodyLarge(
                  context,
                ).copyWith(color: AppColor.blackTextColor(context).withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
      itemCount: cars.length,
      separatorBuilder: (_, __) => Gap(16.h),
      itemBuilder: (context, index) {
        final car = localizeCarData != null ? localizeCarData!(cars[index]) : cars[index];
        final carId = HiveMethods.getCarUniqueId(car.toMap());
        return PremiumCarCardWidget(
          car: car,
          heroTag: 'premium_car_image_${carId.isNotEmpty ? carId : index}_$index',
          isOffer: isOffer,
          offer: (car.itemCode.isNotEmpty ? offersByItemCode[car.itemCode] : null) ?? normalOffer,
          financingOffers: isOffer ? const [] : normalOffers,
        );
      },
    );
  }
}
