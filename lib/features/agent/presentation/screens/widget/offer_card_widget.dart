import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:car/features/agent/presentation/screens/widget/meta_chip_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/pill_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});
  final OfferModel offer;

  @override
  Widget build(BuildContext context) {
    final paymentLabel = offer.paymentType?.toUpperCase() == 'CSH'
        ? AppLocaleKey.chs.tr()
        : offer.paymentType ?? AppLocaleKey.noData.tr();

    final initials = offer.customerName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Pill(
                  icon: Icons.receipt_rounded,
                  label: '${AppLocaleKey.show_number.tr()}${offer.listNo}',
                  bgColor: AppColor.primaryColor(context).withValues(alpha: 0.08),
                  borderColor: AppColor.primaryColor(context).withValues(alpha: 0.18),
                  textColor: AppColor.primaryColor(context),
                  iconColor: AppColor.primaryColor(context),
                ),
                Pill(
                  icon: Icons.calendar_today_rounded,
                  label: offer.listDate.toString(),
                  bgColor: AppColor.scaffoldColor(context),
                  borderColor: AppColor.borderColor(context).withValues(alpha: 0.15),
                  textColor: AppColor.greyColor(context),
                  iconColor: AppColor.greyColor(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(height: 1, color: AppColor.borderColor(context).withValues(alpha: 0.12)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColor.primaryColor(context).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocaleKey.customer.tr(),
                        style: AppTextStyle.bodySmall(
                          context,
                        ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                      ),
                      Gap(2.h),
                      Text(
                        offer.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyLarge(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: MetaChip(
                    icon: Icons.badge_outlined,
                    iconColor: AppColor.orangeColor(context),
                    label: '${AppLocaleKey.agent.tr()} ${offer.represName}',
                  ),
                ),
                Gap(8.w),
                Expanded(
                  child: MetaChip(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColor.redColor(context),
                    label: '${AppLocaleKey.agent_area.tr()} ${offer.areaName}',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: MetaChip(
              icon: Icons.payment_rounded,
              iconColor: AppColor.greenColor(context),
              label: '${AppLocaleKey.payment.tr()} $paymentLabel',
              fullWidth: true,
            ),
          ),
          if (offer.notes != null && offer.notes!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColor.scaffoldColor(context),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColor.blueColor(context),
                      size: 14.sp,
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Text(
                        offer.notes!,
                        style: AppTextStyle.bodySmall(
                          context,
                        ).copyWith(color: AppColor.greyColor(context), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColor.greenColor(context).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColor.greenColor(context).withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocaleKey.total.tr(),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.w600),
                  ),
                  ValueWithCurrencyIcon(
                    text:
                        '${NumberFormat.decimalPattern().format(offer.total)} ${AppLocaleKey.sar.tr()}',
                    textStyle: AppTextStyle.titleLarge(context).copyWith(
                      color: AppColor.greenColor(context),
                      fontWeight: FontWeight.w900,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range_rounded, color: AppColor.greyColor(context), size: 13.sp),
                    Gap(5.w),
                    Text(
                      '${AppLocaleKey.agent_from.tr()} ${offer.begDate}  ${AppLocaleKey.agent_to.tr()} ${offer.endDate}',
                      style: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                    ),
                  ],
                ),
                // if (offer.deliveryPeriod != null)
                //   Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                //     decoration: BoxDecoration(
                //       color: AppColor.primaryColor(context).withValues(alpha: 0.08),
                //       borderRadius: BorderRadius.circular(6.r),
                //     ),
                //     child: Text(
                //       '${AppLocaleKey.agent_delivery.tr()} ${offer.deliveryPeriod}',
                //       style: AppTextStyle.bodySmall(context).copyWith(
                //         color: AppColor.primaryColor(context),
                //         fontWeight: FontWeight.w600,
                //         fontSize: 11.sp,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
