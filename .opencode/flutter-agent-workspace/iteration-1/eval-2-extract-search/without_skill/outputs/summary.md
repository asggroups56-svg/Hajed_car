# Extract home search — without skills

## Built
- `home_search_filter_widget.dart`: `HomeSearchFilterWidget`, a `const` widget holding the search field (`AbsorbPointer` + read-only `TextField`) and filter button, with styling copied verbatim. Search sets the cars tab; filter pushes `RoutesName.filterScreen`.
- `guest_home_screen.dart`: uses `const HomeSearchFilterWidget()`, removes now-unused imports and the never-attached `_searchController`.

## Verification
`flutter analyze` on both touched files: no issues.

## Not verified
No runtime tap test or full suite; rendering/RTL checked by inspection.
