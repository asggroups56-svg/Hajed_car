import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/data/repository/home_repo.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:share_plus/share_plus.dart';

import '../routes/app_routers_import.dart';

/// خدمة إدارة الروابط العميقة (Deep Linking) المجانية 100% بدون أي وسيط مدفوع.
///
/// الاستراتيجية:
/// 1. الروابط المباشرة (App Links / Universal Links):
///    - أندرويد: https://delta-asg.com/car/{id} عبر assetlinks.json
///    - آيفون: https://delta-asg.com/car/{id} عبر apple-app-site-association
///    - Custom Scheme: hbwcars://car/{id}
/// 2. الـ Deferred لأندرويد (تثبيت جديد من المتجر):
///    - قراءة Google Play Install Referrer واستخراج car_id فور أول فتح.
/// 3. الـ Deferred لـ iOS (تثبيت جديد من المتجر):
///    - فحص الـ Clipboard فور أول فتح بعد التثبيت لمعرفة السيارة المحالة من صفحة الويب.
/// 4. المشاركة:
///    - توليد رابط رسمي نظيف: https://delta-asg.com/car/{id}
class DeepLinkService {
  DeepLinkService._();

  static const String _webDomain = 'https://delta-asg.com';
  static const String _customScheme = 'hbwcars';

  static const String _boxKeyCheckedReferrer = 'has_checked_install_referrer';
  static const String _boxKeyCheckedIosClip = 'has_checked_ios_clipboard';

  static StreamSubscription? _appLinksSubscription;
  static final AppLinks _appLinks = AppLinks();
  static bool _isInitialized = false;
  static bool _isNavigatorReady = false;
  static GetBrandCarsDataModel? _pendingCar;
  static String? _pendingCarId;
  static int? _pendingFromMakeYear;
  static int? _pendingColorCode;
  static String? _lastHandledId;
  static DateTime? _lastHandledTime;

  /// رابط صفحة الويب للسيارة (نظيف وبدون مسافات، مع إرفاق سنة الصنع وكود اللون)
  static String getCarWebUrl(
    String carId, {
    int? makeYear,
    int? colorCode,
  }) {
    final cleanId = Uri.encodeComponent(carId.trim());
    final queryParams = <String, String>{
      if (makeYear != null && makeYear > 0) 'frommakeyear': makeYear.toString(),
      if (colorCode != null && colorCode > 0) 'color_code': colorCode.toString(),
    };

    if (queryParams.isEmpty) {
      return '$_webDomain/car/$cleanId';
    }
    return Uri.parse('$_webDomain/car/$cleanId')
        .replace(queryParameters: queryParams)
        .toString();
  }

  /// رابط التطبيق المباشر (Custom Scheme) مع البارامترات
  static String getCarCustomSchemeUrl(
    String carId, {
    int? makeYear,
    int? colorCode,
  }) {
    final cleanId = Uri.encodeComponent(carId.trim());
    final queryParams = <String, String>{
      if (makeYear != null && makeYear > 0) 'frommakeyear': makeYear.toString(),
      if (colorCode != null && colorCode > 0) 'color_code': colorCode.toString(),
    };

    if (queryParams.isEmpty) {
      return '$_customScheme://car/$cleanId';
    }
    return Uri.parse('$_customScheme://car/$cleanId')
        .replace(queryParameters: queryParams)
        .toString();
  }

  /// تهيئة الإنصات للروابط العميقة والـ Deferred Deep Links
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. الاستماع للروابط المباشرة (App Links / Universal Links / Custom Scheme)
    try {
      // الرابط عند الفتح المباشر وهو مغلق (Cold Start)
      final initialUri = await _appLinks.getInitialLink();
      debugPrint('[DL] initial link: $initialUri');
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }

      // الإنصات للروابط الواردة أثناء تشغيل التطبيق في الخلفية
      _appLinksSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('[DL] stream link: $uri');
          _handleIncomingUri(uri);
        },
        onError: (err) {
          debugPrint('[DL] AppLinks stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('[DeepLinkService] AppLinks init error: $e');
    }

    // 2. فحص الـ Deferred Deep Link لأندرويد (Play Install Referrer)
    if (Platform.isAndroid) {
      unawaited(_checkAndroidInstallReferrer());
    }

    // 3. فحص الـ Deferred Deep Link لـ iOS (Clipboard Check عند أول فتح)
    if (Platform.isIOS) {
      unawaited(_checkIosClipboardDeferred());
    }

    // 4. مؤقت أمان لضمان جاهزية الـ Navigator حتى لو لم تستدعه SplashScreen
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!_isNavigatorReady) {
        markNavigatorReady();
      }
    });
  }

  /// فحص Google Play Install Referrer (Android Deferred Deep Linking)
  static Future<void> _checkAndroidInstallReferrer() async {
    try {
      final box = Hive.box('app');
      final alreadyChecked = box.get(_boxKeyCheckedReferrer, defaultValue: false);
      if (alreadyChecked) return;

      final ReferrerDetails referrerDetails =
          await PlayInstallReferrer.installReferrer;

      final referrerUrl = referrerDetails.installReferrer;
      debugPrint('[DeepLinkService] Google Play Referrer: $referrerUrl');

      if (referrerUrl != null && referrerUrl.isNotEmpty) {
        // فك تشفير وتفسير الـ query parameters القادمة من المتجر
        final decoded = Uri.decodeComponent(referrerUrl);
        String? carId;

        // بحث عن car_id=123 أو car=123 أو utm_content=123
        final params = Uri.splitQueryString(decoded);
        carId = params['car_id'] ??
            params['carId'] ??
            params['car'] ??
            params['id'] ??
            params['utm_content'];

        if (carId == null) {
          // محاولة استخراج الرقم بالـ Regex إذا كانت القيمة ممررة بنمط مباشر
          final match = RegExp(r'(?:car|id)[=_/:](\w+)').firstMatch(decoded);
          if (match != null) {
            carId = match.group(1);
          }
        }

        if (carId != null && carId.trim().isNotEmpty) {
          debugPrint('[DeepLinkService] Deferred Car found from Play Store: $carId');
          await handleIncomingCarId(carId.trim());
        }
      }

      await box.put(_boxKeyCheckedReferrer, true);
    } catch (e) {
      debugPrint('[DeepLinkService] Install Referrer check error: $e');
    }
  }

  /// فحص الـ Clipboard عند أول فتح بعد التثبيت (iOS Deferred Deep Linking)
  static Future<void> _checkIosClipboardDeferred() async {
    try {
      final box = Hive.box('app');
      final alreadyChecked = box.get(_boxKeyCheckedIosClip, defaultValue: false);
      if (alreadyChecked) return;

      // قراءة الحافظة
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text != null && text.isNotEmpty) {
        String? carId;

        // فحص ما إذا كان النص رابط للسيارة من التطبيق أو الموقع
        if (text.startsWith('hbwcars://') || text.contains('delta-asg.com/car/')) {
          final uri = Uri.tryParse(text);
          if (uri != null) {
            final carIndex = uri.pathSegments.indexOf('car');
            if (carIndex != -1 && carIndex + 1 < uri.pathSegments.length) {
              carId = uri.pathSegments[carIndex + 1];
            } else if (uri.host == 'car' && uri.pathSegments.isNotEmpty) {
              carId = uri.pathSegments.first;
            }
          }
        }

        if (carId != null && carId.isNotEmpty) {
          debugPrint('[DeepLinkService] Deferred Car found from iOS Clipboard: $carId');
          // تنظيف الحافظة حتى لا تفتح السيارة في كل مرة
          await Clipboard.setData(const ClipboardData(text: ''));
          await handleIncomingCarId(carId);
        }
      }

      await box.put(_boxKeyCheckedIosClip, true);
    } catch (e) {
      debugPrint('[DeepLinkService] iOS Clipboard deferred check error: $e');
    }
  }

  /// استخراج معرف السيارة من الـ URI المباشر والتوجيه إليها
  static void _handleIncomingUri(Uri uri) {
    debugPrint('[DL] incoming uri: $uri');
    String? carId;

    // حالة: https://delta-asg.com/car/{id}
    if (uri.pathSegments.isNotEmpty) {
      final carIndex = uri.pathSegments.indexOf('car');
      if (carIndex != -1 && carIndex + 1 < uri.pathSegments.length) {
        carId = uri.pathSegments[carIndex + 1];
      }
    }

    // حالة: hbwcars://car/{id}
    if (carId == null && uri.scheme == _customScheme) {
      if (uri.host == 'car' && uri.pathSegments.isNotEmpty) {
        carId = uri.pathSegments.first;
      } else if (uri.pathSegments.contains('car')) {
        final idx = uri.pathSegments.indexOf('car');
        if (idx + 1 < uri.pathSegments.length) {
          carId = uri.pathSegments[idx + 1];
        }
      }
    }

    // Query parameters fallback (?car_id=123 أو ?id=123 أو ?car=123)
    carId ??= uri.queryParameters['car_id'] ??
        uri.queryParameters['carId'] ??
        uri.queryParameters['id'] ??
        uri.queryParameters['car'];

    // Regex fallback
    if (carId == null || carId.isEmpty) {
      final raw = uri.toString();
      final match = RegExp(r'/car[/:=](\w+)').firstMatch(raw);
      if (match != null) {
        carId = match.group(1);
      }
    }

    // استخراج frommakeyear و color_code من الرابط
    final yearStr = uri.queryParameters['frommakeyear'] ??
        uri.queryParameters['year'] ??
        uri.queryParameters['makeYear'];
    final colorStr = uri.queryParameters['color_code'] ??
        uri.queryParameters['colorCode'] ??
        uri.queryParameters['color'];
    final makeYear = int.tryParse(yearStr ?? '');
    final colorCode = int.tryParse(colorStr ?? '');

    if (carId != null && carId.trim().isNotEmpty) {
      final cleanId = carId.trim();
      final now = DateTime.now();
      if (_lastHandledId == cleanId &&
          _lastHandledTime != null &&
          now.difference(_lastHandledTime!).inMilliseconds < 1500) {
        debugPrint('[DeepLinkService] Debounced duplicate URI for car: $cleanId');
        return;
      }
      _lastHandledId = cleanId;
      _lastHandledTime = now;
      handleIncomingCarId(
        cleanId,
        fromMakeYear: makeYear,
        colorCode: colorCode,
      );
    }
  }

  /// استخراج معرّف نظيف وآمن وصالح للروابط (بدون مسافات أو رموز خاصة)
  static String resolveSafeCarId(GetBrandCarsDataModel car) {
    if (car.itemCode.trim().isNotEmpty && car.itemCode.trim() != '0') {
      return car.itemCode.trim();
    }
    if (car.chassisNo.trim().isNotEmpty &&
        car.chassisNo.trim() != '0' &&
        car.chassisNo.trim().toLowerCase() != 'null') {
      return car.chassisNo.trim();
    }
    if (car.groupCode > 0) {
      return car.groupCode.toString();
    }
    if (car.groupCode1 > 0) {
      return car.groupCode1.toString();
    }
    final unique = HiveMethods.getCarUniqueId(car.toMap());
    final safe = unique.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return safe.replaceAll(RegExp(r'_+'), '_');
  }

  /// إنشاء رابط المشاركة الرسمي المباشر للسيارة
  static String createCarShareLink(GetBrandCarsDataModel car) {
    final carId = resolveSafeCarId(car);
    return getCarWebUrl(
      carId,
      makeYear: car.makeYear > 0 ? car.makeYear : null,
      colorCode: car.colorCode > 0 ? car.colorCode : null,
    );
  }

  /// مشاركة السيارة عبر نافذة المشاركة الرسمية في النظام (share_plus).
  static Future<void> shareCar(GetBrandCarsDataModel car) async {
    final title = '${car.groupName} - ${car.itemName}';
    final price = car.formattedPriceWithVat;
    final carId = resolveSafeCarId(car);

    await shareCarData(
      carId: carId,
      title: title,
      price: price,
      makeYear: car.makeYear > 0 ? car.makeYear : null,
      colorCode: car.colorCode > 0 ? car.colorCode : null,
    );
  }

  /// مشاركة سيارة المندوب (AgentCar)
  static Future<void> shareAgentCar(dynamic car) async {
    final itemCode = car.itemCode?.toString().trim() ?? '';
    final chassis = car.chassisNo?.toString().trim() ?? '';
    final group = car.groupCode?.toString().trim() ?? '';
    final id = car.id?.toString().trim() ?? '';

    final carId = itemCode.isNotEmpty && itemCode != '0'
        ? itemCode
        : (chassis.isNotEmpty && chassis != '0' && chassis.toLowerCase() != 'null'
            ? chassis
            : (group.isNotEmpty && group != '0' ? group : id));

    final num priceVal = (car.priceWithVat is num)
        ? car.priceWithVat
        : (car.price is num ? car.price : 0);
    final formattedPrice = priceVal > 0 ? priceVal.toInt().toString() : '---';

    final int? yearVal = car.year is int
        ? car.year
        : int.tryParse(car.year?.toString() ?? '');
    final int? colorVal = car.colorCode is int
        ? car.colorCode
        : int.tryParse(car.colorCode?.toString() ?? '');

    await shareCarData(
      carId: carId,
      title: '${car.brand} - ${car.name}',
      price: formattedPrice,
      makeYear: yearVal,
      colorCode: colorVal,
    );
  }

  /// مشاركة بيانات أي سيارة عبر الرابط العميق
  static Future<void> shareCarData({
    required String carId,
    required String title,
    required String price,
    int? makeYear,
    int? colorCode,
  }) async {
    final link = getCarWebUrl(
      carId,
      makeYear: makeYear,
      colorCode: colorCode,
    );

    final shareText = '''
🚗 $title
💰 السعر: $price ريال
تفقد كامل تفاصيل ومواصفات السيارة وخيارات التمويل:
$link
''';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: title,
      ),
    );
  }

  /// إشعار الخدمة بأن شاشة البداية (Splash) أو تسجيل الدخول انتهت والـ Navigator أصبح جاهزاً
  static void markNavigatorReady() {
    _isNavigatorReady = true;
    debugPrint('[DL] markNavigatorReady, pendingCar: ${_pendingCar?.itemName}, pendingId: $_pendingCarId');
    if (_pendingCar != null) {
      final car = _pendingCar!;
      _pendingCar = null;
      _navigateToCar(car);
    } else if (_pendingCarId != null && _pendingCarId!.isNotEmpty) {
      final id = _pendingCarId!;
      final year = _pendingFromMakeYear;
      final color = _pendingColorCode;
      _pendingCarId = null;
      _pendingFromMakeYear = null;
      _pendingColorCode = null;
      handleIncomingCarId(
        id,
        fromMakeYear: year,
        colorCode: color,
      );
    }
  }

  /// إعادة فحص الروابط المعلقة بعد نجاح تسجيل الدخول
  static void flushPendingAfterLogin() {
    markNavigatorReady();
  }

  /// معالجة معرف السيارة القادم من الرابط العميق وفتح شاشة تفاصيلها
  static Future<void> handleIncomingCarId(
    String rawCarId, {
    int? fromMakeYear,
    int? colorCode,
  }) async {
    try {
      debugPrint('[DL] handleIncomingCarId: $rawCarId');
      final decodedId = Uri.decodeComponent(rawCarId).trim();
      final prefixId = decodedId.contains('_') ? decodedId.split('_').first.trim() : '';

      // إذا كان الـ Navigator غير جاهز (شاشة البداية لا تزال تعمل)، احفظ الكود كمعلق وأوقف التنفيذ
      if (!_isNavigatorReady) {
        _pendingCarId = rawCarId;
        _pendingFromMakeYear = fromMakeYear;
        _pendingColorCode = colorCode;
        return; // ← إيقاف: لا تبحث الآن، انتظر markNavigatorReady
      }

      bool matches(GetBrandCarsDataModel c) {
        final itemCode = c.itemCode.toString().trim();
        final chassis = c.chassisNo.trim();
        final groupCode = c.groupCode.toString();
        final groupCode1 = c.groupCode1.toString();
        final uniqueId = HiveMethods.getCarUniqueId(c.toMap());

        bool idMatched = false;
        if (itemCode.isNotEmpty && itemCode != '0' && (itemCode == decodedId || itemCode == prefixId)) {
          idMatched = true;
        } else if (chassis.isNotEmpty && chassis != '0' && chassis.toLowerCase() != 'null' && (chassis == decodedId || chassis == prefixId)) {
          idMatched = true;
        } else if (groupCode.isNotEmpty && groupCode != '0' && (groupCode == decodedId || groupCode == prefixId)) {
          idMatched = true;
        } else if (groupCode1.isNotEmpty && groupCode1 != '0' && (groupCode1 == decodedId || groupCode1 == prefixId)) {
          idMatched = true;
        } else if (uniqueId == decodedId || (prefixId.isNotEmpty && uniqueId.startsWith(prefixId))) {
          idMatched = true;
        } else if (decodedId.length > 5 && c.itemName.isNotEmpty && decodedId.contains(c.itemName)) {
          idMatched = true;
        }

        if (!idMatched) return false;

        // مطابقة سنة الصنع إذا تم تمريرها
        if (fromMakeYear != null && fromMakeYear > 0 && c.makeYear > 0 && c.makeYear != fromMakeYear) {
          return false;
        }
        // مطابقة كود اللون إذا تم تمريره
        if (colorCode != null && colorCode > 0 && c.colorCode > 0 && c.colorCode != colorCode) {
          return false;
        }

        return true;
      }

      // 1. البحث في جميع سيارات الذاكرة بـ HomeCubit
      final homeCubit = sl<HomeCubit>();
      final state = homeCubit.state;
      final inMemoryCars = <GetBrandCarsDataModel>[
        ...?state.allCarsStatus.data,
        ...?state.brandCarsStatus.data,
        ...?state.filteredCarsStatus.data,
        if (state.allPopularCarsStatus.data is Map)
          ...(state.allPopularCarsStatus.data as Map).values.expand((list) => (list as Iterable).whereType<GetBrandCarsDataModel>()),
        ...state.promoCarOffers.map((ad) => ad.toCarDataModel()),
        if (state.financingAdsStatus.data != null)
          ...state.financingAdsStatus.data!.map((ad) => ad.toCarDataModel()),
        if (state.normalFinancingStatus.data != null)
          ...state.normalFinancingStatus.data!.map((ad) => ad.toCarDataModel()),
        if (state.programCarsStatus.data != null)
          ...state.programCarsStatus.data!.map((ad) => ad.toCarDataModel()),
      ];

      GetBrandCarsDataModel? targetCar;
      for (final c in inMemoryCars) {
        if (matches(c)) {
          targetCar = c;
          break;
        }
      }

      // 2. إذا لم تكن في الذاكرة، يتم جلبها من الـ API
      if (targetCar == null) {
        final homeRepo = sl<HomeRepo>();

        // أ) إذا كان الكود يبدأ برقم ماركة محتمل (مثل 1008 لهيونداي أو كود رقمي من 4 خانات فأكثر)
        final potentialBrandId = prefixId.isNotEmpty && prefixId.length >= 4
            ? prefixId.substring(0, 4)
            : (decodedId.length >= 4 && int.tryParse(decodedId.substring(0, 4)) != null
                ? decodedId.substring(0, 4)
                : null);

        if (potentialBrandId != null) {
          final brandCarsRes = await homeRepo.fetchAllCars(
            int.tryParse(potentialBrandId),
            fromMakeYear?.toString(),
            null,
            null,
            null,
            null,
            colorCode,
          );
          brandCarsRes.fold((_) {}, (cars) {
            for (final c in cars) {
              if (matches(c)) {
                targetCar = c;
                break;
              }
            }
          });

          if (targetCar == null) {
            final directRes = await homeRepo.getBrandCars(potentialBrandId);
            directRes.fold((_) {}, (cars) {
              for (final c in cars) {
                if (matches(c)) {
                  targetCar = c;
                  break;
                }
              }
            });
          }
        }

        // ب) فحص عروض التمويل (GetFinancingAds) حيث ترتبط بكود الصنف ITEM_CODE
        if (targetCar == null) {
          final adsRes = await homeRepo.getFinancingAds();
          adsRes.fold((_) {}, (ads) {
            for (final ad in ads) {
              final carFromAd = ad.toCarDataModel();
              if (matches(carFromAd)) {
                targetCar = carFromAd;
                break;
              }
            }
          });
        }

        // ج) فحص التمويل العادي (GetFinancingnormal)
        if (targetCar == null) {
          final normalRes = await homeRepo.getNormalFinancing();
          normalRes.fold((_) {}, (ads) {
            for (final ad in ads) {
              final carFromAd = ad.toCarDataModel();
              if (matches(carFromAd)) {
                targetCar = carFromAd;
                break;
              }
            }
          });
        }

        // د) البحث في سيارات جميع الماركات المسجلة في التطبيق
        if (targetCar == null) {
          final brands = state.brands.isNotEmpty
              ? state.brands
              : (await homeRepo.getCarsModels()).fold((_) => <CarModel>[], (res) => res.cars);

          for (final b in brands) {
            if (targetCar != null) break;
            final res = await homeRepo.getBrandCars(b.groupCode.toString());
            res.fold((_) {}, (cars) {
              for (final c in cars) {
                if (matches(c)) {
                  targetCar = c;
                  break;
                }
              }
            });
          }
        }
      }

      // 3. الانتقال لشاشة تفاصيل السيارة
      if (targetCar != null) {
        debugPrint('[DeepLinkService] Found target car: ${targetCar!.itemName} (groupCode: ${targetCar!.groupCode}, itemCode: ${targetCar!.itemCode})');
        await _navigateToCar(targetCar!);
      } else {
        debugPrint('[DeepLinkService] Car not found with id: $rawCarId (decoded: $decodedId, prefix: $prefixId)');
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Error navigating to car $rawCarId: $e');
    }
  }

  /// الانتقال لشاشة تفاصيل السيارة مع انتظار جاهزية الـ NavigatorState وانتهاء شاشة البداية
  static Future<void> _navigateToCar(GetBrandCarsDataModel targetCar) async {
    debugPrint('[DL] navigating to car: ${targetCar.itemName} (id: ${targetCar.itemCode})');
    // إذا لم تكن شاشة البداية قد أعلنت جاهزية الـ Navigator، احفظها كمعلقة حتى لا تمسحها شاشة الـ Splash
    if (!_isNavigatorReady) {
      _pendingCar = targetCar;
      debugPrint('[DeepLinkService] Navigator not ready yet (Splash/Auth active), pending car saved: ${targetCar.itemName}');
      return;
    }

    _pendingCar = null;
    _pendingCarId = null;

    for (int i = 0; i < 35; i++) {
      final navState = AppRouters.navigatorKey.currentState;
      if (navState != null) {
        debugPrint('[DeepLinkService] Pushing carDetailsScreen for car: ${targetCar.itemName}');
        navState.pushNamed(
          RoutesName.carDetailsScreen,
          arguments: targetCar,
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
    debugPrint('[DeepLinkService] Navigation timeout: NavigatorState was null');
  }

  /// تنظيف الموارد عند إغلاق التطبيق
  static void dispose() {
    _appLinksSubscription?.cancel();
  }
}
