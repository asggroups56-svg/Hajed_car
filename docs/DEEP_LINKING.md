# Deep Linking Setup (app_links)

## 1. Configuration values

Everything is driven by one place in Dart:

`lib/core/services/deep_link_service.dart` → `DeepLinkConfig`

```dart
static const String webDomain = 'https://delta-asg.com';
static const String customScheme = 'hajedcar';
static const String carPath = 'car';
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
- `https://www.delta-asg.com/car/<carId>` (any subdomain of the configured host)
- `hajedcar://car/<carId>`
- `hajedcar:///car/<carId>`

Unsupported links, empty ids, `null`, `0`, and malformed ids are ignored safely.

## 2. How the Dart side works

1. `main.dart` calls `DeepLinkService.init()` once after DI/Hive/Firebase are ready.
2. `app_links.getInitialLink()` handles the killed-app case.
3. `app_links.uriLinkStream` handles running/background links.
4. A cold-start link waits for `DeepLinkService.markNavigatorReady()`, called from
   `SplashScreen` after the splash replacement route is installed.
5. The car id is searched in `HomeCubit` inventory first, then through
   `HomeRepo.fetchAllCars(...)` (the existing endpoint).
6. A small loading overlay is shown while loading.
7. Not found / network errors show an i18n message and a **Back to Home** action.
8. Navigation uses the existing arguments shape:
   `{'car': car, 'heroTag': null}`.
9. Rapid duplicate links for the same car are ignored for 3 seconds; a different
   link arriving while one is being handled is queued.

Car details are public in this app (guests can browse; only reservation asks for
login), so deep links are not blocked behind auth. `handleIncomingCarId` has a
`requiresAuth` flag plus `flushPendingAfterLogin()` for future auth-protected
links; `LoginScreen` already calls the flush after a successful login.

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

The repository file already contains the three local fingerprints:

| Key | SHA-256 |
| --- | --- |
| Play App Signing (confirm in Play Console) | `2B:AE:22:A6:2C:D3:04:75:6D:32:82:06:78:ED:21:D3:97:4D:48:1B:CD:42:55:A4:07:BE:12:56:79:27:05:23` |
| Upload/release (`key.jks`, alias `upload`) | `D0:EB:87:2E:AC:AE:3C:FF:90:AF:BB:03:2D:6A:22:3E:A1:54:7D:D1:CE:52:5F:EB:31:4C:05:A4:C1:54:C2:1B` |
| Debug (`~/.android/debug.keystore`) | `63:00:6F:29:99:5A:FB:BD:65:18:29:5C:9C:75:AB:AE:8A:E5:96:43:D3:57:A6:AE:79:5B:08:87:4E:48:88:08` |

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

Verify:

```bash
adb shell pm get-app-links com.Hajed.car
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

The rewrite keeps the public URLs extensionless and returns `200` with
`Content-Type: application/json` — no redirects. `/.well-known` is rewritten
to `/deep-links` because ASP.NET Core's default file provider hides
dot-prefixed directories. If URL Rewrite is unavailable, use
[`deploy/aspnet/DeepLinkEndpoints.cs`](../deploy/aspnet/DeepLinkEndpoints.cs).

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
  path `/car/*`.
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

- Android → Google Play (also adds `referrer=car_id=<id>` for the optional
  Android Play Install Referrer helper).
- iOS → App Store.
- Desktop/other → car id + download buttons + “open in app” button.

Before deploying, replace `APP_STORE_URL` in the page with the real App Store id.

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

- `lib/core/services/deep_link_service.dart` (new/rewritten)
- `lib/main.dart` — initializes the service once
- `lib/app.dart` — disposes the link subscription
- `lib/service_initialize.dart` — no longer initializes deep links before DI
- `lib/features/splash/presentation/view/screen/splash_screen.dart` — marks the
  navigator ready after splash routing
- `lib/features/auth/presentation/view/screen/login_screen.dart` — flushes a
  pending auth-protected link after login
- `lib/core/localization/app_locale_keys.dart` + `i18n/ar.json` + `i18n/en.json`
  — `car_not_found`, `deep_link_load_failed`
- `pubspec.yaml` / `pubspec.lock` — `app_links` 7.0.0
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle.kts`
- `ios/Runner/Info.plist`
- `ios/Runner/Runner.entitlements` (domain was already present)
- `ios/Podfile.lock` — app_links 7.0.0 pod
- `web/.well-known/assetlinks.json` (new)
- `web/.well-known/apple-app-site-association` (new)
- `web/car/index.html` (new)
- `deploy/iis/web.config.merge.xml` — IIS rewrite rules for `/.well-known/*` and
  `/car/*` on port 443
- `deploy/iis/README.md` — server deployment, verification, pitfalls
- `deploy/aspnet/DeepLinkEndpoints.cs` — no-IIS-module alternative
