import 'core/config/app_config.dart';
import 'main.dart' as app_main;

void main() async {
  AppConfig.init(
    appFlavor: AppFlavor.prod,
    appBaseUrl: 'https://delta-asg.com:54510/',
    appBaseImage: 'https://delta-asg.com:54510/MyVirtualDir/',
  );
  app_main.main();
}
