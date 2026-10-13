import 'dart:async';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:car/features/cart/presentation/view/widget/cancel_confirm_dialog_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CartItemWidget extends StatefulWidget {
  final CarModel car;
  const CartItemWidget({super.key, required this.car});
  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isCancelling = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTime());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTime());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTime() {
    if (!mounted) return;

    final DateTime? expiry = context.read<CartCubit>().expiryTimeFor(widget.car.itemCode);

    if (expiry == null) {
      setState(() => _remainingTime = Duration.zero);
      return;
    }
    final Duration diff = expiry.difference(DateTime.now());
    setState(() => _remainingTime = diff.isNegative ? Duration.zero : diff);
  }

  Future<void> _onDeleteTapped() async {
    final cubit = context.read<CartCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CancelConfirmDialog(carName: widget.car.itemName ?? ''),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isCancelling = true);
    try {
      await cubit.cancelReservation(widget.car);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String carName = widget.car.itemName ?? '';
    final double priceWithVat = widget.car.costPrice ?? 0;
    final double vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final double price = priceWithVat * (1 + vatPercentage / 100);
    final String lpoNo = widget.car.lpoNo ?? '';
    final bool isAboutToExpire =
        _remainingTime > Duration.zero && _remainingTime <= const Duration(hours: 1);
    final String priceFormatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic)),
        child: Container(
          margin: EdgeInsets.only(bottom: 18.h),
          decoration: BoxDecoration(
            color: AppColor.secondAppColor(context),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColor.borderColor(context).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor(context).withValues(alpha: 0.04),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Big & Clear Image Showcase ───────────────────
                Container(
                  width: double.infinity,
                  height: 175.h,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(context).withValues(alpha: 0.03),
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primaryColor(context).withValues(alpha: 0.05),
                        AppColor.primaryColor(context).withValues(alpha: 0.01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Car Image
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          child: widget.car.imageUrls.isNotEmpty
                              ? CustomNetworkImage(
                                  imageUrl: widget.car.imageUrls.first,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car_filled_rounded,
                                      size: 56.sp,
                                      color: AppColor.primaryColor(context).withValues(alpha: 0.2),
                                    ),
                                    Gap(6.h),
                                    Text(
                                      carName,
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        color: AppColor.blackTextColor(
                                          context,
                                        ).withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // Top-Start: Active Status Badge
                      PositionedDirectional(
                        top: 12.h,
                        start: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColor.secondAppColor(context).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColor.primaryColor(context).withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.shade500,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Gap(6.w),
                              Text(
                                AppLocaleKey.active.tr(),
                                style: AppTextStyle.bodySmall(context).copyWith(
                                  color: AppColor.blackTextColor(context),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top-End: Make Year Badge (if available)
                      if (widget.car.makeYear != null && widget.car.makeYear! > 0)
                        PositionedDirectional(
                          top: 12.h,
                          end: 12.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColor.secondAppColor(context).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColor.borderColor(context).withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11.sp,
                                  color: AppColor.primaryColor(context),
                                ),
                                Gap(4.w),
                                Text(
                                  '${widget.car.makeYear}',
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: AppColor.blackTextColor(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ─── Car Details Section ──────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car Name Title
                      Text(
                        carName,
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 17.sp,
                          color: AppColor.blackTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Gap(10.h),

                      // Specs & Chips (Chassis, Fuel Type, LPO)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          if (widget.car.chassisNo != null && widget.car.chassisNo!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColor.primaryColor(context).withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 13.sp,
                                    color: AppColor.primaryColor(context),
                                  ),
                                  Gap(5.w),
                                  Text(
                                    widget.car.chassisNo!,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: AppColor.primaryColor(context),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (lpoNo.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColor.borderColor(context).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    size: 13.sp,
                                    color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                                  ),
                                  Gap(5.w),
                                  Text(
                                    '${AppLocaleKey.reservationNumber.tr()} $lpoNo',
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: AppColor.blackTextColor(
                                        context,
                                      ).withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (widget.car.fuelType != null && widget.car.fuelType!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_gas_station_rounded,
                                    size: 13.sp,
                                    color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                                  ),
                                  Gap(5.w),
                                  Text(
                                    widget.car.fuelType!,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: AppColor.blackTextColor(
                                        context,
                                      ).withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      Gap(12.h),

                      // Price Display
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          ValueWithCurrencyIcon(
                            text: '$priceFormatted  ${AppLocaleKey.sar.tr()}',
                            textStyle: AppTextStyle.titleLarge(context).copyWith(
                              color: AppColor.primaryColor(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 19.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Divider ──────────────────────────────────────
                Container(
                  height: 1,
                  color: AppColor.borderColor(context).withValues(alpha: 0.35),
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                ),

                // ─── Bottom Action & Timer Bar ────────────────────
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.015),
                  ),
                  child: Row(
                    children: [
                      // Timer Box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: isAboutToExpire
                                    ? Colors.orange.withValues(alpha: 0.12)
                                    : _remainingTime <= const Duration(seconds: 30)
                                    ? AppColor.redColor(context).withValues(alpha: 0.1)
                                    : AppColor.primaryColor(context).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isAboutToExpire
                                      ? Colors.orange.withValues(alpha: 0.35)
                                      : _remainingTime <= const Duration(seconds: 30)
                                      ? AppColor.redColor(context).withValues(alpha: 0.3)
                                      : AppColor.primaryColor(context).withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAboutToExpire
                                        ? Icons.alarm_rounded
                                        : Icons.access_time_filled_rounded,
                                    size: 15.sp,
                                    color: isAboutToExpire
                                        ? Colors.orange.shade800
                                        : _remainingTime <= const Duration(seconds: 30)
                                        ? AppColor.redColor(context)
                                        : AppColor.primaryColor(context),
                                  ),
                                  Gap(6.w),
                                  Text(
                                    '${_remainingTime.inHours.toString().padLeft(2, '0')}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: isAboutToExpire
                                          ? Colors.orange.shade900
                                          : _remainingTime <= const Duration(seconds: 30)
                                          ? AppColor.redColor(context)
                                          : AppColor.primaryColor(context),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAboutToExpire)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 12.sp,
                                      color: Colors.orange.shade800,
                                    ),
                                    Gap(3.w),
                                    Text(
                                      AppLocaleKey.cancelReservationAboutToExpire.tr(),
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Cancel Reservation Action
                      InkWell(
                        onTap: _isCancelling ? null : _onDeleteTapped,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColor.redColor(context).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColor.redColor(context).withValues(alpha: 0.2),
                            ),
                          ),
                          child: _isCancelling
                              ? SizedBox(
                                  width: 16.sp,
                                  height: 16.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(AppColor.redColor(context)),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16.sp,
                                      color: AppColor.redColor(context),
                                    ),
                                    Gap(6.w),
                                    Text(
                                      AppLocaleKey.cancelReservation.tr(),
                                      style: AppTextStyle.bodySmall(context).copyWith(
                                        color: AppColor.redColor(context),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
