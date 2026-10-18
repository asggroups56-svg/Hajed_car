import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/status.state.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/agent/data/model/creat_offer_model.dart';
import 'package:car/features/agent/data/model/customer_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:car/features/agent/presentation/screens/widget/custom_quote_header_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/customer_dropdown_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/date_picker_tile_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/info_chip_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/payment_toggle_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/sar_field_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/section_title_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/sections_title_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/submit_footer_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/total_banner_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class QuoteBuilderDialog extends StatefulWidget {
  final CarModel car;
  final Map<String, String> existingSpecs;
  final void Function(String successMsg) onSuccess;
  const QuoteBuilderDialog({
    super.key,
    required this.car,
    required this.existingSpecs,
    required this.onSuccess,
  });

  /// الطريقة الوحيدة لعرض الـ dialog
  static Future<bool> show(
    BuildContext context, {
    required CarModel car,
    required Map<String, String> existingSpecs,
  }) async {
    String? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // sheetCtx هو context الـ modal نفسه — مضمون للـ pop
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<AgentCubit>(),
        child: QuoteBuilderDialog(
          car: car,
          existingSpecs: existingSpecs,
          onSuccess: (msg) {
            result = msg;
            // نستخدم sheetCtx المُقدَّم من showModalBottomSheet مباشرة
            Navigator.of(sheetCtx).pop();
          },
        ),
      ),
    );

    if (result != null && result!.isNotEmpty) {
      CommonMethods.showToast(message: result!, type: ToastType.success);
      return true;
    }
    return false;
  }

  @override
  State<QuoteBuilderDialog> createState() => _QuoteBuilderDialogState();
}

class _QuoteBuilderDialogState extends State<QuoteBuilderDialog> {
  late TextEditingController _priceController;
  final TextEditingController _platePriceController = TextEditingController(text: '600');
  final TextEditingController _specController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _begDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final List<String> _instantSpecs = [];
  CustomerModel? _selectedCustomer;
  String _paymentType = 'CSH'; // CSH = نقد, CRD = آجل
  bool _isCustomerDropdownOpen = false;

  int get _represNo {
    final code = HiveMethods.getUserCode() ?? '1';
    return int.tryParse(code) ?? 1;
  }

  DateTime? _begDate;
  DateTime? _endDate;

  Future<void> _pickDate(BuildContext context, bool isBeg) async {
    if (isBeg) {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: _begDate ?? now,
        firstDate: now.subtract(const Duration(days: 30)),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) {
        final formatted = DateFormat('yyyy-MM-dd', 'en').format(picked);
        setState(() {
          _begDate = picked;
          _begDateController.text = formatted;
          _endDate = picked.add(const Duration(days: 2));
          _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);
        });
      }
    } else {
      final baseBegDate = _begDate ?? DateTime.now();
      final maxEndDate = baseBegDate.add(const Duration(days: 2));
      final picked = await showDatePicker(
        context: context,
        initialDate:
            _endDate != null && !_endDate!.isAfter(maxEndDate) && !_endDate!.isBefore(baseBegDate)
            ? _endDate!
            : maxEndDate,
        firstDate: baseBegDate,
        lastDate: maxEndDate,
      );
      if (picked != null) {
        final formatted = DateFormat('yyyy-MM-dd', 'en').format(picked);
        setState(() {
          _endDate = picked;
          _endDateController.text = formatted;
        });
      }
    }
  }

  num get _price => num.tryParse(_priceController.text) ?? 0;
  num get _taxRate => 0.15;
  num get _platePrice => num.tryParse(_platePriceController.text) ?? 0;
  num get _taxAmount => _price * _taxRate;
  num get _total => (_price + _taxAmount + _platePrice) * 1;
  String get _today => DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
  String get _lastDate => DateFormat(
    'yyyy-MM-dd',
    'en',
  ).format((_begDate ?? DateTime.now()).add(const Duration(days: 3)));
  String get _terms => _instantSpecs.join(' | ');
  String get _carNote {
    final List<String> parts = _existingSpecsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.join(' | ');
  }

  late TextEditingController _existingSpecsController;
  StreamSubscription<AgentState>? _stateSubscription;
  bool _handled = false; // منع التكرار

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.car.costPrice?.toStringAsFixed(0) ?? '0');
    if (widget.car.paintingsVal != null && widget.car.paintingsVal! > 0) {
      _platePriceController.text = widget.car.paintingsVal!.toStringAsFixed(0);
    }
    _begDate = DateTime.now();
    _begDateController.text = _today;
    _endDate = DateTime.now().add(const Duration(days: 2));
    _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);
    context.read<AgentCubit>().getCustomer(null);

    final initialText = widget.existingSpecs.entries
        .where((e) => e.value.trim().isNotEmpty && e.value.trim() != '—' && e.value.trim() != '-')
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    _existingSpecsController = TextEditingController(text: initialText);

    // نتابع الـ stream مباشرة — الـ pop يتم عبر widget.onSuccess
    Status lastStatus = context.read<AgentCubit>().state.bookingPermissionStatus.status;

    _stateSubscription = context.read<AgentCubit>().stream.listen((state) {
      if (!mounted || _handled) return;
      final currentStatus = state.bookingPermissionStatus.status;
      if (currentStatus == lastStatus) return;
      lastStatus = currentStatus;

      if (state.bookingPermissionStatus.isSuccess) {
        _handled = true;
        final resMsg =
            state.bookingPermissionStatus.data?.message ?? state.bookingPermissionStatus.message;
        final isArabic = context.locale.languageCode == 'ar';
        final successMsg = (resMsg != null && resMsg.trim().isNotEmpty)
            ? resMsg
            : (isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully');

        // نستدعي reset أولاً ثم نُغلق عبر الـ callback الخارجي
        context.read<AgentCubit>().resetBookingPermissionStatus();
        widget.onSuccess(successMsg);
      } else if (state.bookingPermissionStatus.isFailure) {
        final errMsg =
            state.bookingPermissionStatus.error ??
            (context.locale.languageCode == 'ar'
                ? 'حدث خطأ أثناء حفظ عرض السعر'
                : 'Error occurred while saving quote');
        context.read<AgentCubit>().resetBookingPermissionStatus();
        CommonMethods.showToast(message: errMsg, type: ToastType.error);
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _priceController.dispose();
    _begDateController.dispose();
    _endDateController.dispose();
    _platePriceController.dispose();
    _existingSpecsController.dispose();
    _specController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _addSpec() {
    if (_specController.text.trim().isNotEmpty) {
      setState(() {
        _instantSpecs.add(_specController.text.trim());
        _specController.clear();
      });
    }
  }

  void _removeSpec(int index) {
    setState(() => _instantSpecs.removeAt(index));
  }

  void _submit(BuildContext context) {
    if (_selectedCustomer == null) {
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar'
            ? 'برجاء اختيار العميل أولاً'
            : 'Please select a customer first',
        type: ToastType.error,
      );
      return;
    }

    final beg = _begDate ?? DateTime.now();
    final end = _endDate ?? beg.add(const Duration(days: 2));
    if (end.difference(beg).inDays > 3) {
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar'
            ? 'صلاحية عرض السعر ٣ أيام فقط لا يمكن أن تزيد عن ذلك'
            : 'Quotation validity is 3 days only and cannot exceed that',
        type: ToastType.error,
      );
      return;
    }

    final subList = [
      OfferItemModel(
        GROUP_CODE: '',
        itemName: widget.car.itemName ?? '',
        colorCode: widget.car.colorCode ?? 0,
        itemCode: widget.car.itemCode ?? '',
        chassisNo: widget.car.chassisNo ?? '',
        makeYear: widget.car.makeYear ?? 0,
        qnty: 1,
        price: _price,
        note: _carNote,
        taxVal: _taxAmount,
        paintingsVal: _platePrice,
      ),
    ];

    final offer = CreatOfferModel(
      listDate: _today,
      taamedDate: _today,
      lastDate: _lastDate,
      customerNo: _selectedCustomer!.customerNo ?? 0,
      represCode: _represNo,
      resType: 1,
      paymentType: _paymentType,
      guarPrimary: 0,
      guarFinal: 0,
      deliveryPeriod: 0,
      listPeriod: 3,
      notes: null,
      terms: _terms.isEmpty ? null : _terms,
      total: _total,
      subList: subList,
      begDate: _begDateController.text,
      endDate: _endDateController.text,
    );

    context.read<AgentCubit>().addbookingpermission(offer);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 0.92.sh,
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor(context).withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              CustomQuoteHeaderWidget(widget: widget),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: AppLocaleKey.date.tr(),
                        icon: Icons.calendar_today_rounded,
                      ),
                      Gap(10.h),
                      InfoChip(
                        icon: Icons.event_rounded,
                        label: _today,
                        color: AppColor.primaryColor(context),
                        context: context,
                      ),
                      Gap(20.h),
                      Row(
                        children: [
                          SectionTitle(
                            title: AppLocaleKey.period.tr(),
                            icon: Icons.date_range_rounded,
                          ),
                          Gap(8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              context.locale.languageCode == 'ar'
                                  ? 'صلاحية ٣ أيام فقط بحد اقصي'
                                  : '3 Days Validity Only Max',
                              style: AppTextStyle.bodySmall(context).copyWith(
                                color: AppColor.primaryColor(context),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(10.h),
                      Row(
                        children: [
                          Expanded(
                            child: DatePickerTile(
                              label: AppLocaleKey.form.tr(),
                              date: _begDate,
                              onTap: () => _pickDate(context, true),
                              context: context,
                              controller: _begDateController,
                              validator: (_) => null,
                            ),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: DatePickerTile(
                              label: AppLocaleKey.to.tr(),
                              date: _endDate,
                              onTap: () => _pickDate(context, false),
                              context: context,
                              controller: _endDateController,
                              validator: (_) => null,
                            ),
                          ),
                        ],
                      ),
                      Gap(20.h),
                      SectionTitle(
                        title: AppLocaleKey.customer.tr(),
                        icon: Icons.person_search_rounded,
                      ),
                      Gap(10.h),
                      CustomerDropdown(
                        selected: _selectedCustomer,
                        isOpen: _isCustomerDropdownOpen,
                        searchController: _customerSearchController,
                        onToggle: () =>
                            setState(() => _isCustomerDropdownOpen = !_isCustomerDropdownOpen),
                        onSelect: (c) => setState(() {
                          _selectedCustomer = c;
                          _isCustomerDropdownOpen = false;
                          _customerSearchController.clear();
                          context.read<AgentCubit>().getCustomer(null);
                        }),
                        onSearch: (v) =>
                            context.read<AgentCubit>().getCustomer(v.isEmpty ? null : v),
                        context: context,
                      ),
                      Gap(20.h),
                      SectionTitle(
                        title: AppLocaleKey.payment_type.tr(),
                        icon: Icons.payments_rounded,
                      ),
                      Gap(10.h),
                      PaymentToggle(
                        value: _paymentType,
                        onChanged: (v) => setState(() => _paymentType = v),
                        context: context,
                      ),
                      Gap(20.h),
                      SectionTitle(
                        title: AppLocaleKey.agentSellingPrice.tr(),
                        icon: Icons.sell_rounded,
                      ),
                      Gap(10.h),
                      SarField(
                        controller: _priceController,
                        context: context,
                        onChanged: (_) => setState(() {}),
                      ),
                      Gap(16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColor.orangeColor(context).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColor.orangeColor(context).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calculate_outlined,
                                  size: 16.sp,
                                  color: AppColor.orangeColor(context),
                                ),
                                Gap(8.w),
                                Text(
                                  AppLocaleKey.tax.tr(),
                                  style: AppTextStyle.bodySmall(context).copyWith(
                                    color: AppColor.orangeColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${NumberFormat('#,##0.##').format(_taxAmount)} ${AppLocaleKey.sar.tr()}',
                              style: AppTextStyle.bodyMedium(context).copyWith(
                                color: AppColor.orangeColor(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(16.h),
                      SectionTitle(
                        title: AppLocaleKey.agentPlatePrice.tr(),
                        icon: Icons.credit_card_rounded,
                      ),
                      Gap(10.h),
                      SarField(
                        controller: _platePriceController,
                        context: context,
                        onChanged: (_) => setState(() {}),
                      ),
                      Gap(16.h),
                      TotalBanner(
                        price: _price,
                        taxAmount: _taxAmount,
                        platePrice: _platePrice,
                        total: _total,
                        context: context,
                      ),
                      Gap(20.h),
                      SectionTitleWidget(
                        title: AppLocaleKey.specs.tr(),
                        icon: Icons.add_task_rounded,
                      ),
                      Gap(10.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              controller: _specController,
                              hintText: AppLocaleKey.enterSpecTitle.tr(),
                              onSubmitted: (_) => _addSpec(),
                              validator: (v) => null,
                            ),
                          ),
                          Gap(12.w),
                          GestureDetector(
                            onTap: _addSpec,
                            child: Container(
                              height: 40.h,
                              width: 40.h,
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: AppColor.whiteColor(context),
                                size: 28.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_instantSpecs.isNotEmpty) ...[
                        Gap(14.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _instantSpecs.asMap().entries.map((entry) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColor.primaryColor(context).withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.value,
                                    style: AppTextStyle.bodySmall(context).copyWith(
                                      color: AppColor.primaryColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Gap(8.w),
                                  GestureDetector(
                                    onTap: () => _removeSpec(entry.key),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 16.sp,
                                      color: AppColor.primaryColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      Gap(20.h),
                      SectionTitleWidget(
                        title: AppLocaleKey.existingSpecs.tr(),
                        icon: Icons.list_alt_rounded,
                      ),
                      Gap(10.h),
                      CustomFormField(
                        controller: _existingSpecsController,
                        hintText: AppLocaleKey.enter_spec_title_hint.tr(),
                        maxLines: 6,
                        validator: (_) => null,
                      ),
                    ],
                  ),
                ),
              ),
              SubmitFooter(onSubmit: () => _submit(context), context: context),
            ],
          ),
        ),
      ),
    );
  }
}
