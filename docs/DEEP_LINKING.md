# Deep Linking Setup (app_links)

## 1. Configuration values

Everything is driven by one place in Dart:

`lib/core/services/deep_link_service.dart` → `DeepLinkConfig`

```dart
class DeepLinkConfig {
  static const String webDomain = 'https://delta-asg.com';
  static const String customScheme = 'hajedcar';
  static const String legacyCustomScheme = 'hbwcars';
  static const String carPath = 'car';
  static const String androidPackageName = 'com.Hajed.car';
  static const String iosAppId = '6816629989';
  static const String playStoreUrl = '...com.Hajed.car';
  static const String appStoreUrl = '.../id6816629989';
}
```

Change `webDomain` / `customScheme` there and keep these in sync:

| Place | Value |
| --- | --- |
| `android/app/build.gradle.kts` | `manifestPlaceholders["deepLinkHost"]` / `["deepLinkScheme"]` |
| `android/app/src/main/AndroidManifest.xml` | uses `${deepLinkHost}` / `${deepLinkScheme}` |
| `ios/Runner/Info.plist` | `CFBundleURLSchemes` |
| `ios/Runner/Runner.entitlements` | `applinks:<host>` |
| `web/.well-known/assetlinks.json` | Android package names + SHA-256 fingerprints |
| `web/.well-known/apple-app-site-association` | Team ID + bundle id + `/car/*` |

Supported links:

- `https://delta-asg.com/car/<carId>`
- `https://delta-asg.com/car/` and `https://delta-asg.com/car` (fallback page)
- `hajedcar://car/<carId>`
- `hajedcar:///car/<carId>`
- `hbwcars://car/<carId>` (legacy scheme kept for old shared links)

`www.delta-asg.com` is **not** currently supported: it does not serve
`assetlinks.json` or the AASA file. Add it to the Android intent filter / iOS
entitlements only after the same files are reachable on `www`.

Unsupported links, empty ids, `null`, `0`, and malformed ids are ignored safely.

## 2. How the Dart side works

1. `main.dart` calls `DeepLinkService.init()` once after DI/Hive/Firebase are ready.
2. `app_links.getInitialLink()` handles the killed-app case.
3. On iOS with `UIScene`, the launch URL can arrive after `getInitialLink()`.
   The service polls `getLatestLink()` for ~2.5s as a safety net.
4. `app_links.uriLinkStream` handles running/background links.
5. A cold-start link waits for `DeepLinkService.markNavigatorReady()`, called
   from `MainLayout`, `AgentShell` or `AdminMainLayout` after the shell has
   replaced the splash route. There is no early timer anymore: opening the
   details screen while the splash is still the top route loses it when the
   splash replaces itself with the home layout (that was the "app opens on the
   home page" bug).
6. The pending car id is persisted in Hive (`deep_link_pending_car_id`) as soon
   as a link arrives and cleared only after a successful `push`. If the app is
   killed during the splash or the request fails, it is resumed on the next
   launch (expires after 7 days); an id that is confirmed not to exist is
   cleared.
7. The car id is searched in `HomeCubit` inventory first. Then the exact id is
   requested directly (`GetprandcarsData?id=<id>`, which accepts `GROUP_CODE`),
   then the full inventory (`HomeRepo.fetchAllCars(null, ...)`) and matches
   `ITEM_CODE` / `CHASSIS_NO` / `GROUP_CODE` / `GROUP_CODE1` / unique id.
   Brand-specific and financing-ad lookups remain as fallbacks.
8. Not found / network errors show a localized toast instead of silently
   staying on the home screen.
9. Navigation uses the existing arguments shape: the car model is passed
   directly to `RoutesName.carDetailsScreen`; `AppRouters` also accepts the
   `{'car': car, 'heroTag': null}` map shape.
10. Rapid duplicate links for the same car are ignored for 1.5s, the same car
    is not pushed twice within 3s, and a second link is ignored while one is
    already being resolved.

Car details are public in this app (guests can browse; only reservation asks for
login), so deep links are not blocked behind auth. `flushPendingAfterLogin()` is
kept for future auth-protected links; `LoginScreen` already calls it after a
successful login.

## 3. Android manual steps

### 3.1 SHA-256 fingerprints

Debug keystore:

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```

Release/upload keystore (the path configured in `build.gradle.kts`):

```bash
keytool -list -v \
  -keystore /Users/asgsystems/key.jks \
  -alias upload \
  -storepass 111111 -keypass 111111
```

Google Play App Signing:

1. Play Console → your app → **Test and release** → **App integrity**.
2. Copy the **App signing key certificate** SHA-256 fingerprint.
3. Use that value for installs from Google Play. Use the upload-key fingerprint
   for direct/sideloaded release builds.

The repository file contains every fingerprint this project has used:

| Key | SHA-256 |
| --- | --- |
| Play App Signing (confirm in Play Console) | `2B:AE:22:A6:2C:D3:04:75:6D:32:82:06:78:ED:21:D3:97:4D:48:1B:CD:42:55:A4:07:BE:12:56:79:27:05:23` |
| Upload/release (`key.jks`, alias `upload`) | `D0:EB:87:2E:AC:AE:3C:FF:90:AF:BB:03:2D:6A:22:3E:A1:54:7D:D1:CE:52:5F:EB:31:4C:05:A4:C1:54:C2:1B` |
| Older upload key still present in the live file | `D0:EB:87:2E:AC:AE:3C:FF:90:AF:BB:03:2D:6A:22:3E:A1:54:7D:D1:CE:52:5F:EB:B3:14:C0:5A:4C:15:4C:21` |
| Debug (`~/.android/debug.keystore`) | `63:00:6F:29:99:5A:FB:BD:65:18:29:5C:9C:75:AB:AE:8A:E5:96:43:D3:57:A6:AE:79:5B:08:87:4E:48:88:08` |

> **Important:** the file in the repository is correct, but the live file at
> `https://delta-asg.com/.well-known/assetlinks.json` (checked 2026-11-24) only
> lists `com.Hajed.car` with the **older** upload key. Release/Play builds do
> not verify against that file. Re-deploy the repository file, then re-verify
> with `adb shell pm verify-app-links --re-verify com.Hajed.car`.

Add the Play App Signing SHA-256 if it is different; Play-installed builds are
signed with that key, not with the upload key.

### 3.2 Host the file

The file must be reachable at:

```text
https://delta-asg.com/.well-known/assetlinks.json
```

- HTTPS, no redirects, `Content-Type: application/json`.
- Include every published package name: `com.Hajed.car` (prod),
  `com.Hajed.car.dev` (dev), `com.Hajed.car.testing` (staging).

Verify the server from outside:

```bash
curl -sSI https://delta-asg.com/.well-known/assetlinks.json
# 200, application/json, no Location header
curl -sS https://delta-asg.com/.well-known/assetlinks.json
# body must contain all packages and the current upload key
```

Then on the device:

```bash
adb shell pm set-app-links --package com.Hajed.car 0 all
adb shell pm verify-app-links --re-verify com.Hajed.car
adb shell pm get-app-links com.Hajed.car
# Must print: delta-asg.com: verified
# Android 12+: also check App info → Open by default → Add link
```

### 3.3 Flavors

`applicationIdSuffix` makes the package names:

| Flavor | applicationId |
| --- | --- |
| dev | `com.Hajed.car.dev` |
| staging | `com.Hajed.car.testing` |
| prod | `com.Hajed.car` |

If a flavor needs its own host/scheme, override the placeholders in
`android/app/build.gradle.kts`:

```kotlin
create("staging") {
    dimension = "default"
    applicationIdSuffix = ".testing"
    manifestPlaceholders["deepLinkHost"] = "staging.delta-asg.com"
    manifestPlaceholders["deepLinkScheme"] = "hajedcar.staging"
}
```

Then publish a matching `assetlinks.json` on that host. The Dart parser already
accepts `hajedcar.*` schemes. If you use a completely different domain, also
change `DeepLinkConfig.webDomain`.

### 3.4 The files must be served on port 443 (hard requirement)

Android verifies `https://delta-asg.com/.well-known/assetlinks.json` on **port
443 only**; a custom port such as `:54510` is never used. The same applies to
`/car/<id>`: the shared link has no port.

The `:443` host is an **IIS 10 / ASP.NET Core** site with a different physical
root than `:54510`. Full server-side instructions, including the verified
`web.config` rewrite rules and the IIS/ASP.NET Core pitfalls, are in
[`deploy/iis/README.md`](../deploy/iis/README.md). Files to deploy:

```
<443 site root>\web.config                       (merge the rules)
<443 site root>\wwwroot\deep-links\assetlinks.json
<443 site root>\wwwroot\deep-links\apple-app-site-association.json
<443 site root>\wwwroot\car\index.html
```

Or run the copy helper on the server:

```powershell
.\deploy\iis\deploy-deep-links.ps1 `
  -SiteRoot 'C:\inetpub\wwwroot' `
  -RepoRoot 'C:\path\to\Hajed_car'
```

The rewrite keeps the public URLs extensionless and returns `200` with
`Content-Type: application/json` — no redirects. `/.well-known` is rewritten
to `/deep-links` because ASP.NET Core's default file provider hides
dot-prefixed directories. If URL Rewrite is unavailable, use
[`deploy/aspnet/DeepLinkEndpoints.cs`](../deploy/aspnet/DeepLinkEndpoints.cs).

**Checked 2026-11-25:** the live `/.well-known/*` files return `200`, but
`https://delta-asg.com/car/2531` and `https://delta-asg.com/car/` still return
`404` with an empty body. That is exactly the **black/blank page** users see in
the browser when the app is not installed (and, on Android, when App Links are
not verified the same 404 is what they land on). Deploy `wwwroot/car/index.html`
and the `/car` rewrite (or the ASP.NET endpoints) before shipping.

The live `assetlinks.json` is also stale (checked 2026-11-25): it only lists
`com.Hajed.car` with the old upload + debug keys, so a Play-signed release does
not verify App Links and the https link opens the browser instead of the app.
Re-run the deploy script to publish the repository file (Play App Signing key +
`com.Hajed.car`, `com.Hajed.car.testing`, `com.Hajed.car.dev`), then re-verify:

```powershell
.\deploy\iis\deploy-deep-links.ps1 `
  -SiteRoot 'C:\inetpub\wwwroot' `
  -RepoRoot 'C:\path\to\Hajed_car'
```

The script now copies the three files **and** merges the rewrite rules into the
existing `web.config` (backup first); pass `-SkipWebConfig` to only copy files.
Once `/car/<id>` returns the page, the page's `intent://…;package=com.Hajed.car`
opens the app even when Android App Links are not verified, so this deployment
is what fixes both reported symptoms.

## 4. iOS manual steps

### 4.1 Xcode capabilities

1. Open `ios/Runner.xcworkspace`.
2. Select the Runner target → **Signing & Capabilities**.
3. Confirm **Associated Domains** contains `applinks:delta-asg.com`
   (already in `Runner.entitlements`).
4. Confirm the provisioning profile includes the Associated Domains capability.
5. `CFBundleURLSchemes` in `Info.plist` is already `hajedcar`.

### 4.2 Host the AASA file

`web/.well-known/apple-app-site-association` must be reachable at:

```text
https://delta-asg.com/.well-known/apple-app-site-association
```

- On port **443** (Universal Links never use a custom port), with a valid
  certificate for `delta-asg.com`. See section 3.4 for the IIS/ASP.NET Core
  deployment.
- No `.json` extension.
- HTTPS, no redirects, `Content-Type: application/json`.
- Current values: Team ID `2ZJV9X83AZ`, bundle id `com.Hajed.car`,
  paths `/car` and `/car/*` (both are in the repository file).
- Apple caches the file. For testing, use a developer-mode Associated Domains
  entry (`applinks:delta-asg.com?mode=developer`) or wait for the cache to
  refresh. Universal Links also need a real device/simulator with a signed build.

### 4.3 CocoaPods

After changing `app_links`:

```bash
cd ios
pod install
```

## 5. Web fallback page

File: `web/car/index.html`

- Android → tries `intent://car/<id>#Intent;scheme=hajedcar;...` so the app
  opens when installed; otherwise Chrome follows
  `S.browser_fallback_url` to Google Play. The Play link also carries
  `referrer=car_id=<id>` for the Android Play Install Referrer helper.
- iOS → tries the `hajedcar://` scheme first; if the app does not open, it
  copies the car URL to the clipboard (read by the app on first launch) and
  goes to the real App Store page (`id6816629989`).
- Desktop/other → car id + download buttons + “open in app” button.

The page renders its card immediately, so users never see a blank screen while
the redirect is in progress. Keep `CUSTOM_SCHEME`, `PLAY_STORE_URL` and
`APP_STORE_URL` in sync with `DeepLinkConfig`.

The server must serve `/car/<id>` with this file. Examples:

Firebase Hosting (`firebase.json`):

```json
"hosting": {
  "public": "web",
  "rewrites": [
    { "source": "/car/**", "destination": "/car/index.html" }
  ],
  "headers": [
    {
      "source": "/.well-known/assetlinks.json",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    },
    {
      "source": "/.well-known/apple-app-site-association",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    }
  ]
}
```

Nginx:

```nginx
location /car/ {
  try_files $uri /car/index.html;
}
```

## 6. Deferred deep linking (install not present)

`app_links` only handles links when the app is already installed. If the app is
not installed:

- Android App Links / iOS Universal Links fall back to the browser, which is
  why `web/car/index.html` sends the user to the store.
- The car id is **not** automatically preserved after installation by
  `app_links`. A real deferred deep link needs a provider such as **Branch** or
  **AppsFlyer** (or a server-side install-referrer/clipboard flow).
- This project includes an optional Android-only best-effort using
  `play_install_referrer` (`&referrer=car_id=<id>`), but it is not a complete
  cross-platform deferred solution.

## 7. Test commands

Use the package id of the installed flavor (`com.Hajed.car.dev` in the examples).

Killed app:

```bash
adb shell am force-stop com.Hajed.car.dev
adb shell am start -a android.intent.action.VIEW -d "https://delta-asg.com/car/123"
```

Background app (press Home first, then):

```bash
adb shell am start -a android.intent.action.VIEW -d "https://delta-asg.com/car/123"
```

Running app:

```bash
adb shell am start -a android.intent.action.VIEW -d "https://delta-asg.com/car/123"
```

Custom scheme:

```bash
adb shell am start -a android.intent.action.VIEW -d "hajedcar://car/123"
```

iOS simulator:

```bash
xcrun simctl openurl booted "https://delta-asg.com/car/123"
xcrun simctl openurl booted "hajedcar://car/123"
```

iOS killed-app test:

```bash
xcrun simctl terminate booted com.Hajed.car
xcrun simctl openurl booted "https://delta-asg.com/car/123"
```

Expected: splash finishes → loading overlay → car details screen. If the id does
not exist, an i18n message appears and the Back to Home action is available.

## 8. Files added/changed by this implementation

- `lib/core/services/deep_link_service.dart` — `DeepLinkConfig`, `hajedcar`
  scheme + legacy `hbwcars`, `getLatestLink()` polling, one-request inventory
  lookup, localized error toast, duplicate-navigation guard
- `lib/main.dart` — initializes the service once
- `lib/app.dart` — disposes the link subscription
- `lib/service_initialize.dart` — no longer initializes deep links before DI
- `lib/features/home/presentation/view/screen/main_layout.dart`,
  `lib/features/agent/presentation/agent_shell.dart`,
  `lib/features/admin/presentation/screen/admin_main_layout.dart` — mark the
  navigator ready after the shell renders
- `lib/features/auth/presentation/view/screen/login_screen.dart` — flushes a
  pending auth-protected link after login
- `lib/core/localization/app_locale_keys.dart` + `i18n/ar.json` + `i18n/en.json`
  — `car_not_found`, `deep_link_load_failed`
- `pubspec.yaml` / `pubspec.lock` — `app_links` 7.0.0
- `android/app/src/main/AndroidManifest.xml` — App Links + `hajedcar` /
  `hbwcars` schemes
- `android/app/build.gradle.kts` — `deepLinkHost` / `deepLinkScheme`
- `ios/Runner/Info.plist` — `hajedcar` + legacy `hbwcars` schemes
- `ios/Runner/Runner.entitlements` — `applinks:delta-asg.com`
- `ios/Podfile.lock` — app_links 7.0.0 pod
- `web/.well-known/assetlinks.json` — all packages + fingerprints
- `web/.well-known/apple-app-site-association` — `/car` and `/car/*`
- `web/car/index.html` — app-first fallback page with real store URLs
- `deploy/iis/web.config.merge.xml` — IIS rewrite rules for `/.well-known/*`,
  `/car`, `/car/` and `/car/*` on port 443
- `deploy/iis/deploy-deep-links.ps1` — copies the three files to `wwwroot`
- `deploy/iis/README.md` — server deployment, verification, pitfalls
- `deploy/aspnet/DeepLinkEndpoints.cs` — no-IIS-module alternative

## 9. Troubleshooting

### App opens but stays on the home screen

1. Make sure the installed build contains the current `DeepLinkService`
   (the previous build could push the details screen above the splash, then
   the splash replaced itself with the home layout). Builds after 2026-11-25
   wait for `markNavigatorReady()` and persist the pending car id.
2. Confirm Android verified the domain:
   ```bash
   adb shell pm get-app-links com.Hajed.car
   ```
   If it says `none` / `unverified`, the live `assetlinks.json` is missing the
   signing key. Re-deploy the repository file and re-verify. (Even unverified,
   the `/car` fallback page now opens the app through `intent://`.)
3. Confirm the installed package is listed. Dev builds are
   `com.Hajed.car.dev`, staging is `com.Hajed.car.testing`; the live file must
   contain a statement for the exact package.
4. Check `adb logcat | grep -E '\[DL\]|DeepLinkService'`. The link should be
   logged as `initial link` or `stream link`, followed by
   `handleIncomingCarId`.
5. If the link is received but the car is not found, the service tries the id
   directly (`?id=<GROUP_CODE>`), then the full inventory, and shows a
   localized toast. Verify the shared id matches `GROUP_CODE` / `ITEM_CODE` /
   `CHASSIS_NO`.

### Blank white screen when the app is not installed

`https://delta-asg.com/car/<id>` is not being served. It must return `200
text/html` (no redirect) and render `web/car/index.html`. Check:

```bash
curl -sSI https://delta-asg.com/car/2531
```

If it returns `404`, deploy `wwwroot/car/index.html` and add the
`DeepLink-CarRoot` / `DeepLink-CarDetails` rewrite rules (or use
`deploy/aspnet/DeepLinkEndpoints.cs`).

### iOS Universal Link opens Safari instead of the app

- The AASA file must be reachable on **port 443** at
  `https://delta-asg.com/.well-known/apple-app-site-association`, with no
  redirect and `Content-Type: application/json`.
- Associated Domains must contain `applinks:delta-asg.com` and the provisioning
  profile must include the capability.
- Apple caches the AASA file. For testing, add
  `applinks:delta-asg.com?mode=developer` to the entitlements of a debug build
  and reinstall, or wait for the cache to refresh.
- Links opened inside some in-app browsers do not trigger Universal Links. The
  fallback page now tries the `hajedcar://` scheme before the App Store, so the
  app can still open.
