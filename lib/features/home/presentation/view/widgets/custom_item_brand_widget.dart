import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomItemBrandWidget extends StatelessWidget {
  const CustomItemBrandWidget({super.key, required this.brand});
  final CarModel brand;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<HomeCubit>().getBrandCars(brand.groupCode.toString());
        Navigator.pushNamed(context, RoutesName.popularCarsScreen);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        color: AppColor.whiteColor(context),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.greyColor(context).withValues(alpha: (0.05)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomNetworkImage(
                      imageUrl:
                          "${Constants.baseImage}${brand.picturePath.replaceAll('../../Img/Emp/', '')}",
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            // Name
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
              child: Text(
                context.locale.languageCode == 'ar'
                    ? brand.groupName
                    : brand.groupEName ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w600, color: AppColor.blackColor(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
