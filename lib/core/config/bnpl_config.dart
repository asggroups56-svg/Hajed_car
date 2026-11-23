class BnplConfig {
  // --- Tabby Configuration ---
  static const String tabbyApiKey = 'pk_test_YOUR_TABBY_PUBLIC_KEY'; // Replace with real Public Key
  static const String tabbyMerchantId =
      'merchant.moyasar.test'; // Optional depending on SDK version
  static const String tabbyBaseUrl = 'https://api.tabby.ai/api/v2/';
  // --- Tamara Configuration ---
  static const String tamaraToken = 'YOUR_TAMARA_MERCHANT_KEY'; // Replace with real API Token
  static const String tamaraBaseUrl =
      'https://api-sandbox.tamara.co/'; // Use https://api.tamara.co/ for production
  // --- Common Settings ---
  static const bool isSandbox = true; // Set to false for production
  // URLs for payment result handling
  static const String successUrl = 'https://yourdomain.com/payment-success';
  static const String cancelUrl = 'https://yourdomain.com/payment-cancel';
  static const String failureUrl = 'https://yourdomain.com/payment-failure';
}
