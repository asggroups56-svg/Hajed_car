---
name: flutter-refactor
description: Hajed_car safe-refactoring workflow — capturing a baseline, moving and splitting files, resolving duplicate symbols, deduplicating widgets, and verifying that behavior did not change. Use this skill whenever the task is to clean up, reorganize, rename, extract, merge, or simplify existing Flutter code, and as the final verification gate for every other skill.
---

# Refactoring — Hajed_car

This codebase has real debt and an active working tree. Refactoring here means **small,
behavior-preserving moves with proof**, not a rewrite. The most common failure mode is a "cleanup"
that changes a JSON key, a route name, or a status enum and silently breaks a screen.

## 1. Rules

- One intent per change series: either behavior changes or structure changes, never both.
- Never refactor files the user did not ask about, and never touch uncommitted work that is not yours.
- Preserve public names (`HomeCubit`, `EndPoints.getprandcars`, route strings) unless the task is
  explicitly a rename; renaming an API key or route string changes runtime behavior.
- Move with `git mv` so history follows the file.
- Update imports after every move — this repo mixes `package:car/...` and relative imports.
- Do not "fix" pre-existing analyzer infos in the same pass. Baseline is ~406 issues (`flutter analyze`, 2026-10-23); the bar is
  "no new issues in touched files".
- Do not reformat whole files or run `dart format lib`.

## 2. Baseline before touching anything

```bash
git status --porcelain          # what is already dirty
git diff --stat                 # size of the user's WIP
flutter analyze <paths> 2>&1 | tail -5    # issue count for the area you will touch
flutter test test/<relevant_test>.dart   # if a test exists
```

Record the counts. You will compare against them at the end.

## 3. Procedure

1. **Characterize** — describe current behavior in one paragraph: inputs, side effects, UI states,
   and which other files depend on the symbol you are about to move.
2. **Find all references** — `grep -rn "SymbolName" lib test`. A rename is only safe when the hit list
   is complete; imported symbols can appear in `app_routers_import.dart` and `services_locator_imports.dart`.
3. **Choose the smallest slice** — one widget, one method, one duplicate pair. If a file needs three
   unrelated fixes, do the first, verify, then continue.
4. **Move/split** — create the destination with the existing code verbatim, then delete the source.
   Keep class names stable; only the file path changes in most extractions.
5. **Wire** — update imports, `part`/`part of`, DI registration, route cases, and test imports.
6. **Verify** — analyze, run the focused test, read the diff for accidental behavior changes
   (default values, null handling, key renames, callback order).
7. **Report** — files moved, symbols unchanged/changed, baseline vs final analyzer count, manual check.

## 4. High-value targets in this repo

| Debt | Evidence | Safe slice |
| ---- | -------- | ---------- |
| Duplicate `handleDioRequest` | `core/error/failures.dart:131` and `core/network/handle_dio_request.dart:7` | Keep one implementation, make the other re-export or delete it, then remove `hide handleDioRequest` from `auth_repo.dart`. One file at a time. |
| Duplicate widget files | `card_image_section.dart` vs `card_image_section_widget.dart`; `favorite_button.dart`, `favorite_button_widget.dart`, `favorites_button.dart` | Grep usage, keep the live one, delete the dead one, re-run analyze. |
| Two status abstractions | `StatusState<T>` (`core/network/status.state.dart`) vs `CubitStatus` + `ApiResponseWidget` (`core/enum/cubit_state.dart`) | Do not unify globally. Convert only the screen you are working on, and only if the task allows behavior-adjacent edits. |
| `home_repo.dart` 696 lines / `home_cubit.dart` 621 lines | one class per concern mixed: cars, banks, financing, notifications, WhatsApp | Split by use case into additional interfaces (`BanksRepo`, `FinancingRepo`) with a compatibility `HomeRepo` façade. Large task — propose before starting. |
| `home` widget folder has 60+ files | several near-duplicate cards/buttons | Consolidate per the widget map, one pair per change. |
| Unmounted home section | `BanksSliderWidget` reads `banksStatus` but is not mounted in `guest_home_screen` | Mount the existing widget (and its search entry) rather than writing a second bank strip. |
| Localization parity | 5 keys missing in `en.json`, 2 in `ar.json`; 25 `AppLocaleKey` values missing from `en.json`, 21 from `ar.json` | Fix only the gaps the task touches; run `.opencode/skills/flutter-localization/scripts/i18n_audit.py`; bulk translation is a separate change. |
| Deprecated color API | many `withOpacity` infos | Replace only in files you already touch (`withValues(alpha:)`). |
| Naming lint | `fAQ_Item_widget.dart`, `constant_identifier_names` in `app_locale_keys.dart` | Renaming a file/key touches imports at call sites — separate, mechanical change with grep proof. |

Never combine the `home_repo` split, the status unification, and a feature request in one pass.

## 5. Extraction and split rules

- A move is safe when the destination compiles with **the same class name and constructor signature**.
  If you must change the signature, every call site is part of the change and must be listed.
- When splitting a widget file, keep the public widget in the original path and move only the private
  sub-widgets, or move both and update imports — never leave a stale file behind.
- When splitting a cubit, do not copy state fields into both halves; one state per screen, or an
  explicit composition at the screen level.
- When removing a duplicate, confirm zero references **and** zero dynamic string references (route
  names, keys).

## 6. Verification gates

| Gate | Command | Pass condition |
| ---- | ------- | -------------- |
| Compile | `flutter analyze <touched files>` | no errors, no new warnings/infos vs baseline |
| Unit | `flutter test test/<file>_test.dart` | same or better than baseline |
| References | `grep -rn "OldSymbol" lib test` | zero hits after a rename/move |
| Diff | `git diff -- <touched>` | only intended lines; no formatting noise |
| Runtime | manual or `flutter run` on the touched screen | success + error + empty states unchanged |

If you cannot run the app, say so explicitly and state which states you verified by inspection.

## 7. Reporting template

```markdown
## Refactor: <title>
Behavior: unchanged (<one-line description of what still happens>)

Moved/changed:
- lib/.../old.dart → lib/.../new.dart (class unchanged)
- removed duplicate `X` (0 references)

Verification:
- flutter analyze <paths>: 0 new issues (baseline N)
- flutter test <file>: pass
- references grep: 0
- manual: <what you checked / what you could not check>

Risk / follow-up: <remaining debt, if any>
```

## 8. Handoff

- ← `flutter-codebase` / `flutter-api` / `flutter-widgets` / `flutter-localization`: the change set to
  verify and, if needed, the structure to clean up.
- → the requesting skill: confirmation that names and file paths changed, so downstream code uses the
  new locations.
- → the user: the reporting template above, including anything unverified.

See `references/debt-register.md` for the full evidence table and a suggested order of attack.
