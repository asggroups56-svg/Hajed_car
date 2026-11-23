# Serving App Links / Universal Links on `delta-asg.com` (IIS + ASP.NET Core)

## What the server actually is

Checked from outside on 2026-11-23:

| URL | Result |
| --- | --- |
| `https://delta-asg.com/` | `200 text/html` — ASP.NET Core web app (`AuroraTech.styles.css`, Blazor scoped attributes) |
| `https://delta-asg.com/.well-known/assetlinks.json` | `404` |
| `https://delta-asg.com/.well-known/apple-app-site-association` | `404` |
| `https://delta-asg.com/car/2531` | `404` |
| `https://delta-asg.com:54510/.well-known/assetlinks.json` | `200 application/json` |
| `https://delta-asg.com:54510/car/2531` | `404 text/html` |

Both ports terminate on **Microsoft-IIS/10.0** with the same GoDaddy certificate
(`CN=delta-asg.com`, SAN `delta-asg.com`, `www.delta-asg.com`). They are two
different IIS sites/bindings with different physical roots, so a file copied to
the `:54510` root is not visible on `:443`.

Android **only** verifies App Links against
`https://<host>/.well-known/assetlinks.json` on port **443**. A custom port is
never used, so the file on `:54510` can never verify links for
`https://delta-asg.com/car/...`.

## Files and where they go

The `:443` site is ASP.NET Core, so its public files live in `wwwroot`:

```
<site physical root>\
├── web.config                          <- MERGE the rules from web.config.merge.xml
└── wwwroot\
    ├── deep-links\
    │   ├── assetlinks.json
    │   └── apple-app-site-association.json
    └── car\
        └── index.html
```

`web/.well-known/apple-app-site-association` has no extension. IIS/ASP.NET Core
will not serve that extensionless file with `application/json` (and the default
ASP.NET Core file provider hides dot-prefixed directories), so it is deployed
as `deep-links/apple-app-site-association.json` and the **public URL stays
extensionless** through an internal rewrite.

## Step 1 — find the `:443` site root

On the server (elevated PowerShell):

```powershell
Import-Module WebAdministration
Get-Website | Format-Table Name, State, PhysicalPath -AutoSize
Get-WebBinding | Where-Object { $_.bindingInformation -like '*:443:*' } |
  Format-Table ItemXPath, protocol, bindingInformation -AutoSize
```

Take the `PhysicalPath` of the site bound to `*:443:delta-asg.com`. Confirm it
is the app that serves `https://delta-asg.com/` (it contains `wwwroot` and a
`web.config` with `<aspNetCore>`).

## Step 2 — copy the files

From the repository root on a machine that can reach the server share, or run
this on the server after copying the repo there:

```powershell
$siteRoot = 'C:\inetpub\wwwroot'          # <- from step 1
$wwwroot  = Join-Path $siteRoot 'wwwroot'
$repoWeb  = 'C:\path\to\Hajed_car\web'    # <- repo checkout

New-Item -ItemType Directory -Force "$wwwroot\deep-links", "$wwwroot\car" | Out-Null

Copy-Item "$repoWeb\.well-known\assetlinks.json" `
          "$wwwroot\deep-links\assetlinks.json" -Force

Copy-Item "$repoWeb\.well-known\apple-app-site-association" `
          "$wwwroot\deep-links\apple-app-site-association.json" -Force

Copy-Item "$repoWeb\car\index.html" `
          "$wwwroot\car\index.html" -Force
```

Before copying `assetlinks.json`, **replace/add the Play App Signing
fingerprint**. Get it from Play Console → your app → *Test and release* →
*App integrity* → *App signing key certificate* → SHA-256. The current file
contains:

- `2B:AE:22:...` — already published on `:54510`; confirm it is the Play App
  Signing certificate.
- `D0:EB:87:...` — local upload/release key (`/Users/asgsystems/key.jks`).
- `63:00:6F:...` — local debug key (`~/.android/debug.keystore`).

If Play Console shows a different SHA-256, add it as well; keep all of them so
Play builds, side-loaded release builds and debug builds all verify.

## Step 3 — merge the rewrite rules into `web.config`

Copy the `<rewrite>` block from `web.config.merge.xml` into the existing
`web.config` of the `:443` site, **inside `<system.webServer>` and before any
catch-all / SPA / Blazor fallback rule**. Do not replace the file: it contains
the `<aspNetCore>` handler that runs the app.

Back up first:

```powershell
Copy-Item "$siteRoot\web.config" "$siteRoot\web.config.bak" -Force
```

Recycle the app pool afterwards:

```powershell
Restart-WebAppPool -Name (Get-Website -Name '<site name>').applicationPool
```

### If IIS URL Rewrite is not installed

Install **URL Rewrite 2.1** (Microsoft Web Platform Installer / iis.net), or
use the C# endpoints in `../aspnet/DeepLinkEndpoints.cs` instead — they do not
depend on any IIS module and are the most reliable option for ASP.NET Core.

## Step 4 — verify

```bash
# must be 200 + application/json, no Location header, no 3xx
curl -sSI https://delta-asg.com/.well-known/assetlinks.json
curl -sSI https://delta-asg.com/.well-known/apple-app-site-association

# body must be the JSON you deployed
curl -sS https://delta-asg.com/.well-known/assetlinks.json

# fallback page, must be 200 text/html at the same URL (no redirect)
curl -sSI https://delta-asg.com/car/2531

# Google's view of the statements (should list your packages)
curl -sS "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://delta-asg.com&relation=delegate_permission/common.handle_all_urls"
```

Then on a device:

```bash
adb shell pm set-app-links --package com.Hajed.car 0 all
adb shell pm verify-app-links --re-verify com.Hajed.car
adb shell pm get-app-links com.Hajed.car     # delta-asg.com: verified
adb shell am start -a android.intent.action.VIEW -d "https://delta-asg.com/car/2531"
```

## Common pitfalls

- **301/302 on `/.well-known/*`** — usually an HTTP→HTTPS redirect rule or a
  `www` canonicalisation rule above ours. HTTPS requests to the final host must
  return `200` directly. Check with `curl -I` and look for `location:`.
- **Authentication** — the rewrite happens before authorization in IIS, and
  ASP.NET Core static files run before `UseAuthorization`. Do not put
  `/.well-known` or `/car` behind a login route.
- **`Content-Type: text/plain` / `application/octet-stream`** — the rewrite
  target must end in `.json`; that is what sets the header.
- **`assetlinks.json` only contains the upload key** — Play-installed builds are
  signed with the Play App Signing key, so verification fails. Always include
  that fingerprint.
- **Catch-all/SPA fallback** — if a rule above ours routes everything to
  `index.html`, our rules never run. They must be first.
- **Same domain for all flavors** — the Android app links are declared for
  `com.Hajed.car`, `com.Hajed.car.testing` and `com.Hajed.car.dev`. Do not
  install more than one of them on a test device, or Android will show an app
  chooser. For isolation use `dev.delta-asg.com` / `staging.delta-asg.com`.
- **API on `:54510`** — leave it untouched. The app still calls it
  (`AppConfig.appBaseUrl`). Only the public share domain uses `:443`.
