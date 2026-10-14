import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/presentation/screens/widget/small_action_btn_widget.dart';
import 'package:car/features/notifications/data/model/notification_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SliderNotifCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const SliderNotifCard({
    super.key,
    required this.notification,
    required this.onApprove,
    required this.onReject,
  });

  String _formatDate(String value) {
    if (value.trim().isEmpty) return '';
    final dt = DateTime.tryParse(value);
    if (dt != null) {
      return DateFormat('yyyy-MM-dd', 'en').format(dt);
    }
    if (value.contains('T')) return value.split('T').first;
    if (value.contains(' ')) return value.split(' ').first;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColor.cardColor(context);
    final blue = AppColor.blueColor(context);
    final green = AppColor.greenColor(context);
    final red = AppColor.redColor(context);

    // card width = ~75% screen width so 3 cards are partially visible
    final cardWidth = (MediaQuery.of(context).size.width - 32.w) * 0.78;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.dividerColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + title + date ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(Icons.notifications_active_rounded, color: blue, size: 18.sp),
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColor.blackTextColor(context),
                          fontSize: 13.sp,
                        ),
                      ),
                      Gap(2.h),
                      Text(
                        _formatDate(notification.createdAt),
                        style: AppTextStyle.bodySmall(
                          context,
                        ).copyWith(color: AppColor.greyColor(context), fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Gap(10.h),

            // ── Body ──
            Expanded(
              child: Text(
                notification.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall(
                  context,
                ).copyWith(color: AppColor.darkTextColor(context), height: 1.5, fontSize: 12.sp),
              ),
            ),

            if (!notification.isCancellation) ...[
              Gap(12.h),
              Row(
                children: [
                  Expanded(
                    child: SmallActionBtn(
                      label: AppLocaleKey.approve.tr(),
                      icon: Icons.check_rounded,
                      color: green,
                      onTap: onApprove,
                    ),
                  ),
                  if (notification.isLoan) ...[
                    Gap(8.w),
                    Expanded(
                      child: SmallActionBtn(
                        label: AppLocaleKey.reject.tr(),
                        icon: Icons.close_rounded,
                        color: red,
                        isOutlined: true,
                        onTap: onReject,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
