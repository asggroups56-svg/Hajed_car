import 'package:car/core/utils/saudi_phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaudiPhoneNumber', () {
    test('normalizes Arabic keyboard digits', () {
      expect(SaudiPhoneNumber.normalize('٠٥٠١٢٣٤٥٦٧'), '0501234567');
    });

    test('normalizes Saudi international prefixes', () {
      expect(SaudiPhoneNumber.normalize('+966501234567'), '0501234567');
      expect(SaudiPhoneNumber.normalize('00966501234567'), '0501234567');
    });

    test('accepts exactly a Saudi mobile number', () {
      expect(SaudiPhoneNumber.isValid('0501234567'), isTrue);
      expect(SaudiPhoneNumber.isValid('050123456'), isFalse);
      expect(SaudiPhoneNumber.isValid('0601234567'), isFalse);
    });
  });
}
