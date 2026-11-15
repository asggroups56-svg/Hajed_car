import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_cubit.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_state.dart';
import 'package:car/features/notifications/presentation/view/widget/notification_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final code = HiveMethods.getcode() ?? '';
      final isAgent = HiveMethods.isAgentRole();
      context.read<HomeCubit>().getNotificationsData(
        currentUserId: code,
        userType: isAgent ? 2 : 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        title: Text(
          AppLocaleKey.notifications.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                  child: Text(
                    AppLocaleKey.markAllAsRead.tr(),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) => prev.notificationsStatus != curr.notificationsStatus,
            listener: (context, state) {
              if (state.notificationsStatus.isSuccess) {
                final list = state.notificationsStatus.data ?? [];
                context.read<NotificationsCubit>().loadFromApi(list.map((n) => n.toMap()).toList());
              } else if (state.notificationsStatus.isFailure) {
                context.read<NotificationsCubit>().loadFromApi([]);
              }
            },
          ),
        ],
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                physics: const BouncingScrollPhysics(),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationItemWidget(
                    notification: notification,
                    onTap: () => _openNotification(context, notification),
                  );
                },
              );
            }
            return const Center(child: CustomLoading());
          },
        ),
      ),
    );
  }

  void _openNotification(BuildContext context, Map<String, dynamic> notification) {
    context.read<NotificationsCubit>().markAsRead(notification['id'] as String);
    final type = notification['relatedEntityType'] as int?;
    final id = notification['relatedEntityId'];
    final bool isLoan = notification['isLoan'] as bool? ?? false;

    if (isLoan || type == 77) {
      Navigator.pushNamed(
        context,
        RoutesName.trackOrderScreen,
        arguments: {'orderId': id?.toString()},
      );
      return;
    }

    switch (type) {
      case 20:
      case 34:
      case 40:
        Navigator.pushNamed(context, RoutesName.cartScreen, arguments: {'id': id});
        break;
    }

    if (type == null && notification['type'] == 'reservation') {
      Navigator.pushNamed(context, RoutesName.cartScreen);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: AppColor.secondAppColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              color: AppColor.blackTextColor(context).withValues(alpha: 0.2),
              size: 60.sp,
            ),
          ),
          Gap(24.h),
          Text(
            AppLocaleKey.no_alert.tr(),
            style: AppTextStyle.titleMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
          ),
          Gap(12.h),
          Text(
            AppLocaleKey.no_alert_desc.tr(),
            style: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context).withValues(alpha: 0.4), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
