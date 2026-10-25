enum AppFlavor { dev, testing, prod }

class AppConfig {
  static AppFlavor? _flavor;
  static String? _baseUrl;
  static String? _baseImage;
  static void init({
    required AppFlavor appFlavor,
    required String appBaseUrl,
    required String appBaseImage,
  }) {
    _flavor = appFlavor;
    _baseUrl = appBaseUrl;
    _baseImage = appBaseImage;
  }

  static AppFlavor get flavor => _flavor ?? AppFlavor.prod;
  static String get baseUrl => _baseUrl ?? 'https://delta-asg.com:54513/';
  static String get baseImage => _baseImage ?? 'https://delta-asg.com:54513/MyVirtualDir/';
}
