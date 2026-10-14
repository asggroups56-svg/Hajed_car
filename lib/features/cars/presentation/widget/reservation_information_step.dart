import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/saudi_phone_number.dart';
import 'package:car/features/admin/data/model/representative_model.dart';
import 'package:car/features/cars/presentation/widget/financing_contact_form.dart';
import 'package:car/features/cars/presentation/widget/financing_pricing_card_widget.dart';
import 'package:car/features/cars/presentation/widget/reservation_pricing_card.dart';
import 'package:car/features/cars/presentation/widget/reservation_step_indicator.dart';
import 'package:car/features/cars/presentation/widget/reservation_terms_checkbox_widget.dart';
import 'package:car/features/cars/presentation/widget/reservation_whatsapp_checkbox_widget.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReservationInformationStep extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final bool isFinancingFlow;
  final double totalPrice;
  final double depositAmount;
  final GlobalKey<FormState> formKey;
  final TextEditingController cashNameController;
  final TextEditingController cashPhoneController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController financePhoneController;
  final ValueNotifier<bool> whatsappNotifier;
  final ValueNotifier<String?> selectedCityNotifier;
  final VoidCallback onShowPricingDetails;
  final bool isTermsAccepted;
  final ValueChanged<bool?> onTermsAcceptedChanged;
  final RepresentativeModel? selectedRepresentative;
  final ValueChanged<RepresentativeModel?> onRepresentativeChanged;

  const ReservationInformationStep({
    super.key,
    required this.car,
    required this.isFinancingFlow,
    required this.totalPrice,
    required this.depositAmount,
    required this.formKey,
    required this.cashNameController,
    required this.cashPhoneController,
    required this.firstNameController,
    required this.lastNameController,
    required this.financePhoneController,
    required this.whatsappNotifier,
    required this.selectedCityNotifier,
    required this.onShowPricingDetails,
    required this.isTermsAccepted,
    required this.onTermsAcceptedChanged,
    required this.selectedRepresentative,
    required this.onRepresentativeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReservationStepIndicator(
          currentStep: 0,
          isFinancingFlow: isFinancingFlow,
        ),
        Gap(8.h),
        if (isFinancingFlow)
          FinancingPricingCard(
            totalPrice: totalPrice,
            onShowDetails: onShowPricingDetails,
          )
        else
          ReservationPricingCard(
            totalPrice: totalPrice,
            depositAmount: depositAmount,
          ),
        Gap(32.h),
        Text(
          isFinancingFlow
              ? AppLocaleKey.agentEnterDetails.tr()
              : AppLocaleKey.agentContactInfo.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 20.sp),
        ),
        Gap(16.h),
        if (isFinancingFlow) ...[
          FinancingContactForm(
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            phoneController: financePhoneController,
            whatsappNotifier: whatsappNotifier,
            selectedCityNotifier: selectedCityNotifier,
          ),
          Gap(16.h),
          const _PurchaseRequirementsNoticeWidget(),
        ] else ...[
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormField(
                  controller: cashNameController,
                  hintText: AppLocaleKey.agentFullName.tr(),
                  radius: 12,
                  validator: (v) => v == null || v.isEmpty
                      ? AppLocaleKey.validateEmpty.tr()
                      : null,
                ),
                Gap(16.h),
                CustomFormField(
                  controller: cashPhoneController,
                  hintText: AppLocaleKey.agentPhone.tr(),
                  radius: 12,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: const [SaudiPhoneInputFormatter()],
                  validator: (v) {
                    final phone = SaudiPhoneNumber.normalize(v ?? '');
                    if (phone.isEmpty) {
                      return AppLocaleKey.validateEmpty.tr();
                    }
                    if (!phone.startsWith('05')) {
                      return context.locale.languageCode == 'ar'
                          ? 'رقم الجوال يجب أن يبدأ بـ 05'
                          : 'Phone number must start with 05';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                      return context.locale.languageCode == 'ar'
                          ? 'رقم الجوال يجب أن يحتوي على أرقام فقط'
                          : 'Phone number must contain only digits';
                    } else if (!SaudiPhoneNumber.isValid(phone)) {
                      return context.locale.languageCode == 'ar'
                          ? 'رقم الجوال يجب أن يكون 10 أرقام'
                          : 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // BlocBuilder<AdminCubit, AdminState>(
                //   buildWhen: (previous, current) =>
                //       previous.searchRepresentativesStatus != current.searchRepresentativesStatus,
                //   builder: (context, state) {
                //     final status = state.searchRepresentativesStatus;
                //     final representatives = status.data ?? const <RepresentativeModel>[];
                //     return DropdownButtonFormField<RepresentativeModel>(
                //       initialValue: selectedRepresentative,
                //       isExpanded: true,
                //       decoration: InputDecoration(
                //         labelText: 'المندوب (اختياري)',
                //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                //       ),
                //       hint: Text(status.isLoading ? 'جاري تحميل المناديب...' : 'اختر مندوبًا'),
                //       items: representatives
                //           .where((representative) => representative.represNo != null)
                //           .map(
                //             (representative) => DropdownMenuItem<RepresentativeModel>(
                //               value: representative,
                //               child: Text(
                //                 representative.represName ??
                //                     representative.represNameEng ??
                //                     'مندوب ${representative.represNo}',
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             ),
                //           )
                //           .toList(),
                //       onChanged: status.isLoading ? null : onRepresentativeChanged,
                //       validator: (value) => null,
                //     );
                //   },
                // ),
              ],
            ),
          ),
          Gap(16.h),
          const _PurchaseRequirementsNoticeWidget(),
          Gap(16.h),
          ValueListenableBuilder<bool>(
            valueListenable: whatsappNotifier,
            builder: (context, isWhatsappEnabled, _) {
              return ReservationWhatsAppCheckboxWidget(
                value: isWhatsappEnabled,
                onChanged: (val) => whatsappNotifier.value = val ?? false,
              );
            },
          ),
          Gap(12.h),
          ReservationTermsCheckboxWidget(
            value: isTermsAccepted,
            onChanged: onTermsAcceptedChanged,
          ),
        ],
      ],
    );
  }
}

class _PurchaseRequirementsNoticeWidget extends StatelessWidget {
  const _PurchaseRequirementsNoticeWidget();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262015) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: const Color(0xFFD97706),
              size: 22.sp,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'تنبيه لإتمام عملية الشراء'
                      : 'Purchase Requirement Notice',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: isDark
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFFB45309),
                  ),
                ),
                Gap(4.h),
                Text(
                  isArabic
                      ? 'ملاحظة مهمة: يلزم توفر بطاقة الهوية الوطنية (أو الإقامة) ورخصة قيادة سارية المفعول لإتمام مبايعة السيارة ونقل الملكية.'
                      : 'Important Note: A valid National ID (or Iqama) and a valid driving license are required to complete the vehicle purchase and transfer ownership.',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    fontSize: 11.5.sp,
                    height: 1.55,
                    color: AppColor.blackTextColor(
                      context,
                    ).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
