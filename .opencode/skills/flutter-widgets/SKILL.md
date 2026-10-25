---
name: flutter-widgets
description: Hajed_car widget architecture — splitting screens into small single-purpose widget files, choosing Stateless vs Stateful, reading Cubit state with buildWhen/select, theming with AppColor/AppTextStyle, ScreenUtil sizing, RTL-safe layout, and reusing the core widget library. Use this skill when building or editing any Flutter UI, when a build method is getting long, when a widget must be reused in two places, or when layout breaks in Arabic or dark mode.
---

# Widget Architecture — Hajed_car

The home feature is the model to copy: a screen is a thin composition, and every repeated or
non-trivial visual block is its own file in `presentation/view/widgets/`.

## 1. File placement and naming

| Kind                    | Path                                             | Example |
| ----------------------- | ------------------------------------------------ | ------- |
| Page                    | `presentation/view/screen/<name>_screen.dart`    | `guest_home_screen.dart` |
| Extracted block         | `presentation/view/widgets/<name>_widget.dart`   | `section_title_widget.dart` |
| Small shared piece inside `core` | `core/custom_widgets/<group>/<name>.dart` | `custom_button.dart` |

- One public widget per file; private helper widgets may live in the same file only if they are
  meaningless outside it (`_BanksSliderItem`).
- Prefix internal state classes with `_`: `class _BanksSliderWidgetState extends State<BanksSliderWidget>`.
- Do not create `widgets.dart` barrel files; import directly.

## 2. When to extract

Extract when **any** of these is true:

- `build()` exceeds ~80 lines or nests deeper than 5 widget levels.
- The same subtree appears twice (cards, rows, badges, empty states).
- A subtree has its own state, controller, timer, or animation.
- Conditional branches (loading/empty/error/success) make one `build()` hard to read.
- A block would rebuild for reasons unrelated to its parent (wrap it, then scope the `BlocBuilder`).

Do not extract just to reduce line count if the widget needs eight parameters and no reuse. A private
`_buildX()` method is acceptable for a purely visual one-off; a public widget file is required for
anything reused or independently testable.

## 3. Stateless by default

- `StatelessWidget` unless you need `initState`, `dispose`, a `TextEditingController`, `Timer`,
  `AnimationController`, `ScrollController`, or `PageController`.
- Every widget gets `const X({super.key, ...})` when possible; required data is `required` and typed.
- Pass domain objects (`FinancingAdModel ad`, `BANKSDATAModel bank`), not `Map<String, dynamic>`.
  `popular_cars_slider_widget.dart` uses maps internally because of a legacy response — do not
  propagate that pattern into new widgets.
- Callbacks are `VoidCallback? onTap` / `ValueChanged<T>? onChanged`; the widget never navigates or
  calls the API on its own unless it is a screen-level widget with an explicit responsibility.
- Dispose every controller, cancel every timer (`BanksSliderWidget`, `PopularCarsSlider`).

## 4. Reading state without over-rebuilding

- Prefer `BlocBuilder<HomeCubit, HomeState>` with `buildWhen` limited to the fields the widget uses.
- For one field, `context.select((HomeCubit c) => c.state.banksStatus)`.
- For actions, `context.read<HomeCubit>()` (never inside `build` for state reads).
- Never create a cubit inside a leaf widget. Feature screens create it; app-wide cubits come from
  `app.dart`.
- Do not put `BlocBuilder` at the root of a scrolling screen: scope it to the section that changes.
- If a widget owns local UI state only (expanded/collapsed, selected tab), use `StatefulWidget` or a
  `ValueNotifier`, not the feature cubit.

## 5. Theming — no hardcoded colors

```dart
// correct
color: AppColor.secondAppColor(context)
style: AppTextStyle.bodySmall(context)
TextStyle(fontSize: 12.sp, color: AppColor.blackTextColor(context).withValues(alpha: 0.7))

// wrong — breaks dark mode and the theme cubit
color: Colors.white
color: Color(0xFF000000)
color: Colors.black.withOpacity(0.5)
```

- `AppColor.*(context)` and `AppTextStyle.*(context)` return theme-aware values. Use `listen: false`
  inside callbacks, dialogs, and long-lived objects.
- Use `.withValues(alpha: x)` (`.withOpacity` is deprecated in this Flutter version).
- Brand/illustration gradients may be literal colors (see `AdCardWidget._navyTop`), but they must be
  `static const` at the top of the file and documented as intentional.

## 6. Sizing and responsiveness

- `.w`, `.h`, `.sp`, `.r` from `flutter_screenutil`; design size is `360×690` (tablets are scaled in
  `app.dart`).
- Use `Gap(n.w)` / `Gap(n.h)` between children instead of `SizedBox`.
- Horizontal page padding is `16.w`; card padding `12–16.w`; radii commonly `12.r`, `16.r`, `20.r`.
- Avoid fixed pixel heights for text; use `constraints`, `AspectRatio`, or `minHeight`.
- Test at 320 dp width and tablet width when the layout has horizontal lists or long Arabic labels.

## 7. Arabic / RTL

- Use direction-aware APIs: `EdgeInsetsDirectional.only(start:, end:)`, `AlignmentDirectional`,
  `TextAlign.start/end`, `BorderRadiusDirectional`.
- Only 25 usages of directional APIs exist today; padding with `left/right` flips incorrectly in
  Arabic. New code should be directional.
- Icons that imply direction (arrows, chevrons) must flip:
  `Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward`.
- Arabic text is taller: leave vertical breathing room, avoid `maxLines: 1` on key labels unless
  ellipsis is acceptable.
- Latin/number fields need `textDirection: TextDirection.ltr` even inside an RTL layout (prices,
  phones, plate numbers).

## 8. Reuse before you build

Check these first — the repo already has most primitives:

| Need                    | Use |
| ----------------------- | --- |
| Primary/outlined button | `core/custom_widgets/buttons/custom_button.dart` (`CustomButton`, accepts `cubitState`) |
| App bar                 | `CustomAppBar` in `core/custom_widgets/custom_app_bar/` (`AppHeader` is home-only) |
| Loading                 | `core/custom_widgets/custom_loading/custom_loading.dart` (`CustomLoading`) |
| Network image           | `core/custom_widgets/custom_image/custom_network_image.dart` (uses `Constants.baseImage`) |
| Empty / error / offline | `NoDataWidget`, `ExceptionWidget`, `OfflineWidget` |
| Toast                   | `CommonMethods.showToast(...)` |
| Status switch           | `StatusState` branches or `ApiResponseWidget` (legacy) |
| Currency                | `ValueWithCurrencyIcon` in `core/custom_widgets/custom_sar_text.dart` |
| Expand/collapse         | `ExpandedSection` in `core/custom_widgets/expanded_section/` |
| Image zoom              | `ZoomImageScreen` in `core/custom_widgets/zoom_image/` |

If a new widget is genuinely generic (not feature-specific), put it in `core/custom_widgets/<group>/`
and mention it in the handoff.

**Search before you build a section.** `BanksSliderWidget` already existed and read `banksStatus`,
but was not mounted anywhere on the guest home screen at the time of writing. If a task says "the home
already loads X", check whether the rendering widget exists and is simply unused; mounting the
existing widget is better than writing a second one. Search by model name and status field, not only
by screen name.

**Do not invent lookalike state widgets.** When the section already has loading/empty/error states,
use `CustomLoading`/`CustomShimmer`, `NoDataWidget`, and `ExceptionWidget` with the real status
message. A bespoke message card is extra UI to maintain and drifts from every other section. If a
screen needs a genuinely different treatment, wrap the shared widget rather than reimplementing it.

**Money formatting.** Use `NumberFormat('#,##0', 'en_US')` for prices and installments in both
languages, matching the rest of the home cards. `context.locale.languageCode` produces Arabic-Indic
digits for `ar` and makes a card look inconsistent next to its neighbours; see the localization skill.

## 9. Performance

- `const` constructors and `const` child lists wherever possible.
- `ListView.builder` / `GridView.builder` for repeated cards; never `Column(children: list.map(...))`
  for unbounded data.
- Give list items stable `ValueKey`s when the list reorders or filters.
- Avoid rebuilding whole sliders on unrelated state: `buildWhen` + `RepaintBoundary` around animated
  subtrees.
- Do not call `MediaQuery.of(context).size` in a loop item; read it once in the parent.

## 10. Accessibility and polish

- Icon-only buttons need `Semantics(label: ...)` or a `tooltip`.
- Touch targets ≥ 44×44 logical pixels.
- `Hero` tags must be unique per item (the car list uses `heroTag` — keep it stable).
- Screens must handle keyboard insets (`resizeToAvoidBottomInset`, scrollable forms).

## 11. Handoff

- ← `flutter-api`: names of the status fields and data types the widget will consume.
- → `flutter-localization`: every visible string, including `hintText`, `tooltip`, `semanticsLabel`,
  empty-state messages, and button labels.
- → `flutter-refactor`: if you moved or split an existing widget, list the old and new file paths.
- → `flutter-codebase`: if a new generic widget belongs in `core/custom_widgets`.

See `references/widget-map.md` for the real home-feature decomposition and the decision tree.
