import 'package:flutter/services.dart';

/// Normalizes Saudi mobile numbers regardless of the keyboard used to enter
/// them. Some Arabic keyboards produce Arabic-Indic digits, which an API that
/// expects ASCII digits will reject.
class SaudiPhoneNumber {
  SaudiPhoneNumber._();

  static const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const _easternArabicIndicDigits = '۰۱۲۳۴۵۶۷۸۹';

  static String normalize(String value) {
    var result = value.trim();
    for (var index = 0; index < 10; index++) {
      result = result
          .replaceAll(_arabicIndicDigits[index], '$index')
          .replaceAll(_easternArabicIndicDigits[index], '$index');
    }

    result = result.replaceAll(RegExp(r'[\s\-()+]'), '');
    if (result.startsWith('00966')) result = '0${result.substring(5)}';
    if (result.startsWith('966')) {
      result = '0${result.substring(3)}';
    }
    return result;
  }

  static bool isValid(String value) =>
      RegExp(r'^05\d{8}$').hasMatch(normalize(value));
}

/// Converts Arabic-Indic digits while typing, so the stored value and the
/// value sent to the OTP and reservation services are always ASCII digits.
class SaudiPhoneInputFormatter extends TextInputFormatter {
  const SaudiPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = SaudiPhoneNumber.normalize(newValue.text);
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(
        offset: newValue.selection.baseOffset.clamp(0, normalized.length),
      ),
    );
  }
}
