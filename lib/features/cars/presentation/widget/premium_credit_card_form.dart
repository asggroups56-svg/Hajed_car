// ignore_for_file: implementation_imports

import 'dart:math';

import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:moyasar/moyasar.dart';
import 'package:moyasar/src/utils/card_network_utils.dart';
import 'package:moyasar/src/utils/card_utils.dart';
import 'package:moyasar/src/utils/input_formatters.dart';
import 'package:moyasar/src/widgets/three_d_s_webview.dart';

class PremiumCreditCardForm extends StatefulWidget {
  final PaymentConfig config;
  final Function(
    dynamic result, {
    required bool isApplePay,
    required String paymentMethod,
  })
  onPaymentResult;
  final bool isArabic;

  const PremiumCreditCardForm({
    super.key,
    required this.config,
    required this.onPaymentResult,
    required this.isArabic,
  });

  @override
  State<PremiumCreditCardForm> createState() => _PremiumCreditCardFormState();
}

class _PremiumCreditCardFormState extends State<PremiumCreditCardForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CardFormModel _cardData = CardFormModel();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final FocusNode _cvcFocusNode = FocusNode();
  bool _showBack = false;
  CardNetwork _detectedNetwork = CardNetwork.unknown;
  bool _unsupportedNetwork = false;

  late Localization _locale;

  String get _paymentMethod {
    switch (_detectedNetwork.name.toLowerCase()) {
      case 'mada':
        return 'mada';
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'amex':
        return 'amex';
      default:
        return 'card';
    }
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.isArabic
        ? const Localization.ar()
        : const Localization.en();
    _cvcFocusNode.addListener(() {
      setState(() {
        _showBack = _cvcFocusNode.hasFocus;
      });
    });

    _cardNumberController.addListener(() {
      final value = _cardNumberController.text.replaceAll(' ', '');
      if (value.length >= 4) {
        final detected = detectNetwork(value);
        setState(() {
          _detectedNetwork = detected;
          if (detected != CardNetwork.unknown) {
            final supported = widget.config.supportedNetworks
                .map((e) => e.name)
                .toSet();
            if (!supported.contains(detected.name)) {
              _unsupportedNetwork = true;
            } else {
              _unsupportedNetwork = false;
            }
          } else {
            _unsupportedNetwork = false;
          }
        });
      } else {
        setState(() {
          _detectedNetwork = CardNetwork.unknown;
          _unsupportedNetwork = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cvcFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_isSubmitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    _formKey.currentState?.save();
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final source = CardPaymentRequestSource(
      creditCardData: _cardData,
      tokenizeCard: widget.config.creditCard?.saveCard ?? false,
      manualPayment: widget.config.creditCard?.manual ?? false,
    );
    final paymentRequest = PaymentRequest(widget.config, source);

    late final dynamic result;
    try {
      result =
          await Moyasar.pay(
            apiKey: widget.config.publishableApiKey,
            paymentRequest: paymentRequest,
          ).timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception(
              widget.isArabic
                  ? 'انتهت مهلة الاتصال. تحقق من الإنترنت وأعد المحاولة.'
                  : 'Connection timed out. Please check your internet and try again.',
            ),
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onPaymentResult(
          ApiError(e.toString()),
          isApplePay: false,
          paymentMethod: _paymentMethod,
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result is! PaymentResponse ||
        result.status != PaymentStatus.initiated) {
      widget.onPaymentResult(
        result,
        isApplePay: false,
        paymentMethod: _paymentMethod,
      );
      return;
    }

    final String transactionUrl =
        (result.source as CardPaymentResponseSource).transactionUrl ?? '';

    if (transactionUrl.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          maintainState: false,
          builder: (context) => ThreeDSWebView(
            transactionUrl: transactionUrl,
            on3dsDone: (String status, String message) async {
              if (status == PaymentStatus.paid.name) {
                result.status = PaymentStatus.paid;
              } else if (status == PaymentStatus.captured.name) {
                result.status = PaymentStatus.captured;
              } else if (status == PaymentStatus.authorized.name) {
                result.status = PaymentStatus.authorized;
              } else {
                result.status = PaymentStatus.failed;
                (result.source as CardPaymentResponseSource).message = message;
              }
              Navigator.pop(context);
              widget.onPaymentResult(
                result,
                isApplePay: false,
                paymentMethod: _paymentMethod,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _showBack ? 180 : 0),
              duration: const Duration(milliseconds: 400),
              builder: (context, angle, child) {
                final isBack = angle >= 90;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle * pi / 180),
                  alignment: Alignment.center,
                  child: isBack
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: _buildCardBack(),
                        )
                      : _buildCardFront(),
                );
              },
            ),
          ),
          Gap(32.h),
          Text(
            _locale.cardInformation,
            style: AppTextStyle.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w900, fontSize: 16.sp),
            textAlign: widget.isArabic ? TextAlign.right : TextAlign.left,
          ),
          Gap(12.h),

          // Card Number Field
          _buildInputField(
            controller: _cardNumberController,
            hintText: _locale.cardNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              CardNumberInputFormatter(),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return _locale.cardNumberRequired;
              if (CardUtils.validateCardNum(v, _locale) != null)
                return _locale.invalidCardNumber;
              if (_unsupportedNetwork) return _locale.unsupportedNetwork;
              return null;
            },
            onSaved: (v) => _cardData.number = CardUtils.getCleanedNumber(v!),
            suffixIcon: _getNetworkIcon(),
          ),
          Gap(16.h),

          _buildInputField(
            controller: _nameController,
            hintText: _locale.nameOnCard,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z. ]')),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return _locale.nameRequired;
              return CardUtils.validateName(v, _locale);
            },
            onSaved: (v) => _cardData.name = v ?? '',
          ),
          Gap(16.h),

          // Expiry and CVC Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _expiryController,
                  hintText: '${_locale.expiry} (MM/YY)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    CardMonthInputFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return _locale.expiryRequired;
                    return CardUtils.validateDate(
                      v.replaceAll('\u200E', ''),
                      _locale,
                    );
                  },
                  onSaved: (v) {
                    final clean = v!.replaceAll('\u200E', '');
                    final expiryDate = CardUtils.getExpiryDate(clean);
                    _cardData.month = expiryDate.first.replaceAll('\u200E', '');
                    _cardData.year = expiryDate[1].replaceAll('\u200E', '');
                  },
                ),
              ),
              Gap(16.w),
              Expanded(
                child: _buildInputField(
                  controller: _cvcController,
                  focusNode: _cvcFocusNode,
                  hintText: _locale.cvc,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return _locale.cvcRequired;
                    return CardUtils.validateCVC(v, _locale);
                  },
                  onSaved: (v) => _cardData.cvc = v ?? '',
                ),
              ),
            ],
          ),
          Gap(32.h),

          // Pay Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor(context),
              disabledBackgroundColor: AppColor.primaryColor(
                context,
              ).withValues(alpha: 0.5),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 4,
              shadowColor: AppColor.primaryColor(
                context,
              ).withValues(alpha: 0.3),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: CircularProgressIndicator(
                      color: AppColor.whiteColor(context),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_locale.pay} ',
                        style: AppTextStyle.buttonStyle(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        (widget.config.amount / 100).toStringAsFixed(2),
                        style: AppTextStyle.buttonStyle(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Gap(4.w),
                      Text(
                        widget.isArabic ? 'ر.س' : 'SAR',
                        style: AppTextStyle.buttonStyle(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
          ),
          Gap(16.h),

          // Security Notice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColor.greenColor(context),
                size: 14.sp,
              ),
              Gap(6.w),
              Text(
                widget.isArabic
                    ? 'دفع إلكتروني آمن ومشفّر 100%'
                    : '100% Secure & Encrypted Payment',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.greenColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          Gap(12.h),

          // Moyasar Logo Branding
          Center(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/moyasarlogo.png',
                package: 'moyasar',
                height: 18.h,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onSaved: onSaved,
        textDirection: TextDirection.ltr,
        textAlign: widget.isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.blackTextColor(context),
        ),
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(
            fontSize: 12.sp,
            color: AppColor.greyColor(context),
          ),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColor.borderColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColor.borderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: AppColor.primaryColor(context),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget? _getNetworkIcon() {
    String assetName = '';
    switch (_detectedNetwork) {
      case CardNetwork.visa:
        assetName = 'assets/images/visa.png';
        break;
      case CardNetwork.masterCard:
        assetName = 'assets/images/mastercard.png';
        break;
      case CardNetwork.mada:
        assetName = 'assets/images/mada.png';
        break;
      case CardNetwork.amex:
        assetName = 'assets/images/amex.png';
        break;
      case CardNetwork.unionPay:
        assetName = 'assets/images/unionpay.png';
        break;
      default:
        return null;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      child: Image.asset(
        assetName,
        package: 'moyasar',
        height: 20.h,
        errorBuilder: (c, e, s) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCardFront() {
    final number = _cardNumberController.text.isEmpty
        ? '••••  ••••  ••••  ••••'
        : _cardNumberController.text;
    final name = _nameController.text.isEmpty
        ? (widget.isArabic ? 'الاسم على البطاقة' : 'CARDHOLDER NAME')
        : _nameController.text.toUpperCase();
    final expiry = _expiryController.text.isEmpty
        ? 'MM/YY'
        : _expiryController.text;

    return Container(
      width: double.infinity,
      height: 190.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141E30).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chip and Brand Logo Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Golden metallic chip
              Container(
                width: 42.w,
                height: 32.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10.w,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 1, color: Colors.black26),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 1, color: Colors.black26),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 10.h,
                      child: Container(height: 1, color: Colors.black26),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10.h,
                      child: Container(height: 1, color: Colors.black26),
                    ),
                  ],
                ),
              ),

              // Network Logo (Visa/Mastercard/Mada)
              if (_detectedNetwork != CardNetwork.unknown) ...[
                Image.asset(
                  _detectedNetwork == CardNetwork.visa
                      ? 'assets/images/visa.png'
                      : _detectedNetwork == CardNetwork.masterCard
                      ? 'assets/images/mastercard.png'
                      : _detectedNetwork == CardNetwork.mada
                      ? 'assets/images/mada.png'
                      : _detectedNetwork == CardNetwork.amex
                      ? 'assets/images/amex.png'
                      : 'assets/images/unionpay.png',
                  package: 'moyasar',
                  height: 28.h,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ] else ...[
                Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white70,
                  size: 28.sp,
                ),
              ],
            ],
          ),

          // Card Number Text
          Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Cardholder name and Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'حامل البطاقة' : 'CARDHOLDER',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.isArabic ? 'تاريخ الانتهاء' : 'VALID THRU',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    expiry,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    final cvc = _cvcController.text.isEmpty ? '•••' : _cvcController.text;
    return Container(
      width: double.infinity,
      height: 190.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF243B55), Color(0xFF141E30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141E30).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap(24.h),
          // Magnetic strip
          Container(height: 40.h, color: Colors.black87),
          Gap(20.h),
          // Signature strip and CVC
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36.h,
                    color: Colors.white.withValues(alpha: 0.8),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10.w),
                    child: Text(
                      _nameController.text.toUpperCase(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  width: 50.w,
                  height: 36.h,
                  color: const Color(0xFFF39C12),
                  alignment: Alignment.center,
                  child: Text(
                    cvc,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              widget.isArabic
                  ? 'تم إصدار هذه البطاقة للعمليات الإلكترونية الآمنة.'
                  : 'This card is issued for secure electronic transactions.',
              style: TextStyle(color: Colors.white24, fontSize: 8.sp),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
