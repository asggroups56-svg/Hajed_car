import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/notification_service.dart';
import 'core/services/services_locator.dart';
import 'core/theme/theme_enum.dart';
import 'firebase_options.dart';

class ServiceInitialize {
  ServiceInitialize._();
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(ThemeEnumAdapter());
    await Hive.openBox('app');
    await ScreenUtil.ensureScreenSize();
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.initialize();
    PaintingBinding.instance.imageCache.maximumSizeBytes = 60 << 20; // 60MB
    PaintingBinding.instance.imageCache.maximumSize = 120;
    await initDependencies();
  }
}
