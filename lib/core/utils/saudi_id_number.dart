import 'package:flutter/services.dart';

/// Normalizes and validates Saudi National ID / Iqama numbers (10 digits).
/// Handles ASCII digits as well as Arabic-Indic digits from Arabic keyboards.
class SaudiIdNumber {
  SaudiIdNumber._();

  static const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const _easternArabicIndicDigits = '۰۱۲۳۴۵۶۷۸۹';

  static String normalize(String value) {
    var result = value.trim();
    for (var index = 0; index < 10; index++) {
      result = result
          .replaceAll(_arabicIndicDigits[index], '$index')
          .replaceAll(_easternArabicIndicDigits[index], '$index');
    }
    return result.replaceAll(RegExp(r'\D'), '');
  }

  static bool isValid(String value) {
    final normalized = normalize(value);
    return normalized.length == 10;
  }
}

/// A [TextInputFormatter] that restricts input to at most 10 digits and
/// automatically converts Arabic-Indic digits into ASCII digits.
class SaudiIdInputFormatter extends TextInputFormatter {
  const SaudiIdInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var normalized = SaudiIdNumber.normalize(newValue.text);
    if (normalized.length > 10) {
      normalized = normalized.substring(0, 10);
    }
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(
        offset: newValue.selection.baseOffset.clamp(0, normalized.length),
      ),
    );
  }
}
