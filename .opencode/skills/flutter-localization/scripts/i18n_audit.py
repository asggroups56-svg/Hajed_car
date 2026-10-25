#!/usr/bin/env python3
"""Audit Hajed_car localization keys.

The app looks strings up by the *value* of an AppLocaleKey constant, not by the
constant's Dart name (e.g. AppLocaleKey.aboutCompany -> 'about_company'). This
script therefore resolves every constant and checks that value against both JSON
files, then checks ar/en parity.

Usage:
    python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py [--json]
    python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py --root /path/to/repo

Exit code: 0 clean, 1 any missing key or locale mismatch, 2 unreadable project.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

KEY_PATTERN = re.compile(
    r"static\s+const\s+String\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
    r"'((?:[^'\\]|\\.)*)'\s*;",
    re.MULTILINE,
)


def find_root(start: Path) -> Path | None:
    for candidate in [start, *start.parents]:
        if (candidate / "lib/core/localization/app_locale_keys.dart").is_file():
            return candidate
    return None


def load_json_pairs(path: Path) -> tuple[dict[str, str], list[str]]:
    """Load a flat JSON object and detect duplicate keys (last one wins in Python)."""
    duplicates: list[str] = []

    def hook(pairs):
        seen: dict[str, str] = {}
        for key, value in pairs:
            if key in seen:
                duplicates.append(key)
            seen[key] = value
        return seen

    with path.open(encoding="utf-8") as handle:
        data = json.load(handle, object_pairs_hook=hook)
    if not isinstance(data, dict):
        raise ValueError(f"{path} is not a flat JSON object")
    return {str(k): str(v) for k, v in data.items()}, duplicates


def parse_constants(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    constants: dict[str, str] = {}
    for name, value in KEY_PATTERN.findall(text):
        constants[name] = value
    return constants


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit AppLocaleKey against i18n/ar.json and en.json")
    parser.add_argument("--root", type=Path, default=Path.cwd(), help="Repository root (default: cwd)")
    parser.add_argument("--json", action="store_true", help="Print JSON instead of a human report")
    args = parser.parse_args()

    root = find_root(args.root.resolve())
    if root is None:
        print(f"Could not find lib/core/localization/app_locale_keys.dart under {args.root}", file=sys.stderr)
        return 2

    constants_path = root / "lib/core/localization/app_locale_keys.dart"
    en_path = root / "i18n/en.json"
    ar_path = root / "i18n/ar.json"
    for path in (constants_path, en_path, ar_path):
        if not path.is_file():
            print(f"Missing required file: {path}", file=sys.stderr)
            return 2

    constants = parse_constants(constants_path)
    en, en_dupes = load_json_pairs(en_path)
    ar, ar_dupes = load_json_pairs(ar_path)

    values = set(constants.values())
    missing_en = sorted(values - set(en))
    missing_ar = sorted(values - set(ar))
    only_en = sorted(set(en) - set(ar))
    only_ar = sorted(set(ar) - set(en))
    # Constants that share a value are aliases, not necessarily errors.
    aliases = {}
    for name, value in constants.items():
        aliases.setdefault(value, []).append(name)
    alias_groups = {v: names for v, names in aliases.items() if len(names) > 1}

    result = {
        "root": str(root),
        "constants": len(constants),
        "unique_values": len(values),
        "en_keys": len(en),
        "ar_keys": len(ar),
        "missing_in_en": missing_en,
        "missing_in_ar": missing_ar,
        "only_in_en": only_en,
        "only_in_ar": only_ar,
        "duplicate_keys_en": sorted(set(en_dupes)),
        "duplicate_keys_ar": sorted(set(ar_dupes)),
        "alias_groups": alias_groups,
    }

    clean = not (missing_en or missing_ar or only_en or only_ar or en_dupes or ar_dupes)

    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(f"Root: {root}")
        print(
            f"Constants: {len(constants)} ({len(values)} unique values) | "
            f"en: {len(en)} keys | ar: {len(ar)} keys"
        )
        _section("AppLocaleKey values missing from en.json", missing_en)
        _section("AppLocaleKey values missing from ar.json", missing_ar)
        _section("Keys only in ar.json (missing from en.json)", only_ar)
        _section("Keys only in en.json (missing from ar.json)", only_en)
        _section("Duplicate keys in en.json", sorted(set(en_dupes)))
        _section("Duplicate keys in ar.json", sorted(set(ar_dupes)))
        if alias_groups:
            print("\nNote: constants sharing one JSON value (aliases):")
            for value, names in sorted(alias_groups.items())[:10]:
                print(f"  {value!r}: {', '.join(names)}")
            if len(alias_groups) > 10:
                print(f"  … and {len(alias_groups) - 10} more")
        print("\nOK: no missing keys or locale mismatches." if clean else "\nFAIL: fix the lists above.")
        if not clean:
            print("Only new issues introduced by your change are yours; pre-existing debt is listed so it is visible.")

    return 0 if clean else 1


def _section(title: str, items: list[str]) -> None:
    if not items:
        return
    print(f"\n{title} ({len(items)}):")
    for item in items:
        print(f"  - {item}")


if __name__ == "__main__":
    raise SystemExit(main())
