import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_cubit.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationIconWidget extends StatelessWidget {
  const NotificationIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final int unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 35.h,
              width: 35.h,
              decoration: BoxDecoration(
                color: AppColor.whiteColor(context),
                borderRadius: BorderRadius.circular(10.r),
                shape: BoxShape.rectangle,
                border: Border.all(color: AppColor.blackTextColor(context).withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackTextColor(context).withValues(alpha: (0.1)),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, RoutesName.notificationsScreen),
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColor.blackTextColor(context),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColor.redColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: AppTextStyle.titleMedium(context).copyWith(
                      color: AppColor.whiteColor(context),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
