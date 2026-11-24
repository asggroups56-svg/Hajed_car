import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/deep_link_service.dart';
import 'package:car/core/services/notification_service.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:car/features/agent/data/model/customer_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/screens/widget/custom_agent_car_details_info_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/customer_dropdown_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/icon_btn_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/quote_builder_dialog.dart';
import 'package:car/features/cars/presentation/widget/reservation_terms_checkbox_widget.dart';
import 'package:car/features/home/data/model/add_booking_permission_model.dart';
import 'package:car/features/home/data/model/send_whatsapp_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class AgentCarDetailsScreen extends StatefulWidget {
  final AgentCar car;
  const AgentCarDetailsScreen({super.key, required this.car});
  @override
  State<AgentCarDetailsScreen> createState() => _AgentCarDetailsScreenState();
}

class _AgentCarDetailsScreenState extends State<AgentCarDetailsScreen> {
  bool _isLoading = false;

  /// Customer details captured when the representative confirms the
  /// reservation, kept until the booking response returns so the WhatsApp
  /// message can be sent to the right number.
  String? _pendingCustomerPhone;
  double _pendingDeposit = 0;
  int _pendingReservationType = 0; // 0: فرد, 1: معرض, 2: بنك

  void _sendBookingWhatsApp(String bookingNo) {
    final phone = _pendingCustomerPhone?.trim();
    if (phone == null || phone.isEmpty) return;
    _pendingCustomerPhone = null;

    final String textMsg;
    if (_pendingReservationType == 1 || _pendingReservationType == 2) {
      // حجز بنك أو معرض: حذف المبلغ الإجمالي والعربون وعرض سنة الصنع واللون
      final carColor = (widget.car.color.isNotEmpty && widget.car.color != '—')
          ? widget.car.color
          : (widget.car.bodyColor.isNotEmpty && widget.car.bodyColor != '—'
                ? widget.car.bodyColor
                : (widget.car.colorCode?.isNotEmpty == true ? widget.car.colorCode! : '—'));

      final carYear = (widget.car.year.isNotEmpty && widget.car.year != '—')
          ? widget.car.year
          : '—';

      textMsg =
          'حجز سيارة: ${widget.car.itemName}\n'
          'رقم الحجز: ${bookingNo.isNotEmpty ? bookingNo : ''}\n'
          'رقم السيارة: ${widget.car.itemCode}\n'
          'سنة الصنع: $carYear\n'
          'اللون: $carColor\n';
    } else {
      // حجز أفراد: عرض المبلغ الإجمالي والعربون
      final money = NumberFormat('#,##0', 'en_US');
      textMsg =
          'حجز سيارة: ${widget.car.itemName}\n'
          'رقم الحجز: ${bookingNo.isNotEmpty ? bookingNo : ''}\n'
          'رقم السيارة: ${widget.car.itemCode}\n'
          'المبلغ الإجمالي: ${money.format(widget.car.priceWithVat)} ر.س\n'
          'العربون: ${money.format(_pendingDeposit)} ر.س\n';
    }

    context.read<HomeCubit>().sendWhatsApp(SendWhatsAppModel(toNumber: phone, text: textMsg));
  }

  @override
  Widget build(BuildContext context) {
    final availabilityColor = widget.car.getAvailabilityColor(context);
    final isArabic = context.locale.languageCode == 'ar';

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.addBookingPermissionResponseModel != current.addBookingPermissionResponseModel,
      listener: (context, state) {
        final status = state.addBookingPermissionResponseModel;
        if (status.isSuccess && status.data?.success == true) {
          setState(() => _isLoading = false);
          // The booking is complete: notify the customer on WhatsApp, then
          // leave the screen.
          _sendBookingWhatsApp(status.data?.lpoNo ?? '');
          NotificationService.showReservationCreatedNotification(carName: widget.car.itemName);
          final msg = status.data?.msg ?? (isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully');
          CommonMethods.showToast(message: msg, type: ToastType.success);
          Navigator.pop(context);
        } else if (status.isSuccess && (status.data == null || status.data?.success == false)) {
          setState(() => _isLoading = false);
          CommonMethods.showToast(
            message:
                status.data?.msg ??
                (isArabic
                    ? 'فشل الحجز، يرجى المحاولة مجدداً'
                    : 'Reservation failed. Please try again.'),
            type: ToastType.error,
          );
        } else if (status.isFailure) {
          setState(() => _isLoading = false);
          CommonMethods.showToast(
            message:
                status.error ??
                (isArabic ? 'حدث خطأ أثناء حفظ الحجز' : 'Error occurred while saving reservation'),
            type: ToastType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        bottomNavigationBar: widget.car.availability == CarAvailability.available
            ? Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.blackColor(context).withValues(alpha: .04),
                      blurRadius: 20,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: CustomButton(
                  onPressed: (widget.car.availability == CarAvailability.available && !_isLoading)
                      ? () {
                          _showReserveDialog();
                        }
                      : null,
                  radius: 14.r,
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.whiteColor(context),
                          ),
                        )
                      : Text(
                          AppLocaleKey.agentReserveForCustomer.tr(),
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            color: AppColor.whiteColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              )
            : null,

        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 340.h,
                backgroundColor: AppColor.appBarColor(context),
                elevation: 0,
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: IconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                actions: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: IconBtn(
                      icon: Icons.share_outlined,
                      onTap: () => DeepLinkService.shareAgentCar(widget.car),
                    ),
                  ),
                  if (widget.car.availability == CarAvailability.available)
                    TextButton(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          AppLocaleKey.create_quotation.tr(),
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final success = await QuoteBuilderDialog.show(
                          context,
                          car: widget.car.toCarModel(),
                          existingSpecs: {
                            if (widget.car.luxury != null && widget.car.luxury!.trim().isNotEmpty)
                              (isArabic ? 'المواصفات' : 'Luxury'): widget.car.luxury!.trim(),
                            if (widget.car.specificName != null &&
                                widget.car.specificName!.trim().isNotEmpty)
                              (isArabic ? 'المواصفات' : 'Specifications'): widget.car.specificName!
                                  .trim(),
                            if (widget.car.luxury != null && widget.car.luxury!.trim().isNotEmpty)
                              (isArabic ? 'درجة الفخامة' : 'Luxury'): widget.car.luxury!.trim(),
                            if (widget.car.specificName != null &&
                                widget.car.specificName!.trim().isNotEmpty)
                              (isArabic ? 'المواصفات' : 'Specifications'): widget.car.specificName!
                                  .trim(),
                          },
                        );
                        if (success == true && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.car.imageUrl.trim().isNotEmpty
                          ? CustomNetworkImage(
                              imageUrl: widget.car.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColor.blueColor(context).withValues(alpha: .08),
                              child: Icon(
                                Icons.directions_car_filled_rounded,
                                size: 150.sp,
                                color: AppColor.blueColor(context).withValues(alpha: .25),
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColor.blackColor(context).withValues(alpha: .75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20.w,
                        right: 20.w,
                        bottom: 30.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: availabilityColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                widget.car.availabilityLabel,
                                style: AppTextStyle.bodySmall(context).copyWith(
                                  color: AppColor.whiteColor(context),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                            Gap(12.h),

                            Text(
                              widget.car.brand,
                              style: AppTextStyle.bodyMedium(
                                context,
                              ).copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
                            ),

                            Gap(4.h),

                            Text(
                              widget.car.name,
                              style: AppTextStyle.titleLarge(context).copyWith(
                                color: AppColor.whiteColor(context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            Gap(12.h),

                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.w,
                              runSpacing: 4.h,
                              children: [
                                ValueWithCurrencyIcon(
                                  text:
                                      '${NumberFormat('#,##0', 'en_US').format(widget.car.priceWithVat)} ${AppLocaleKey.sar.tr()}',
                                  textStyle: AppTextStyle.titleLarge(context).copyWith(
                                    color: AppColor.whiteColor(context),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor(context).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: AppColor.whiteColor(context).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    isArabic ? 'شامل الضريبة واللوحات' : 'Inc. VAT & Plates',
                                    style: TextStyle(
                                      color: AppColor.whiteColor(context),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CustomAgentCarDetailsInfoWidget(car: widget.car),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReserveDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final depositController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    final searchController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isArabic = context.locale.languageCode == 'ar';
    CustomerModel? selectedCustomer;
    bool isCustomerDropdownOpen = false;
    bool isTermsAccepted = false;
    int reservationType = 0; // 0: فرد (١٢ ساعة), 1: معرض (١٢ ساعة), 2: بنك (٣ أيام)
    context.read<AgentCubit>().getCustomer(null);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<AgentCubit>(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              Widget buildTab(String title, int typeIndex) {
                final isSelected = reservationType == typeIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setModalState(() => reservationType = typeIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor(dialogContext)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColor.primaryColor(
                                    dialogContext,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodySmall(dialogContext).copyWith(
                              color: isSelected
                                  ? AppColor.whiteColor(dialogContext)
                                  : AppColor.blackTextColor(dialogContext).withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final Color infoBoxBg;
              final Color infoBoxBorder;
              final Color infoBoxText;
              final String durationInfoText;

              if (reservationType == 2) {
                infoBoxBg = const Color(0xFF3B82F6).withValues(alpha: 0.08);
                infoBoxBorder = const Color(0xFF3B82F6).withValues(alpha: 0.25);
                infoBoxText = const Color(0xFF1E40AF);
                durationInfoText = isArabic
                    ? 'مدة حجز عملاء البنوك: ٣ أيام'
                    : 'Bank Reservation Duration: 3 Days';
              } else if (reservationType == 1) {
                infoBoxBg = const Color(0xFF8B5CF6).withValues(alpha: 0.08);
                infoBoxBorder = const Color(0xFF8B5CF6).withValues(alpha: 0.25);
                infoBoxText = const Color(0xFF5B21B6);
                durationInfoText = isArabic
                    ? 'مدة حجز المعارض: ١٢ ساعة'
                    : 'Showroom Reservation Duration: 12 Hours';
              } else {
                infoBoxBg = const Color(0xFFF59E0B).withValues(alpha: 0.08);
                infoBoxBorder = const Color(0xFFF59E0B).withValues(alpha: 0.25);
                infoBoxText = const Color(0xFF92400E);
                durationInfoText = isArabic
                    ? 'مدة حجز الأفراد: ١٢ ساعة'
                    : 'Individual Reservation Duration: 12 Hours';
              }

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 0.85.sh),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor(
                                        dialogContext,
                                      ).withValues(alpha: .1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.bookmark_add_rounded,
                                      color: AppColor.primaryColor(dialogContext),
                                      size: 24.sp,
                                    ),
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Text(
                                      isArabic ? 'حجز سيارة للعميل' : 'Reserve Car for Customer',
                                      style: AppTextStyle.titleMedium(dialogContext).copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.blackTextColor(dialogContext),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(20.h),
                              const Divider(height: 1),
                              Gap(20.h),
                              CustomerDropdown(
                                selected: selectedCustomer,
                                isOpen: isCustomerDropdownOpen,
                                searchController: searchController,
                                onToggle: () => setModalState(() {
                                  isCustomerDropdownOpen = !isCustomerDropdownOpen;
                                }),
                                onSelect: (CustomerModel c) {
                                  setModalState(() {
                                    selectedCustomer = c;
                                    isCustomerDropdownOpen = false;
                                    nameController.text = c.customerName ?? '';
                                    phoneController.text = c.tel1 ?? '';
                                    final custNameLower = (c.customerName ?? '').toLowerCase();
                                    final typeLower = (c.customerTypeName ?? '').toLowerCase();
                                    if (custNameLower.contains('معرض') ||
                                        custNameLower.contains('معارض') ||
                                        custNameLower.contains('showroom') ||
                                        typeLower.contains('معرض') ||
                                        typeLower.contains('معارض') ||
                                        typeLower.contains('showroom')) {
                                      reservationType = 1;
                                    } else if (custNameLower.contains('بنك') ||
                                        custNameLower.contains('bank') ||
                                        custNameLower.contains('تمويل') ||
                                        typeLower.contains('بنك') ||
                                        typeLower.contains('bank') ||
                                        typeLower.contains('تمويل')) {
                                      reservationType = 2;
                                    } else {
                                      reservationType = 0;
                                    }
                                    searchController.clear();
                                    context.read<AgentCubit>().getCustomer(null);
                                  });
                                },
                                onSearch: (v) =>
                                    context.read<AgentCubit>().getCustomer(v.isEmpty ? null : v),
                                context: dialogContext,
                              ),
                              Gap(16.h),
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColor.scaffoldColor(dialogContext),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: AppColor.borderColor(
                                      dialogContext,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    buildTab(isArabic ? 'فرد (١٢ ساعة)' : 'Individual (12h)', 0),
                                    Gap(4.w),
                                    buildTab(isArabic ? 'معرض (١٢ ساعة)' : 'Showroom (12h)', 1),
                                    Gap(4.w),
                                    buildTab(isArabic ? 'بنك (٣ أيام)' : 'Bank (3 Days)', 2),
                                  ],
                                ),
                              ),
                              Gap(12.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: infoBoxBg,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: infoBoxBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 18.sp, color: infoBoxText),
                                    Gap(8.w),
                                    Expanded(
                                      child: Text(
                                        durationInfoText,
                                        style: AppTextStyle.bodySmall(dialogContext).copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5.sp,
                                          color: infoBoxText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(16.h),
                              CustomFormField(
                                controller: nameController,
                                hintText: isArabic
                                    ? 'الاسم بالكامل للعميل / المندوب'
                                    : 'Customer / Representative Name',
                                radius: 12.r,
                                keyboardType: TextInputType.name,
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColor.hintColor(dialogContext),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return isArabic
                                        ? 'برجاء إدخال اسم العميل أو المندوب'
                                        : 'Please enter name';
                                  }
                                  return null;
                                },
                              ),
                              Gap(16.h),
                              CustomFormField(
                                controller: phoneController,
                                hintText: isArabic ? 'رقم جوال العميل' : 'Customer Phone Number',
                                radius: 12.r,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                prefixIcon: Icon(
                                  Icons.phone_android_rounded,
                                  color: AppColor.hintColor(dialogContext),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return isArabic
                                        ? 'برجاء إدخال رقم الجوال'
                                        : 'Please enter phone number';
                                  }
                                  if (value.trim().length < 10) {
                                    return isArabic
                                        ? 'رقم الجوال يجب أن يكون 10 أرقام'
                                        : 'Phone number must be 10 digits';
                                  }
                                  return null;
                                },
                              ),
                              Gap(16.h),
                              CustomFormField(
                                controller: depositController,
                                hintText: isArabic
                                    ? 'مبلغ العربون (اختياري)'
                                    : 'Deposit Amount (Optional)',
                                radius: 12.r,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icon(
                                  Icons.payments_outlined,
                                  color: AppColor.hintColor(dialogContext),
                                ),
                                suffixIcon: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppImages.sar,
                                      width: 15.w,
                                      height: 15.h,
                                      colorFilter: ColorFilter.mode(
                                        AppColor.blackColor(dialogContext),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final amount = double.tryParse(value.trim());
                                    if (amount == null) {
                                      return isArabic
                                          ? 'الرجاء إدخال رقم صحيح'
                                          : 'Please enter a valid number';
                                    }
                                    if (amount < 0) {
                                      return isArabic
                                          ? 'المبلغ لا يمكن أن يكون سالباً'
                                          : 'Amount cannot be negative';
                                    }
                                    if (amount > widget.car.priceWithVat) {
                                      return isArabic
                                          ? 'المبلغ لا يمكن أن يتجاوز سعر السيارة الإجمالي'
                                          : 'Amount cannot exceed the total car price';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              Gap(16.h),
                              CustomFormField(
                                controller: notesController,
                                hintText: AppLocaleKey.agentBookingNotesHint.tr(),
                                radius: 12.r,
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                prefixIcon: Icon(
                                  Icons.edit_note_rounded,
                                  color: AppColor.hintColor(dialogContext),
                                ),
                              ),
                              Gap(16.h),
                              ReservationTermsCheckboxWidget(
                                value: isTermsAccepted,
                                onChanged: (val) => setModalState(() {
                                  isTermsAccepted = val ?? false;
                                }),
                              ),
                              Gap(24.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          side: BorderSide(
                                            color: AppColor.borderColor(dialogContext),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isArabic ? 'إلغاء' : 'Cancel',
                                        style: AppTextStyle.bodySmall(dialogContext).copyWith(
                                          color: AppColor.greyColor(dialogContext),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: CustomButton(
                                      radius: 12.r,
                                      onPressed: () {
                                        if (!isTermsAccepted) {
                                          CommonMethods.showToast(
                                            message: isArabic
                                                ? 'يرجى الموافقة على الشروط والأحكام أولاً'
                                                : 'Please agree to the Terms & Conditions first',
                                            type: ToastType.error,
                                          );
                                          return;
                                        }
                                        if (formKey.currentState!.validate()) {
                                          final name = nameController.text.trim();
                                          final phone = phoneController.text.trim();
                                          final deposit =
                                              double.tryParse(depositController.text.trim()) ?? 0.0;
                                          Navigator.pop(dialogContext);
                                          _submitReservation(
                                            customerName: name,
                                            customerPhone: phone,
                                            depositAmount: deposit,
                                            customerNo: selectedCustomer?.customerNo,
                                            reservationType: reservationType,
                                            notes: notesController.text.trim(),
                                          );
                                        }
                                      },
                                      child: _isLoading
                                          ? CustomLoading(color: AppColor.whiteColor(dialogContext))
                                          : Text(
                                              isArabic ? 'تأكيد الحجز' : 'Confirm Reservation',
                                              style: AppTextStyle.bodySmall(dialogContext).copyWith(
                                                color: AppColor.whiteColor(dialogContext),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _submitReservation({
    required String customerName,
    required String customerPhone,
    required double depositAmount,
    int? customerNo,
    required int reservationType,
    required String notes,
  }) {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd', 'en').format(now);
    final DateTime expiryDateTime = (reservationType == 2)
        ? now.add(const Duration(days: 3))
        : now.add(const Duration(hours: 12));
    final futureDateStr = DateFormat('yyyy-MM-dd', 'en').format(expiryDateTime);

    final itemCode = widget.car.itemCode;
    final itemName = widget.car.itemName;
    final chassisNo = widget.car.chassisNo;
    final groupCode = widget.car.groupCode.toString();
    final storeCodeVal = int.tryParse(widget.car.storeCode) ?? 1;
    final code = HiveMethods.getcode() ?? '';
    final double vatSerial = double.tryParse(HiveMethods.getVatNumber().toString()) ?? 15.0;
    final double basePrice = widget.car.price;
    final double totalWithTax = basePrice * ((100 + vatSerial) / 100);
    final double taxValue = double.parse((totalWithTax - basePrice).toStringAsFixed(2));

    final String typeTitle;
    switch (reservationType) {
      case 2:
        typeTitle = 'بنك';
        break;
      case 1:
        typeTitle = 'معرض';
        break;
      case 0:
      default:
        typeTitle = 'فرد';
        break;
    }
    final noteType = 'حجز $typeTitle من التطبيق';
    final representativeNotes = notes.trim();
    final bookingNotes = representativeNotes.isEmpty
        ? '$noteType '
        : '$noteType - $representativeNotes';

    // Remember who to notify once the booking is confirmed.
    _pendingCustomerPhone = customerPhone;
    _pendingDeposit = depositAmount;
    _pendingReservationType = reservationType;

    final model = AddBookingPermissionModel(
      lpoNos: '',
      lpono: '',
      listNo: 0,
      analytical: '',
      customerNo: customerNo ?? 0,
      represCode: int.tryParse(code) ?? 0,
      fDate: todayStr,
      lDate: futureDateStr,
      lpoDate: todayStr,
      storeCode: storeCodeVal,
      taamedNo: '',
      payCond: '',
      guarFinal: 0,
      notes:
          'حجز من التطبيق $bookingNotes${customerName.isNotEmpty ? " - الاسم: $customerName" : ""}',
      userAdd: (HiveMethods.getUserName() ?? '').substring(
        0,
        (HiveMethods.getUserName() ?? '').length.clamp(0, 50),
      ),
      requiredDoc: widget.car.price.toString().substring(
        0,
        widget.car.price.toString().length.clamp(0, 50),
      ),
      subLpo: [
        SubLpoModel(
          itemCode: itemCode.trim(),
          itemName: itemName.substring(0, itemName.length.clamp(0, 100)),
          chassisNo: chassisNo.substring(0, chassisNo.length.clamp(0, 50)),
          price: basePrice,
          advancedAmount: depositAmount,
          storeCode: storeCodeVal,
          TAX_VAL: taxValue,
          GROUP_CODE: groupCode,
          PAINTINGS_VAL: (widget.car.paintingsVal ?? 0.0).toString(),
          MAKEYEAR: widget.car.year,
          colorcode: widget.car.colorCode?.trim() ?? '',
        ),
      ],
    );

    context.read<HomeCubit>().getAddBookingPermission(model);
  }
}
