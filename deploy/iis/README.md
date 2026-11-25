# Serving App Links / Universal Links on `delta-asg.com` (IIS + ASP.NET Core)

## Current live state (checked 2026-11-25)

| URL | Result |
| --- | --- |
| `https://delta-asg.com/.well-known/assetlinks.json` | `200 application/json` |
| `https://delta-asg.com/.well-known/apple-app-site-association` | `200 application/json` |
| `https://delta-asg.com/car/2531` | **`404`, empty body** |
| `https://delta-asg.com/car/index.html` | **`404`** |
| `https://delta-asg.com/deep-links/assetlinks.json` | `404` (not used on this server) |

So the verification files are already deployed correctly. **Only the `/car/<id>`
fallback page is missing**, which is why the browser shows a blank page and
never reaches the store redirect.

Google's view of the live file already contains:

- `com.Hajed.car` + `D0:EB:...:B3:14:C0:5A:4C:15:4C:21`
- `com.Hajed.car` + `63:00:6F:...` (debug key)

It does **not** contain the Play App Signing key or the `.testing` / `.dev`
packages. Add them if you install Play builds or the other flavors.

---

## Minimal fix for the blank `/car/<id>` page

### 1. Copy the fallback page

On the server:

```powershell
$siteRoot = 'C:\inetpub\wwwroot'          # <- the :443 site physical path
$wwwroot  = Join-Path $siteRoot 'wwwroot' # adjust if the app uses another root
$repoWeb  = 'C:\path\to\Hajed_car\web'    # <- repo checkout

New-Item -ItemType Directory -Force "$wwwroot\car" | Out-Null
Copy-Item "$repoWeb\car\index.html" "$wwwroot\car\index.html" -Force
```

Before copying, set the real App Store id in `web/car/index.html`
(`APP_STORE_URL`, currently `id000000000`). The Android link already uses
`com.Hajed.car` and adds `referrer=car_id=<id>`.

### 2. Route `/car/<id>` to that file

**Option A — IIS URL Rewrite (no app redeploy).** Merge
`car-route.merge.xml` into the existing `web.config`, inside
`<system.webServer><rewrite><rules>` and **before any catch-all / SPA /
Blazor fallback rule**:

```xml
<rule name="CarDetailsFallback" stopProcessing="true">
  <match url="^car/(.+)$" />
  <conditions>
    <add input="{URL}" pattern="^car/index\.html$" negate="true" />
  </conditions>
  <action type="Rewrite" url="/car/index.html" />
</rule>
```

**Option B — ASP.NET Core endpoint (most reliable).** Add to `Program.cs`,
before the Blazor/SPA fallback:

```csharp
app.MapGet("/car/{carId}", () => Results.File(
        Path.Combine(app.Environment.WebRootPath!, "car", "index.html"),
        "text/html; charset=utf-8"))
   .AllowAnonymous();
```

This keeps the public URL (`/car/2531`) unchanged and returns `200` with no
redirect, so the JavaScript in the page can read the car id and redirect to the
correct store.

### 3. Verify

```bash
curl -sSI https://delta-asg.com/car/2531
# HTTP/2 200
# content-type: text/html; charset=utf-8

curl -sS https://delta-asg.com/car/2531 | head -5
# <!DOCTYPE html> ... بن وزير للسيارات
```

If it is still 404, the physical path is wrong: confirm that
`wwwroot\car\index.html` exists in the **same** directory that IIS uses as the
site root, and that no rule above yours routes everything to the app.

---

## Full deployment (only if you redo `.well-known`)

The `:443` site is ASP.NET Core. Files live under `wwwroot`:

```
<site root>\
├── web.config                     <- merge the rewrite rules
└── wwwroot\
    ├── .well-known\
    │   ├── assetlinks.json
    │   └── apple-app-site-association
    └── car\
        └── index.html
```

The live server already serves `.well-known` (do not break it). If you redo it
from scratch and ASP.NET Core hides the dot-directory, use the alternative in
`web.config.merge.xml` (rewrite `.well-known/*` to `/deep-links/*`), or add
explicit endpoints — see `../aspnet/DeepLinkEndpoints.cs`.

### Fingerprints

`web/.well-known/assetlinks.json` contains:

| Key | SHA-256 |
| --- | --- |
| Play App Signing (confirm in Play Console) | `2B:AE:22:A6:2C:D3:04:75:6D:32:82:06:78:ED:21:D3:97:4D:48:1B:CD:42:55:A4:07:BE:12:56:79:27:05:23` |
| Upload (live server value) | `D0:EB:87:2E:AC:AE:3C:FF:90:AF:BB:03:2D:6A:22:3E:A1:54:7D:D1:CE:52:5F:EB:B3:14:C0:5A:4C:15:4C:21` |
| Upload (`key.jks`, alias `upload`) | `D0:EB:87:2E:AC:AE:3C:FF:90:AF:BB:03:2D:6A:22:3E:A1:54:7D:D1:CE:52:5F:EB:31:4C:05:A4:C1:54:C2:1B` |
| Debug (`~/.android/debug.keystore`) | `63:00:6F:29:99:5A:FB:BD:65:18:29:5C:9C:75:AB:AE:8A:E5:96:43:D3:57:A6:AE:79:5B:08:87:4E:48:88:08` |

Play-installed builds are signed with the Play App Signing key, so that
fingerprint must be present for links to work on Play builds. Get it from Play
Console → *Test and release* → *App integrity* → *App signing key certificate*.

## App-side checklist

The Dart side must call `DeepLinkService.init()` exactly once, after DI:

```dart
await ServiceInitialize.initialize();
await DeepLinkService.init();
```

It was missing from `lib/main.dart` and has been restored. Without it the app
opens (the OS handles the intent) but never reads the URL, so it stays on Home.

Cold-start links wait for `SplashScreen` to call
`DeepLinkService.markNavigatorReady()`, then look up the id in the
`HomeCubit` inventory (waiting for the in-flight home request) and fall back to
`HomeRepo.fetchAllCars(...)`.

## Common pitfalls

- **Blank page** — `/car/<id>` has no route or `wwwroot/car/index.html` is
  missing. The current live server is in this state.
- **App opens on Home** — the installed build does not contain
  `DeepLinkService.init()` (old APK), or the link was rejected as malformed.
  Rebuild/reinstall and check `adb logcat | grep DeepLinkService`.
- **No auto-open, browser opens instead** — App Links not verified. Check
  `adb shell pm get-app-links com.Hajed.car` and the Google statements API.
- **Verified but wrong app** — more than one flavor installed with the same
  domain; uninstall the others or use per-flavor subdomains.
- **301/302 on `/.well-known/*`** — verification fails. The final HTTPS URL
  must return `200` with no `Location` header.
