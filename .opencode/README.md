# Flutter Agent setup

Project-local OpenCode configuration for **Hajed_car** (`package:car`).

```
.opencode/
├── agents/
│   └── flutter-agent.md          primary/subagent "Flutter Agent"
├── skills/
│   ├── flutter-codebase/         folder layout, naming, imports, DI, routes
│   ├── flutter-api/              endpoints, models, repos, Either/Failure, cubit state
│   ├── flutter-widgets/          screen decomposition, theme, RTL, responsiveness
│   ├── flutter-localization/     AppLocaleKey, ar/en JSON, RTL verification + audit script
│   └── flutter-refactor/         safe moves, dedupe, verification gates
└── flutter-agent-workspace/      eval runs and benchmark (safe to delete)
```

## Use it

Open OpenCode in this repository and select **Flutter Agent**, or ask the current session to use it:

```
Use the flutter-agent to add a "bank offers" section to the home screen.
```

The agent loads the five skills itself, following the pipeline
`codebase → api → widgets → localization → refactor`.

## Why the skills are coupled

- `flutter-codebase` decides **where** everything lives and reserves names.
- `flutter-api` fills the data and state layers those names describe.
- `flutter-widgets` consumes the state fields and produces the visual pieces.
- `flutter-localization` turns every visible string into a key in both languages.
- `flutter-refactor` verifies the whole set and is the gate for any move or rename.

Each skill declares its handoff points so a change made in one stage cannot silently break another.
The agent also enforces the cross-stage invariants that are easy to miss in isolation: the active
filter lives in state when a refresh can replace the list, `.tr()` keys exist in both JSON files, and
money uses Latin digits.

## Localization audit

Run this before calling any UI change done:

```bash
python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py
```

It resolves `AppLocaleKey` **values** against `i18n/en.json` and `i18n/ar.json`, then reports ar/en
parity and duplicate JSON keys. It exits non-zero while any key is missing. Pre-existing debt is
printed too; only newly introduced gaps are yours.

## Evaluation

`.opencode/flutter-agent-workspace/iteration-1/` contains three real tasks run with and without the
skills, plus `benchmark.md`, per-run diffs and grading. The tasks cover a new home section
(financing offers), a data/state/UI feature (bank search), and a behavior-preserving extraction.
Use them as regression checks when editing a skill:

- With skills: 29/30 assertions passed.
- Without skills: 27/30.

The workspace is generated data, not part of the app. Delete it if you want a clean tree.

## Source of truth

All conventions and file references were derived from the code in `lib/features/home` and `lib/core`
at the time of writing (2026-10-23). If the code and a skill disagree, the code wins — update the
skill in the same change.
