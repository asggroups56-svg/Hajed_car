import '../config/app_config.dart';

class Constants {
  static String get baseUrl => AppConfig.baseUrl;
  static String get baseImage => AppConfig.baseImage;

  // Moyasar payment gateway (test environment)
  // Test keys start with pk_test_ — safe to use on real devices
  static const String moyasarPublishableKey = 'pk_test_jdvdiyDA6PuwzC9dkKsKpuJt8yGmLDWa7KcnJzJt';
  // Apple Pay Merchant ID — must match:
  static const String applePayMerchantId = 'merchant.com.Hajed.car';

  // ─── Moyasar Test Cards (sandbox only) ───────────────────────────────────
  // Use pk_test_ key above. Any future expiry date, any 3-digit CVV.
  //
  // VISA:
  //   4111 1111 1111 1111  → Success
  //   4000 0000 0000 0002  → Requires 3DS
  //
  // Mastercard:
  //   5555 5555 5555 4444  → Success
  //
  // Mada:
  //   4201 3201 1111 1010  → Success
  //   4201 3200 0001 3020  → Failed (unspecified)
  //   4201 3200 0031 1101  → Failed (insufficient funds)
  //
  // Apple Pay (physical iPhone only — no simulator):
  //   Add a REAL card to Wallet, then use these AMOUNTS to trigger results:
  //   200–300 SAR   (20000–30000 halalas)  → Paid / Approved
  //   1000–1100 SAR (100000–110000 halalas)→ Failed (unspecified)
  //   1101–1200 SAR → Insufficient funds
  // ─────────────────────────────────────────────────────────────────────────
}
