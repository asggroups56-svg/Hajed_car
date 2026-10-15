import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/presentation/screen/widget/info_card_widget.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReservationSuccessScreen extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final String paymentMethod;
  final String? completedPaymentMethod;

  const ReservationSuccessScreen({
    super.key,
    required this.car,
    required this.paymentMethod,
    this.completedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<FavoritesCubit>().removeFromFavorites(
          car.itemName,
          itemCode: car.itemCode.toString(),
          chassisNo: car.chassisNo,
        );
      } catch (_) {
        HiveMethods.removeFromFavorites(
          car.itemName,
          itemCode: car.itemCode.toString(),
          chassisNo: car.chassisNo,
        );
      }
    });

    final bool isFinancingFlow =
        paymentMethod == 'tamara' || paymentMethod == 'bank';

    final String methodLabel = _paymentMethodLabel(context);

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: Text(
              AppLocaleKey.cancel.tr(),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            Gap(40.h),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00c853).withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: const Color(0xff00c853),
                size: 64.sp,
              ),
            ),
            Gap(32.h),
            Text(
              AppLocaleKey.request_submitted.tr(),
              style: AppTextStyle.titleMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w900, fontSize: 24.sp),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            Text(
              AppLocaleKey.request_submitted_desc.tr(),
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.blackTextColor(context).withValues(alpha: 0.5),
                height: 1.6,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(48.h),
            InfoCardWidget(
              rows: [
                InfoRow(
                  icon: Icons.directions_car_filled_rounded,
                  iconColor: AppColor.primaryColor(context),
                  label: AppLocaleKey.car.tr(),
                  value: car.itemName,
                ),
                InfoRow(
                  icon: Icons.payment_rounded,
                  iconColor: const Color(0xFF3F51B5),
                  label: AppLocaleKey.paymentMethod.tr(),
                  value: methodLabel,
                ),
                if (!isFinancingFlow)
                  InfoRow(
                    icon: Icons.lock_clock_rounded,
                    iconColor: AppColor.iconColor(context),
                    label: AppLocaleKey.deposit_amount.tr(),
                    value: '500 ر.س (غير قابل للاسترداد)',
                  ),
                InfoRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.grey,
                  label: AppLocaleKey.status.tr(),
                  value: AppLocaleKey.under_review.tr(),
                ),
              ],
            ),

            Gap(32.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xffc8e6c9)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: const Color(0xff25D366),
                    size: 28.sp,
                  ),
                  Gap(16.w),
                  Expanded(
                    child: Text(
                      AppLocaleKey.whatsapp_confirmation.tr(),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.greenColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Gap(48.h),
            CustomButton(
              height: 56.h,
              width: double.infinity,
              radius: 14.r,
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Text(
                AppLocaleKey.backToHome.tr(),
                style: AppTextStyle.buttonStyle(
                  context,
                ).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
            Gap(16.h),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Text(
                AppLocaleKey.browse_other_cars.tr(),
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.primaryColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(40.h),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    switch (completedPaymentMethod) {
      case 'mada':
        return isArabic ? 'مدى' : 'Mada';
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'stc_pay':
        return 'STC Pay';
    }

    if (paymentMethod == 'tamara') {
      return isArabic ? 'تمارا' : 'Tamara';
    }
    if (paymentMethod == 'bank') {
      return isArabic ? 'بطاقة الراجحي / الأهلي' : 'Al Rajhi / Al Ahli Card';
    }
    if (paymentMethod == 'moyasar') {
      return isArabic ? 'بطاقة بنكية' : 'Bank Card';
    }
    return isArabic ? 'الكاش' : 'Cash';
  }
}
