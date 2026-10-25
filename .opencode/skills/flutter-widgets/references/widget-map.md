# Widget Map — home feature

The home feature is the reference for decomposition. Learn the shape from it before creating a new
screen.

```
presentation/view/screen/
├── main_layout.dart            scaffold + bottom nav + tab notifiers
├── guest_home_screen.dart      scrollable composition only (~171 lines)
├── popular_cars_screen.dart    full list variant
├── all_brands_screen.dart      search + grid
└── recently_viewed_screen.dart

presentation/view/widgets/
├── ads_slider_widget.dart          PageView + timer + dot indicator
│   ├── ad_card_widget.dart         one ad card (composition, 350 lines)
│   │   ├── ad_card_background.dart gradient/decoration
│   │   ├── ad_card_image.dart      image + overlay
│   │   ├── ad_card_text_content.dart title/subtitle/price
│   │   ├── ad_tag_widget.dart      small badge
│   │   └── ad_explore_button.dart  CTA
│   └── ads_dot_indicator.dart
├── popular_cars_slider_widget.dart PageView of car cards + auto-scroll
│   └── car_card_widget.dart        one car card
│       ├── card_image_section_widget.dart
│       ├── card_content_section_widget.dart
│       ├── card_footer_widget.dart
│       └── card_top_bar_widget.dart
├── categories_widget.dart          brand chips row
│   └── custom_item_categories_widget.dart
├── banks_slider_widget.dart        auto-scrolling bank strip
├── section_title_widget.dart       title + "see all"
├── main_bottom_nav_bar.dart        bottom navigation
└── ...                              small one-purpose widgets
```

Notice the layering: **screen → section → card → atoms**. Each layer only knows about the layer below
it, and only sections read the cubit.

## Decision tree

```
Is it a page?                        → screen/
Does it own a controller/timer?      → separate StatefulWidget file
Is it used more than once?           → widgets/
Is it longer than ~80 lines?         → split by visual region (card, header, footer)
Is it only a styling wrapper?        → private helper or inline
Does it need the cubit?              → keep it a leaf and scope BlocBuilder
Does it navigate or call an API?     → callback up to the screen/section
```

## Before / after

Before — one file holds the page, the search bar, the list, the card, and the empty state:

```dart
Widget build(BuildContext context) {
  return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) { ... 300 lines ... });
}
```

After:

```dart
// guest_home_screen.dart — composition + lifecycle only
RefreshIndicator(
  onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
  child: SingleChildScrollView(
    child: Column(
      children: const [
        AdsSliderWidget(),
        SectionTitleWidget(titleKey: AppLocaleKey.brands),
        CategoriesWidget(),
        PopularCarsSlider(),
      ],
    ),
  ),
)
```

The screen still owns `initState`, `didChangeAppLifecycleState`, and the scroll view. Sections own
their own `BlocBuilder` and their own animation; cards receive typed data and report taps upward.

## Anti-patterns seen in this repo

- **Two files for the same widget:** `card_image_section.dart` and `card_image_section_widget.dart`;
  `favorite_button.dart`, `favorite_button_widget.dart`, `favorites_button.dart`. Do not add a fourth —
  check usage with `grep -rn "FavoriteButton" lib` and extend the live one.
- **Business logic in `build`:** computing prices, filtering lists, or decoding JSON inside a widget.
  Move it to the cubit or a model helper.
- **Widgets that take the whole cubit state** instead of the fields they need. Pass data; read state at
  the leaf.
- **Hardcoded strings and colors** sprinkled through cards; both break the Arabic and dark themes.
- **Giant `PageView` children rebuilt on every state change**; scope the builder and use keys.

## Sizing reference (from the existing UI)

| Element            | Value |
| ------------------ | ----- |
| Page horizontal padding | `16.w` |
| Section vertical gap    | `15.h` |
| Card margin             | `10.w` horizontal, `4.h` vertical |
| Card radius             | `16.r` – `20.r` |
| Small chip radius       | `12.r` |
| Body text               | `AppTextStyle.bodyMedium` (14.sp) |
| Caption text            | `AppTextStyle.bodySmall` (12.sp) |
| Screen title            | `AppTextStyle.titleMedium` (18.sp) |

When a new element does not match these, prefer the nearest existing value over inventing a scale.
