import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart' as admin;
import 'package:car/features/admin/data/model/representative_model.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/cars/presentation/screen/financing_info_screen.dart';
import 'package:car/features/cars/presentation/screen/reservation_success_screen.dart';
import 'package:car/features/cars/presentation/widget/buying_faq_section_widget.dart';
import 'package:car/features/cars/presentation/widget/car_summary_card_widget.dart';
import 'package:car/features/cars/presentation/widget/otp_bottom_sheet.dart';
import 'package:car/features/cars/presentation/widget/pricing_details_bottom_sheet.dart';
import 'package:car/features/cars/presentation/widget/reservation_information_step.dart';
import 'package:car/features/cars/presentation/widget/reservation_method_selection.dart';
import 'package:car/features/cars/presentation/widget/reservation_payment_body.dart';
import 'package:car/features/cars/presentation/widget/reservation_sticky_footer.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/add_booking_permission_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/data/model/send_whatsapp_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:moyasar/moyasar.dart';

enum ReservationScreenStep { methodSelection, informationEntry, payment }

class CarReservationScreen extends StatefulWidget {
  final GetBrandCarsDataModel car;
  final bool isFromLink;
  const CarReservationScreen({super.key, required this.car, this.isFromLink = false});
  @override
  State<CarReservationScreen> createState() => _CarReservationScreenState();
}

class _CarReservationScreenState extends State<CarReservationScreen> {
  ReservationScreenStep _currentStep = ReservationScreenStep.methodSelection;
  String? _selectedMethod;
  bool _isLoading = false;
  final _infoFormKey = GlobalKey<FormState>();
  final TextEditingController _cashNameController = TextEditingController();
  final TextEditingController _cashPhoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _financePhoneController = TextEditingController();
  final ValueNotifier<bool> _whatsappNotifier = ValueNotifier(true);
  final ValueNotifier<String?> _selectedCityNotifier = ValueNotifier('الرياض');
  double _totalPrice = 0.0;
  final double _depositAmount = 500.0;
  late Map<String, dynamic> _errorCodes;
  late Map<String, dynamic> _moraErrorCodes;
  String? _expectedOtp;
  bool _isOtpSheetOpen = false;
  RepresentativeModel? _selectedRepresentative;
  @override
  void initState() {
    super.initState();
    _totalPrice = _parsePrice(widget.car.price, withTax: true);
    _loadErrorCodes();

    final fullName = HiveMethods.getname() ?? '';
    final phone = HiveMethods.getphone() ?? '';

    _cashNameController.text = fullName;
    _cashPhoneController.text = phone;

    final names = fullName.trim().split(' ');
    if (names.isNotEmpty && fullName.isNotEmpty) {
      _firstNameController.text = names.first;
      _lastNameController.text = names.length > 1 ? names.sublist(1).join(' ') : '';
    }
    _financePhoneController.text = phone;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminCubit>().searchRepresentatives(null);
    });
  }

  Future<void> _loadErrorCodes() async {
    final String data = await rootBundle.loadString('assets/payment_error_codes.json');
    final String moraData = await rootBundle.loadString('assets/mora_sms_error_codes.json');
    setState(() {
      _errorCodes = jsonDecode(data);
      _moraErrorCodes = jsonDecode(moraData);
    });
  }

  double _parsePrice(dynamic price, {bool withTax = false}) {
    if (price == null) return 0.0;
    double value;
    if (price is num) {
      value = price.toDouble();
    } else if (price is String) {
      final clean = price.replaceAll(RegExp(r'[^0-9.]'), '');
      value = double.tryParse(clean) ?? 0.0;
    } else {
      value = 0.0;
    }
    if (!value.isFinite) value = 0.0;
    final double vatSerial = double.tryParse(HiveMethods.getVatNumber().toString()) ?? 15.0;
    final result = withTax ? value * ((100 + vatSerial) / 100) : value;
    return _round2(result);
  }

  double _round2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  bool get _isFinancingFlow => _selectedMethod == 'tamara' || _selectedMethod == 'bank';
  @override
  void dispose() {
    _cashNameController.dispose();
    _cashPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _financePhoneController.dispose();
    _whatsappNotifier.dispose();
    _selectedCityNotifier.dispose();
    super.dispose();
  }

  bool _isTermsAccepted = false;

  void _handleContinue() {
    if (_selectedMethod == null) return;
    if (_isFinancingFlow) {
      final double basePrice = _parsePrice(widget.car.price, withTax: false);
      final double basePriceWithFinancingFee = basePrice + 3000;
      final double vatSerial = double.tryParse(HiveMethods.getVatNumber().toString()) ?? 15.0;
      final double financingTotalPriceWithTax =
          basePriceWithFinancingFee * ((100 + vatSerial) / 100);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinancingInfoScreen(
            car: widget.car,
            paymentMethod: _selectedMethod!,
            totalPrice: financingTotalPriceWithTax,
          ),
        ),
      );
    } else {
      if (_currentStep == ReservationScreenStep.methodSelection) {
        setState(() => _currentStep = ReservationScreenStep.informationEntry);
      } else {
        if (!_infoFormKey.currentState!.validate()) return;
        if (!_isTermsAccepted) {
          CommonMethods.showToast(
            message: context.locale.languageCode == 'ar'
                ? 'يرجى الموافقة على الشروط والأحكام أولاً قبل الإنتقال للدفع'
                : 'Please accept the Terms & Conditions before proceeding to payment',
            type: ToastType.error,
          );
          return;
        }
        context.read<HomeCubit>().sendOtp(SendOtpModel(mobileNumber: _cashPhoneController.text));
      }
    }
  }

  void _navigateToSuccess() {
    context.read<CartCubit>().loadReservedCars();
    context.read<FavoritesCubit>().removeFromFavorites(
      widget.car.itemName,
      itemCode: widget.car.itemCode.toString(),
      chassisNo: widget.car.chassisNo,
    );
    HiveMethods.removeFromRecentlyViewed(widget.car.itemName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationSuccessScreen(car: widget.car, paymentMethod: _selectedMethod!),
      ),
    );
  }

  void _showPricingDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: false,
      useSafeArea: false,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          child: PricingDetailsBottomSheet(car: widget.car, totalPrice: _totalPrice),
        ),
      ),
    );
  }

  void _showOtpSheet() {
    if (_isOtpSheetOpen) return;
    _isOtpSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: OtpBottomSheet(
            phoneNumber: _cashPhoneController.text,
            homeCubit: context.read<HomeCubit>(),
            expectedOtp: _expectedOtp,
            onVerified: () {
              Navigator.pop(ctx);
              setState(() => _currentStep = ReservationScreenStep.payment);
            },
          ),
        ),
      ),
    ).then((_) {
      _isOtpSheetOpen = false;
    });
  }

  void _handlePaymentResult(dynamic result, {required bool isApplePay}) {
    if (result is PaymentResponse) {
      if (result.status == PaymentStatus.paid ||
          result.status == PaymentStatus.captured ||
          result.status == PaymentStatus.authorized) {
        // final isArabic = context.locale.languageCode == 'ar';
        // String? rawMsg;
        // if (isApplePay && result.source is ApplePayPaymentResponseSource) {
        //   rawMsg = (result.source as ApplePayPaymentResponseSource).message;
        // } else if (!isApplePay && result.source is CardPaymentResponseSource) {
        //   rawMsg = (result.source as CardPaymentResponseSource).message;
        // }
        // final statusName = result.status.name;

        // final translated = _translateRawMessage(rawMsg ?? '');
        // final displayMsg = isArabic
        //     ? '$translated\nالحالة: $statusName | الرسالة: ${rawMsg ?? "—"}| رقم الطلب: ${result.id}'
        //     : '$translated\nStatus: $statusName | Msg: ${rawMsg ?? "—"}';
        // CommonMethods.showToast(message: displayMsg, type: ToastType.success, seconds: 5);
        _submitPayment(paymentId: result.id);
      } else {
        final isArabic = context.locale.languageCode == 'ar';
        String? rawMsg;
        if (isApplePay && result.source is ApplePayPaymentResponseSource) {
          rawMsg = (result.source as ApplePayPaymentResponseSource).message;
        } else if (!isApplePay && result.source is CardPaymentResponseSource) {
          rawMsg = (result.source as CardPaymentResponseSource).message;
        } else if (!isApplePay && result.source is StcResponseSource) {
          rawMsg = (result.source as StcResponseSource).message;
        }
        final statusName = result.status.name;

        final translated = _translateRawMessage(rawMsg ?? '');
        final displayMsg = isArabic
            ? '$translated (الحالة: $statusName)'
            : '$translated (Status: $statusName)';
        CommonMethods.showToast(message: displayMsg, type: ToastType.error);
      }
    }
  }

  String _translateRawMessage(String message) {
    final isArabic = context.locale.languageCode == 'ar';
    final lang = isArabic ? 'ar' : 'en';
    final msg = message.toLowerCase();
    for (final entry in _errorCodes.entries) {
      final enText = (entry.value['en'] as String).toLowerCase();
      if (msg.contains(enText) || enText.contains(msg)) {
        final code = entry.key;
        final translation = entry.value[lang];
        return isArabic ? '$translation (رمز: $code)' : '$translation (Code: $code)';
      }
    }
    return isArabic ? 'فشل الدفع $message ' : 'Payment failed';
  }

  void _showMoraToast(String code, bool isArabic) {
    final lang = isArabic ? 'ar' : 'en';
    if (_moraErrorCodes.containsKey(code)) {
      final msg = _moraErrorCodes[code][lang];
      CommonMethods.showToast(
        message: msg,
        type: code == "100" ? ToastType.success : ToastType.error,
      );
    }
  }

  void _submitPayment({String? paymentId}) {
    if (mounted) setState(() => _isLoading = true);
    final todayStr = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
    final futureStr = DateFormat(
      'yyyy-MM-dd',
      'en',
    ).format(DateTime.now().add(const Duration(days: 1)));
    final storeCodeVal = int.tryParse(widget.car.storeCode) ?? 1;
    final code = HiveMethods.getcode() ?? '';
    final represCode =
        _selectedRepresentative?.represNo ??
        int.tryParse(HiveMethods.getRepresentativeNo() ?? '') ??
        0;
    final model = AddBookingPermissionModel(
      lpoNos: '',
      lpono: '',
      listNo: 0,
      analytical: '',
      customerNo: int.tryParse(code) ?? 0,
      represCode: represCode,
      fDate: todayStr,
      lDate: futureStr,
      lpoDate: todayStr,
      storeCode: storeCodeVal,
      taamedNo: '',
      payCond: '',
      guarFinal: 0,
      notes: 'حجز سيارة كاش - (${_cashPhoneController.text})',
      userAdd: (HiveMethods.getUserName() ?? '').substring(
        0,
        (HiveMethods.getUserName() ?? '').length.clamp(0, 50),
      ),
      requiredDoc: paymentId != null
          ? paymentId.toString().substring(0, paymentId.toString().length.clamp(0, 50))
          : '',
      subLpo: [
        SubLpoModel(
          itemCode: widget.car.itemCode,
          itemName: widget.car.itemName.substring(0, widget.car.itemName.length.clamp(0, 100)),
          chassisNo: widget.car.chassisNo.substring(0, widget.car.chassisNo.length.clamp(0, 50)),
          price: _parsePrice(widget.car.price, withTax: false),
          advancedAmount: _depositAmount,
          storeCode: storeCodeVal,
          TAX_VAL: _round2(
            _parsePrice(widget.car.price, withTax: true) -
                _parsePrice(widget.car.price, withTax: false),
          ),
        ),
      ],
    );
    context.read<HomeCubit>().getAddBookingPermission(model);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final isMethodSelection = _currentStep == ReservationScreenStep.methodSelection;
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) =>
              previous.addBookingPermissionResponseModel !=
              current.addBookingPermissionResponseModel,
          listener: (context, state) {
            final status = state.addBookingPermissionResponseModel;
            if (status.isSuccess) {
              setState(() => _isLoading = false);
              context.read<CartCubit>().rememberReservationStart(
                admin.CarModel(
                  itemCode: widget.car.itemCode,
                  itemName: widget.car.itemName,
                  storeCode: widget.car.storeCode.toString(),
                  costPrice: widget.car.price is num ? (widget.car.price as num).toDouble() : null,
                ),
                reservedAt: DateTime.now(),
              );
              if (_whatsappNotifier.value) {
                final phone = _cashPhoneController.text.trim();
                final bookingNo = status.data?.lpoNo ?? '';
                final textMsg =
                    'حجز سيارة: ${widget.car.itemName}\n'
                    'رقم الحجز: ${bookingNo.isNotEmpty ? bookingNo : ''}\n'
                    'رقم السيارة: ${widget.car.itemCode}\n'
                    'المبلغ الإجمالي: $_totalPrice ر.س\n'
                    'العربون: $_depositAmount ر.س\n';
                context.read<HomeCubit>().sendWhatsApp(
                  SendWhatsAppModel(
                    toNumber: phone,
                    text: textMsg,
                    fileUrl: bookingNo.isNotEmpty
                        ? 'https://delta-asg.com:54510/files/$bookingNo.pdf'
                        : null,
                    fileName: bookingNo.isNotEmpty ? '$bookingNo.pdf' : null,
                  ),
                );
              }
              // Notification is handled exclusively by FCM push endpoint
              _navigateToSuccess();
            } else if (status.isFailure) {
              setState(() => _isLoading = false);
              final serverMsg = status.message;
              final displayMessage = isArabic
                  ? 'فشل الحجز: ${serverMsg ?? "يرجى المحاولة مرة أخرى"}'
                  : 'Reservation failed: ${serverMsg ?? "please try again"}';
              CommonMethods.showToast(message: displayMessage, type: ToastType.error);
            }
          },
        ),
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) => previous.sendOtpStatus != current.sendOtpStatus,
          listener: (context, state) {
            final status = state.sendOtpStatus;
            if (status.isLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
              if (status.isSuccess && status.data != null) {
                _expectedOtp = status.data!.message;
                final moraResponse = status.data!.moraResponse;
                if (moraResponse != null) {
                  final code = moraResponse.data.code.toString();
                  _showMoraToast(code, isArabic);
                  if (code == "100") {
                    _showOtpSheet();
                  }
                } else {
                  if (status.data!.success) {
                    _showOtpSheet();
                  } else {
                    CommonMethods.showToast(
                      message: '${status.data!.message ?? ''}',
                      type: ToastType.error,
                    );
                  }
                }
              } else if (status.isFailure) {
                CommonMethods.showToast(
                  message: status.message ?? (isArabic ? 'حدث خطأ' : 'An error occurred'),
                  type: ToastType.error,
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        appBar: AppBar(
          title: Text(
            isMethodSelection ? AppLocaleKey.agentSelectPaymentMethod.tr() : widget.car.itemName,
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16.sp,
              color: isMethodSelection
                  ? AppColor.blackTextColor(context)
                  : AppColor.primaryColor(context),
            ),
          ),
          backgroundColor: AppColor.appBarColor(context),
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocaleKey.agentCancel.tr(),
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),
          ],
          leading: isMethodSelection
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: AppColor.blackTextColor(context)),
                  onPressed: () {
                    if (_currentStep == ReservationScreenStep.payment) {
                      setState(() => _currentStep = ReservationScreenStep.informationEntry);
                    } else {
                      setState(() => _currentStep = ReservationScreenStep.methodSelection);
                    }
                  },
                ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMethodSelection) ...[
                CarSummaryCard(car: widget.car, totalPrice: _totalPrice),
                Gap(24.h),
                ReservationMethodSelection(
                  selectedMethod: _selectedMethod,
                  onMethodChanged: (v) => setState(() => _selectedMethod = v),
                ),
                Gap(40.h),
                const BuyingFaqSection(),
              ] else if (_currentStep == ReservationScreenStep.payment) ...[
                ReservationPaymentBody(
                  car: widget.car,
                  totalPrice: _totalPrice,
                  depositAmount: _depositAmount,
                  isLoading: _isLoading,
                  onPaymentResult: _handlePaymentResult,
                ),
              ] else ...[
                ReservationInformationStep(
                  car: widget.car,
                  isFinancingFlow: _isFinancingFlow,
                  totalPrice: _totalPrice,
                  depositAmount: _depositAmount,
                  formKey: _infoFormKey,
                  cashNameController: _cashNameController,
                  cashPhoneController: _cashPhoneController,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  financePhoneController: _financePhoneController,
                  whatsappNotifier: _whatsappNotifier,
                  selectedCityNotifier: _selectedCityNotifier,
                  selectedRepresentative: _selectedRepresentative,
                  onRepresentativeChanged: (representative) {
                    setState(() => _selectedRepresentative = representative);
                  },
                  onShowPricingDetails: _showPricingDetails,
                  isTermsAccepted: _isTermsAccepted,
                  onTermsAcceptedChanged: (val) => setState(() => _isTermsAccepted = val ?? false),
                ),
              ],
              Gap(100.h),
            ],
          ),
        ),
        bottomNavigationBar: ReservationStickyFooter(
          currentStep: _currentStep,
          selectedMethod: _selectedMethod,
          isFinancingFlow: _isFinancingFlow,
          depositAmount: _depositAmount,
          onContinue: _handleContinue,
        ),
      ),
    );
  }
}
