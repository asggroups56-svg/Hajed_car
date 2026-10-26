import 'dart:async';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/agent/data/model/color_model.dart';
import 'package:car/features/agent/data/model/creat_offer_model.dart';
import 'package:car/features/agent/data/model/customer_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:car/features/agent/presentation/screens/widget/external_quote_picker_sheets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class AgentExternalQuoteScreen extends StatefulWidget {
  const AgentExternalQuoteScreen({super.key});

  @override
  State<AgentExternalQuoteScreen> createState() => _AgentExternalQuoteScreenState();
}

class _AgentExternalQuoteScreenState extends State<AgentExternalQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fmt = NumberFormat('#,##0.##', 'en_US');

  // Car
  final _carNameController = TextEditingController();
  final _carCodeController = TextEditingController();
  final _chassisController = TextEditingController();
  final _makeYearController = TextEditingController(text: DateTime.now().year.toString());
  final _carSpecsController = TextEditingController();
  final _qntyController = TextEditingController(text: '1');

  // Pricing
  final _priceController = TextEditingController();
  final _platePriceController = TextEditingController(text: '600');

  // Quote
  final _begDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _receivePlaceController = TextEditingController();
  final _termsController = TextEditingController();
  final _notesController = TextEditingController();

  // Customer
  final _customerNameController = TextEditingController();
  final _customerMobileController = TextEditingController();

  final ValueNotifier<ColorModel?> _selectedColor = ValueNotifier(null);
  final ValueNotifier<Set<String>> _selectedTerms = ValueNotifier(<String>{});
  final ValueNotifier<String> _paymentType = ValueNotifier('CSH');

  final int _areaNo = 1;
  final int _resType = 1;

  DateTime? _begDate;
  DateTime? _endDate;

  final List<String> _quickTerms = const [
    AppLocaleKey.externalQuoteTermPlates,
    AppLocaleKey.externalQuoteTermVat,
    AppLocaleKey.externalQuoteTermWarranty,
    AppLocaleKey.externalQuoteTermImmediateDelivery,
    AppLocaleKey.externalQuoteTermShipping,
  ];

  final List<String> _popularSpecs = const [
    AppLocaleKey.externalQuoteSpecSunroof,
    AppLocaleKey.externalQuoteSpecLeatherSeats,
    AppLocaleKey.externalQuoteSpecNavigation,
    AppLocaleKey.externalQuoteSpecCameras,
    AppLocaleKey.externalQuoteSpecRadar,
    AppLocaleKey.externalQuoteSpecRims,
    AppLocaleKey.externalQuoteSpecRemoteStart,
  ];

  late final Listenable _pricingListenable = Listenable.merge([
    _priceController,
    _platePriceController,
    _qntyController,
  ]);

  int get _represNo => int.tryParse(HiveMethods.getUserCode() ?? '1') ?? 1;
  String get _today => DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
  String get _lastDate => DateFormat(
    'yyyy-MM-dd',
    'en',
  ).format((_begDate ?? DateTime.now()).add(const Duration(days: 3)));

  num get _price => num.tryParse(_priceController.text) ?? 0;
  num get _platePrice => num.tryParse(_platePriceController.text) ?? 0;
  int get _qty => int.tryParse(_qntyController.text) ?? 1;
  num get _taxAmount => _price * 0.15;
  num get _total => (_price + _taxAmount + _platePrice) * _qty;

  @override
  void initState() {
    super.initState();
    _begDate = DateTime.now();
    _begDateController.text = _today;
    _endDate = DateTime.now().add(const Duration(days: 2));
    _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);

    final cubit = context.read<AgentCubit>();
    cubit.getCustomer(null);
    cubit.getColors(null);
  }

  @override
  void dispose() {
    for (final c in [
      _carNameController,
      _carCodeController,
      _chassisController,
      _makeYearController,
      _carSpecsController,
      _qntyController,
      _priceController,
      _platePriceController,
      _begDateController,
      _endDateController,
      _receivePlaceController,
      _termsController,
      _notesController,
      _customerNameController,
      _customerMobileController,
    ]) {
      c.dispose();
    }
    _selectedColor.dispose();
    _selectedTerms.dispose();
    _paymentType.dispose();
    super.dispose();
  }

  void _toastError(String messageKey) =>
      CommonMethods.showToast(message: messageKey.tr(), type: ToastType.error);

  // ───────────────────────── Style helpers ─────────────────────────

  TextStyle _t(double size, {Color? color, FontWeight? weight}) =>
      AppTextStyle.bodyMedium(context).copyWith(
        fontSize: size.sp,
        color: color ?? AppColor.blackTextColor(context),
        fontWeight: weight ?? FontWeight.w600,
        height: 1.3,
      );

  Color get _primary => AppColor.primaryColor(context);
  Color get _grey => AppColor.greyColor(context);
  Color get _border => AppColor.borderColor(context).withValues(alpha: 0.28);

  // ───────────────────────── Pickers ─────────────────────────


  Future<void> _openColorPicker() async {
    final cubit = context.read<AgentCubit>();
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<ColorModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ExternalQuoteColorPickerSheet(selectedCode: _selectedColor.value?.code),
      ),
    );
    if (picked != null) _selectedColor.value = picked;
  }

  Future<void> _pickDate(bool isBeg) async {
    if (isBeg) {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: _begDate ?? now,
        firstDate: now.subtract(const Duration(days: 30)),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) {
        setState(() {
          _begDate = picked;
          _begDateController.text = DateFormat('yyyy-MM-dd', 'en').format(picked);
          _endDate = picked.add(const Duration(days: 2));
          _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);
        });
      }
    } else {
      final base = _begDate ?? DateTime.now();
      final maxEnd = base.add(const Duration(days: 2));
      final picked = await showDatePicker(
        context: context,
        initialDate: _endDate != null && !_endDate!.isAfter(maxEnd) && !_endDate!.isBefore(base)
            ? _endDate!
            : maxEnd,
        firstDate: base,
        lastDate: maxEnd,
      );
      if (picked != null) {
        setState(() {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(picked);
        });
      }
    }
  }

  // ───────────────────────── Submit / Reset ─────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      _toastError(AppLocaleKey.externalQuoteRequiredFields);
      return;
    }
    final customerName = _customerNameController.text.trim();
    if (customerName.isEmpty) {
      _toastError(AppLocaleKey.externalQuoteSelectCustomer);
      return;
    }
    final customerMobile = _customerMobileController.text.trim();
    int matchedCustomerNo = 0;
    final customerList = context.read<AgentCubit>().state.customersStatus.data ?? [];
    if (customerList.isNotEmpty) {
      final match = customerList.firstWhere(
        (c) =>
            (c.customerName ?? '').trim().toLowerCase() == customerName.toLowerCase() ||
            (customerMobile.isNotEmpty && c.customerMobile.trim() == customerMobile),
        orElse: () => const CustomerModel(),
      );
      matchedCustomerNo = match.customerNo ?? 0;
    }

    final color = _selectedColor.value;
    if (color == null) {
      _toastError(AppLocaleKey.externalQuoteSelectColor);
      return;
    }
    if (_price <= 0) {
      _toastError(AppLocaleKey.externalQuotePriceRequired);
      return;
    }
    final beg = _begDate ?? DateTime.now();
    final end = _endDate ?? beg.add(const Duration(days: 2));
    if (end.difference(beg).inDays > 3) {
      _toastError(AppLocaleKey.externalQuoteValidityError);
      return;
    }

    final allTerms = [
      if (_termsController.text.trim().isNotEmpty) _termsController.text.trim(),
      ..._selectedTerms.value,
    ].join(' | ');

    final subList = [
      OfferItemModel(
        itemCode: '',
        chassisNo: '',
        GROUP_CODE: _carCodeController.text.trim().isNotEmpty
            ? _carCodeController.text.trim()
            : '1',
        itemName: _carNameController.text.trim(),
        colorCode: color.code,
        makeYear: int.tryParse(_makeYearController.text.trim()) ?? DateTime.now().year,
        qnty: _qty,
        price: _price,
        note: _carSpecsController.text.trim(),
        taxVal: _taxAmount,
        paintingsVal: _platePrice,
      ),
    ];

    final offer = CreatOfferModel(
      listDate: _today,
      taamedDate: _today,
      lastDate: _lastDate,
      customerNo: matchedCustomerNo,
      customerName: customerName,
      customerMobile: customerMobile,
      represCode: _represNo,
      resType: _resType,
      paymentType: _paymentType.value,
      areaNo: _areaNo,
      guarPrimary: 0,
      guarFinal: 0,
      deliveryPeriod: 0,
      listPeriod: 3,
      receivePlace: _receivePlaceController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      terms: allTerms.isEmpty ? null : allTerms,
      total: _total,
      subList: subList,
      begDate: _begDateController.text,
      endDate: _endDateController.text,
    );

    context.read<AgentCubit>().addExternalofferprice(offer);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _carNameController.clear();
    _carCodeController.clear();
    _chassisController.clear();
    _makeYearController.text = DateTime.now().year.toString();
    _carSpecsController.clear();
    _qntyController.text = '1';
    _priceController.clear();
    _platePriceController.text = '600';
    _receivePlaceController.clear();
    _termsController.clear();
    _notesController.clear();
    _customerNameController.clear();
    _customerMobileController.clear();
    _selectedColor.value = null;
    _selectedTerms.value = <String>{};
    _paymentType.value = 'CSH';
    setState(() {
      _begDate = DateTime.now();
      _begDateController.text = _today;
      _endDate = DateTime.now().add(const Duration(days: 2));
      _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);
    });
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgentCubit, AgentState>(
      listenWhen: (p, c) => p.createOfferStatus != c.createOfferStatus,
      listener: (context, state) {
        if (state.createOfferStatus.isSuccess) {
          final resMsg = state.createOfferStatus.data?.message ??
              state.createOfferStatus.message;
          final isArabic = context.locale.languageCode == 'ar';
          final msg = (resMsg != null && resMsg.trim().isNotEmpty)
              ? resMsg
              : (isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully');

          CommonMethods.showToast(
            message: msg,
            type: ToastType.success,
          );
          context.read<AgentCubit>().resetCreateOfferStatus();
          _resetForm();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state.createOfferStatus.isFailure) {
          final errMsg = state.createOfferStatus.error ??
              state.createOfferStatus.message ??
              (context.locale.languageCode == 'ar'
                  ? 'حدث خطأ أثناء الحفظ'
                  : 'Error occurred while saving');
          CommonMethods.showToast(
            message: errMsg,
            type: ToastType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        appBar: CustomAppBar(
          context,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(AppLocaleKey.externalQuote.tr(), style: _t(15, weight: FontWeight.w900)),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 20.h),
            children: [
              RepaintBoundary(child: _buildCustomerSection()),
              Gap(10.h),
              RepaintBoundary(child: _buildCarInfoSection()),
              Gap(10.h),
              RepaintBoundary(child: _buildPricingSection()),
              Gap(10.h),
              RepaintBoundary(child: _buildDatesAndTermsSection()),
              Gap(10.h),
              RepaintBoundary(child: _buildSummaryCard()),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Reusable compact UI ─────────────────────────

  Widget _card({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: _primary, size: 16.sp),
              ),
              Gap(8.w),
              Expanded(
                child: Text(title, style: _t(13.5, weight: FontWeight.w900)),
              ),
              if (trailing != null) trailing,
            ],
          ),
          Gap(12.h),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _dec({String? hint, IconData? icon, String? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColor.cardColor(context),
      hintText: hint,
      hintStyle: _t(12, color: AppColor.hintColor(context), weight: FontWeight.normal),
      errorStyle: TextStyle(fontSize: 10.sp, height: 1),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
      prefixIcon: icon == null ? null : Icon(icon, size: 16.sp, color: _grey),
      prefixIconConstraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
      suffixText: suffix,
      suffixStyle: _t(11, color: _grey),
      enabledBorder: b(_border),
      focusedBorder: b(_primary, 1.4),
      errorBorder: b(Colors.redAccent.withValues(alpha: 0.7)),
      focusedErrorBorder: b(Colors.redAccent, 1.4),
    );
  }

  /// Label + compact text field.
  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    String? suffix,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _t(11.5, color: _grey)),
        Gap(4.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          minLines: 1,
          inputFormatters: formatters,
          style: _t(13),
          decoration: _dec(hint: hint, icon: icon, suffix: suffix),
          maxLength: maxLength,
        ),
      ],
    );
  }

  List<TextInputFormatter> get _numOnly => [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

  String? _required(String? value, String messageKey) =>
      value == null || value.trim().isEmpty ? messageKey.tr() : null;

  /// Dropdown-looking field that opens a searchable bottom sheet.
  Widget _selector({
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    String? valueText,
    Widget? leading,
    VoidCallback? onClear,
  }) {
    final hasValue = valueText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _t(11.5, color: _grey)),
        Gap(4.h),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColor.cardColor(context),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: hasValue ? _primary.withValues(alpha: 0.55) : _border),
            ),
            child: Row(
              children: [
                leading ?? Icon(icon, color: hasValue ? _primary : _grey, size: 16.sp),
                Gap(8.w),
                Expanded(
                  child: Text(
                    valueText ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hasValue
                        ? _t(13)
                        : _t(12, color: AppColor.hintColor(context), weight: FontWeight.normal),
                  ),
                ),
                if (hasValue && onClear != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 4.w),
                      child: Icon(Icons.close_rounded, size: 16.sp, color: _grey),
                    ),
                  ),
                Icon(Icons.keyboard_arrow_down_rounded, color: _grey, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, TextEditingController c, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _t(11.5, color: _grey)),
        Gap(4.h),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColor.cardColor(context),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, size: 16.sp, color: _primary),
                Gap(8.w),
                Expanded(child: Text(c.text, style: _t(12.5))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorDot(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade400, width: 0.8),
    ),
  );

  // ───────────────────────── Sections ─────────────────────────

  Widget _buildCustomerSection() {
    return _card(
      icon: Icons.person_rounded,
      title: AppLocaleKey.externalQuoteCustomerSection.tr(),
      children: [
        _field(
          label: '${AppLocaleKey.customerName.tr()} *',
          controller: _customerNameController,
          hint: AppLocaleKey.agentFullCustomerName.tr(),
          icon: Icons.person_outline_rounded,
          validator: (v) => _required(v, AppLocaleKey.externalQuoteSelectCustomer),
        ),
        Gap(10.h),
        _field(
          label: AppLocaleKey.mobileNumber.tr(),
          controller: _customerMobileController,
          hint: '05xxxxxxxx',
          icon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          formatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildCarInfoSection() {
    return _card(
      icon: Icons.directions_car_filled_rounded,
      title: AppLocaleKey.carDetailsExternal.tr(),
      children: [
        _field(
          label: '${AppLocaleKey.carNameModel.tr()} *',
          controller: _carNameController,
          hint: AppLocaleKey.externalQuoteCarNameHint.tr(),
          icon: Icons.drive_file_rename_outline_rounded,
          validator: (v) => _required(v, AppLocaleKey.externalQuoteCarNameRequired),
        ),
        Gap(10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                label: AppLocaleKey.carCode.tr(),
                controller: _carCodeController,
                hint: '2531',
                icon: Icons.qr_code_2_rounded,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: _field(
                label: '${AppLocaleKey.makeYear.tr()} *',
                controller: _makeYearController,
                hint: '2025',
                icon: Icons.calendar_month_rounded,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) => _required(v, AppLocaleKey.externalQuoteYearRequired),
              ),
            ),
          ],
        ),
        Gap(10.h),
        _field(
          label: '${AppLocaleKey.chassisNumber.tr()} *',
          controller: _chassisController,
          hint: AppLocaleKey.externalQuoteChassisHint.tr(),
          icon: Icons.pin_rounded,
          maxLength: 17,
          validator: (v) => _required(v, AppLocaleKey.externalQuoteChassisRequired),
        ),
        Gap(10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ValueListenableBuilder<ColorModel?>(
                valueListenable: _selectedColor,
                builder: (context, color, _) => _selector(
                  label: '${AppLocaleKey.color.tr()} *',
                  hint: AppLocaleKey.externalQuoteColorHint.tr(),
                  icon: Icons.palette_rounded,
                  valueText: color != null ? color.name : null,
                  leading: color != null ? _colorDot(color.displayColor, 16.w) : null,
                  onTap: _openColorPicker,
                  onClear: () => _selectedColor.value = null,
                ),
              ),
            ),
            Gap(10.w),
            Expanded(
              flex: 2,
              child: _field(
                label: AppLocaleKey.quantity.tr(),
                controller: _qntyController,
                hint: '1',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
        Gap(10.h),
        _field(
          label: AppLocaleKey.carSpecsNotes.tr(),
          controller: _carSpecsController,
          hint: AppLocaleKey.externalQuoteSpecsHint.tr(),
          maxLines: 3,
        ),
        Gap(8.h),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _carSpecsController,
          builder: (context, value, _) {
            return Wrap(
              spacing: 6.w,
              runSpacing: 0,
              children: _popularSpecs.map((specKey) {
                final spec = specKey.tr();
                final isAdded = value.text.contains(spec);
                return ActionChip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
                  side: BorderSide(color: isAdded ? _primary : _border),
                  avatar: Icon(
                    isAdded ? Icons.check_rounded : Icons.add_rounded,
                    size: 13.sp,
                    color: isAdded ? _primary : _grey,
                  ),
                  label: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: isAdded ? _primary : AppColor.blackTextColor(context),
                      fontWeight: isAdded ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: isAdded
                      ? _primary.withValues(alpha: 0.1)
                      : AppColor.cardColor(context),
                  onPressed: () {
                    if (isAdded) {
                      _carSpecsController.text = value.text
                          .replaceAll(spec, '')
                          .replaceAll(RegExp(r'\s*-\s*-\s*'), ' - ')
                          .replaceAll(RegExp(r'^\s*-\s*|\s*-\s*$'), '')
                          .trim();
                    } else {
                      final current = value.text.trim();
                      _carSpecsController.text = current.isEmpty ? spec : '$current - $spec';
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _card(
      icon: Icons.payments_rounded,
      title: AppLocaleKey.externalQuotePricingSection.tr(),
      children: [
        _field(
          label: '${AppLocaleKey.baseCarPrice.tr()} *',
          controller: _priceController,
          hint: AppLocaleKey.externalQuotePriceHint.tr(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          formatters: _numOnly,
          suffix: AppLocaleKey.sar.tr(),
          icon: Icons.sell_rounded,
          validator: (v) => _required(v, AppLocaleKey.externalQuotePriceRequired),
        ),
        Gap(10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                label: AppLocaleKey.platesValueLabel.tr(),
                controller: _platePriceController,
                hint: '600',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                formatters: _numOnly,
                suffix: AppLocaleKey.sar.tr(),
                icon: Icons.credit_card_rounded,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocaleKey.taxAmountLabel.tr(), style: _t(11.5, color: _grey)),
                  Gap(4.h),
                  ListenableBuilder(
                    listenable: _priceController,
                    builder: (context, _) => Container(
                      height: 42.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _fmt.format(_taxAmount),
                                style: _t(13, color: _primary, weight: FontWeight.w800),
                              ),
                            ),
                          ),
                          ValueWithCurrencyIcon(
                            text: AppLocaleKey.sar.tr(),
                            textStyle: _t(11, color: _primary),
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
        Gap(12.h),
        Text(AppLocaleKey.externalQuotePaymentMethod.tr(), style: _t(11.5, color: _grey)),
        Gap(4.h),
        ValueListenableBuilder<String>(
          valueListenable: _paymentType,
          builder: (context, value, _) => Container(
            height: 40.h,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColor.cardColor(context),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                _payOption(
                  'CSH',
                  AppLocaleKey.externalQuoteCash.tr(),
                  Icons.payments_outlined,
                  value,
                ),
                _payOption(
                  'CRD',
                  AppLocaleKey.externalQuoteCredit.tr(),
                  Icons.account_balance_outlined,
                  value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _payOption(String code, String label, IconData icon, String current) {
    final selected = current == code;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _paymentType.value = code,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            height: 40.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15.sp, color: selected ? AppColor.whiteColor(context) : _grey),
                Gap(6.w),
                Text(
                  label,
                  style: _t(
                    12,
                    color: selected ? AppColor.whiteColor(context) : _grey,
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatesAndTermsSection() {
    return _card(
      icon: Icons.event_note_rounded,
      title: AppLocaleKey.quoteValidityPeriod.tr(),
      children: [
        Row(
          children: [
            Expanded(
              child: _dateField(
                AppLocaleKey.supplyStartDate.tr(),
                _begDateController,
                () => _pickDate(true),
              ),
            ),
            Gap(10.w),
            Expanded(
              child: _dateField(
                AppLocaleKey.supplyEndDate.tr(),
                _endDateController,
                () => _pickDate(false),
              ),
            ),
          ],
        ),
        Gap(10.h),
        _field(
          label: AppLocaleKey.receivePlace.tr(),
          controller: _receivePlaceController,
          hint: AppLocaleKey.externalQuoteReceivePlaceHint.tr(),
          icon: Icons.location_on_rounded,
        ),
        Gap(10.h),
        _field(
          label: AppLocaleKey.quoteTerms.tr(),
          controller: _termsController,
          hint: AppLocaleKey.externalQuoteTermsHint.tr(),
          icon: Icons.gavel_rounded,
        ),
        Gap(8.h),
        ValueListenableBuilder<Set<String>>(
          valueListenable: _selectedTerms,
          builder: (context, selected, _) => Wrap(
            spacing: 6.w,
            runSpacing: 0,
            children: _quickTerms.map((termKey) {
              final term = termKey.tr();
              final isOn = selected.contains(term);
              return FilterChip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
                showCheckmark: false,
                side: BorderSide(color: isOn ? _primary : _border),
                label: Text(
                  term,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: isOn ? _primary : AppColor.blackTextColor(context),
                    fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isOn,
                selectedColor: _primary.withValues(alpha: 0.1),
                backgroundColor: AppColor.cardColor(context),
                onSelected: (v) {
                  final next = {...selected};
                  v ? next.add(term) : next.remove(term);
                  _selectedTerms.value = next;
                },
              );
            }).toList(),
          ),
        ),
        Gap(10.h),
        _field(
          label: AppLocaleKey.externalQuoteNotesLabel.tr(),
          controller: _notesController,
          hint: AppLocaleKey.externalQuoteNotesHint.tr(),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: _t(12, color: _grey, weight: FontWeight.w500),
          ),
          Text(
            value,
            style: _t(12.5, color: valueColor, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return ListenableBuilder(
      listenable: _pricingListenable,
      builder: (context, _) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            _summaryRow(
              AppLocaleKey.externalQuoteCarPriceSummary.tr(),
              '${_fmt.format(_price)} ${AppLocaleKey.sar.tr()}',
            ),
            _summaryRow(
              AppLocaleKey.externalQuoteTaxSummary.tr(),
              '+ ${_fmt.format(_taxAmount)} ${AppLocaleKey.sar.tr()}',
              valueColor: AppColor.greenColor(context),
            ),
            _summaryRow(
              AppLocaleKey.platesValueLabel.tr(),
              '+ ${_fmt.format(_platePrice)} ${AppLocaleKey.sar.tr()}',
            ),
            _summaryRow(AppLocaleKey.externalQuoteQuantitySummary.tr(), '× $_qty'),
            Divider(height: 14.h, color: _primary.withValues(alpha: 0.2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocaleKey.externalQuoteFinalTotal.tr(),
                  style: _t(13, weight: FontWeight.w900),
                ),
                Row(
                  children: [
                    Text(
                      _fmt.format(_total),
                      style: _t(17, color: _primary, weight: FontWeight.w900),
                    ),
                    Gap(4.w),
                    SvgPicture.asset(
                      AppImages.sar,
                      height: 15.h,
                      width: 15.w,
                      colorFilter: ColorFilter.mode(_primary, BlendMode.srcIn),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ListenableBuilder(
                listenable: _pricingListenable,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKey.total.tr(),
                      style: _t(10.5, color: _grey, weight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _fmt.format(_total),
                              style: _t(16, color: _primary, weight: FontWeight.w900),
                            ),
                          ),
                        ),
                        Gap(4.w),
                        SvgPicture.asset(
                          AppImages.sar,
                          height: 13.h,
                          width: 13.w,
                          colorFilter: ColorFilter.mode(_primary, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              flex: 3,
              child: BlocBuilder<AgentCubit, AgentState>(
                buildWhen: (p, c) => p.createOfferStatus != c.createOfferStatus,
                builder: (context, state) {
                  final isLoading = state.createOfferStatus.isLoading;
                  return CustomButton(
                    text: AppLocaleKey.createExternalQuoteBtn.tr(),
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}
