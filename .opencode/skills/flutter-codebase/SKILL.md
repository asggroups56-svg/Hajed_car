---
name: flutter-codebase
description: Hajed_car codebase conventions — feature folder layout, file and class naming, import rules, GetIt wiring, route registration, and Cubit state shape. Use this skill at the start of every Flutter task in this repo, whenever you need to decide where a file belongs, how to name it, how to register a dependency, or how to add a screen to navigation — even when the user only asks for a small change.
---

# Hajed_car Codebase Contract

This app is `package:car` (Flutter 3.41.9, Dart `^3.8.1`). State is `flutter_bloc` Cubits, DI is
GetIt, HTTP is Dio behind `ApiConsumer`, strings are `easy_localization`, sizing is
`flutter_screenutil`. Everything below is verified against the current tree — do not "improve" it
into a different architecture.

## 1. Where code goes

A feature owns its data and its UI. The reference implementation is `lib/features/home`:

```
lib/features/<feature>/
├── data/
│   ├── model/            # one class per file, *_model.dart
│   └── repository/       # <feature>_repo.dart  (abstract interface + <Feature>RepoImpl)
└── presentation/
    ├── cubit/            # <feature>_cubit.dart + <feature>_state.dart (part of cubit)
    └── view/
        ├── screen/       # <name>_screen.dart — page-level widgets only
        └── widgets/      # <name>_widget.dart — every extracted piece
```

Known divergence — follow the feature you are editing, do not mass-rename:

| Feature                | Layout today                                        |
| ---------------------- | --------------------------------------------------- |
| `home`                 | `presentation/cubit` + `presentation/view/{screen,widgets}` |
| `auth`, `favorites`, `notifications`, `cart` | `presentation/view/cubit` + `presentation/view/screen` |
| `admin`, `agent`, `cars` | `presentation/cubit` (agent: `screens/` + `screens/widget/`), `presentation/screen`, `presentation/widget` |
| `services`, `profile`, `settings`, `about` | no `data/` layer, screens + widgets only |

New features copy `home`. Cross-cutting code goes to `lib/core/<area>`:

```
core/network   api_consumer, dio_consumer, end_points, failures, status.state, interceptors
core/cache     hive/ and shared_pref/ wrappers
core/theme     app_colors, app_text_style, app_theme (+ cubit/)
core/custom_widgets   reusable widgets grouped in subfolders
core/routes    routes_name + app_routers (+ app_routers_import)
core/services  services_locator, notification, permissions, app_update, bnpl
core/localization     app_locale_keys
core/utils     navigator_methods, common_methods, responsive_helper, saudi_phone_number,
               security_helper, pdf_* helpers
```

## 2. Naming

| Thing              | Rule                                             | Example                              |
| ------------------ | ------------------------------------------------ | ------------------------------------ |
| File               | `snake_case.dart`                                | `banks_slider_widget.dart`           |
| Model              | PascalCase, mirrors server entity                | `BANKSDATAModel`, `CarsModelsResponse` |
| Request model      | `<Action>Model` with `toJson()`                  | `SendOtpModel`                       |
| Response model     | `<Action>ResponseModel`                          | `SendOtpResponseModel`               |
| Repo               | `abstract interface class XRepo` + `XRepoImpl`   | `HomeRepo` / `HomeRepoImpl`          |
| Cubit / state      | `XCubit` / `XState`, state is `part of` the cubit | `HomeCubit` / `HomeState`           |
| Screen             | `XScreen` in `*_screen.dart`                     | `GuestHomeScreen`                    |
| Extracted widget   | `XWidget` in `*_widget.dart`                     | `SectionTitleWidget`                 |
| State fields       | `<operation>Status` of type `StatusState<T>`     | `banksStatus`, `carsModelsStatus`    |
| Endpoint constant  | camelCase value path, no base URL                | `EndPoints.getprandcars`             |

One public widget per file. `_PrivateState` classes stay in the same file as their widget.

## 3. Imports

- Cross-feature and cross-`core` imports use the package path:
  `import 'package:car/features/home/data/model/banks_data_model.dart';`
- Within the same feature (sibling widget → model, cubit → state) relative imports are accepted, and
  `part`/`part of` is used for cubit/state only.
- Order: dart: → package: → relative, separated by blank lines. `flutter_lints` is enabled
  (`analysis_options.yaml`), with `prefer_single_quotes` and `prefer_const_constructors`.
- If you see two candidate files for one symbol, stop and check — `handleDioRequest` is defined in
  both `core/error/failures.dart` and `core/network/handle_dio_request.dart`.

## 4. Dependency injection (GetIt)

Register new repositories and cubits in `lib/core/services/services_locator_imports.dart`
(a `part of services_locator.dart`):

```dart
sl.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(sl()));
sl.registerLazySingleton<HomeCubit>(() => HomeCubit(sl()));
```

Cubits that must live for the whole app are provided once in `lib/app.dart` (`MultiBlocProvider`).
Feature-local cubits are provided at the screen that owns them with `BlocProvider(create: ...)` and
are not registered in GetIt. Never construct a `Dio` or `ApiConsumer` inside a repo — take it as a
constructor parameter.

## 5. Routes and navigation

1. Add the name to `lib/core/routes/routes_name.dart` (`static const String x = 'xScreen';`).
2. Add a `case` in `AppRouters.onGenerateRoute` (`lib/core/routes/app_routers.dart`) returning
   `MaterialPageRoute(builder: (_) => const XScreen())`.
3. Navigate with `NavigatorMethods.pushNamed(context, RoutesName.x, arguments: ...)`, not with raw
   `Navigator.push` (the repo uses both; new code uses `NavigatorMethods`).
4. Arguments are untyped `Object?` today; if you pass a map, read it defensively
   (`args is Map<String, dynamic>`), as `carDetailsScreen` does.

## 6. State shape

`StatusState<T>` (`lib/core/network/status.state.dart`) is the current standard:

```dart
StatusState.initial() | .loading() | .success(data) | .failure(message, statusCode: 401)
state.banksStatus.isLoading / isSuccess / isFailure
```

`CubitStatus` + `ApiResponseWidget` (`core/enum/cubit_state.dart`) is the older pattern used by some
screens. Do not introduce it in new code and do not convert existing screens unless that is the task.

State class rules: `extends Equatable`, `const` constructor with defaults, `copyWith` with explicit
`clearX` flags when null is meaningful, and every field listed in `props`.

## 7. Task workflow

1. **Locate** the closest existing implementation with `grep`/`glob`; read it fully.
2. **Plan files** using the layout above and state the plan before editing when the change is larger
   than one or two files.
3. **Data first** (hand off to `flutter-api`): endpoint → model → repo → cubit.
4. **Then UI** (hand off to `flutter-widgets`): screen shell → extracted widgets.
5. **Then strings** (hand off to `flutter-localization`): keys in `AppLocaleKey` + both JSON files.
6. **Verify** (hand off to `flutter-refactor`): analyze, test, review diff.

See `references/feature-scaffold.md` for copy-ready file templates and the exact registration points.

## 8. Commands

```bash
flutter analyze lib/features/home lib/core/network      # touched paths only
flutter test test/notifications_cubit_test.dart         # focused test
flutter test                                            # full suite (slower)
```

Do not run `dart format` across the repo, and do not rewrite files to satisfy pre-existing lints.
The tree has ~406 analyzer issues at the time of writing (2026-10-23); your job is "no new issues",
not zero issues.

## 9. Handoff

- → `flutter-api`: the feature path, the operation names, and the state fields you reserved.
- → `flutter-widgets`: the screen path and the widget folder you created.
- → `flutter-localization`: the new key names you intend to use.
- → `flutter-refactor`: the list of files created/moved and the symbols that changed.
