import 'core/config/app_config.dart';
import 'main.dart' as app_main;

void main() async {
  AppConfig.init(
    appFlavor: AppFlavor.testing,
    appBaseUrl: 'https://delta-asg.com:54513/',
    appBaseImage: 'https://delta-asg.com:54513/MyVirtualDir/',
  );
  app_main.main();
}
