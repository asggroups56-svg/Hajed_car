# i18n Workflow — worked example and glossary

## Worked example: "Booking cancelled successfully"

**1. Key** — lowerCamelCase, constant equals key.

`lib/core/localization/app_locale_keys.dart`, inside the reservation/booking section:

```dart
// Reservation System
...
static const String bookingCancelledSuccess = 'bookingCancelledSuccess';
```

**2. English** — `i18n/en.json`

```json
"bookingCancelledSuccess": "Booking cancelled successfully",
```

**3. Arabic** — `i18n/ar.json`

```json
"bookingCancelledSuccess": "تم إلغاء الحجز بنجاح",
```

**4. Call site**

```dart
CommonMethods.showToast(
  message: AppLocaleKey.bookingCancelledSuccess.tr(),
  type: ToastType.success,
);
```

**5. Verify**

```bash
python3 - <<'PY'
import json
ar = json.load(open('i18n/ar.json')); en = json.load(open('i18n/en.json'))
assert set(ar) == set(en), (sorted(set(ar) ^ set(en)))
print('parity ok:', len(ar), 'keys')
PY
```

## Adding a key without reformatting the JSON

The JSON files are 2-space indented, UTF-8, unescaped Arabic. `json.dump(..., ensure_ascii=False,
indent=2)` rewrites the whole file and produces a noisy diff (key order is preserved by Python 3.7+
dicts, but whitespace may shift). Prefer a targeted text edit: find a sibling key and insert the new
line after it, keeping the trailing comma rules valid.

For several keys, a small script is safer:

```python
import json

path = 'i18n/ar.json'
with open(path, encoding='utf-8') as f:
    data = json.load(f)

new = {'bookingCancelledSuccess': 'تم إلغاء الحجز بنجاح'}
# insert after an existing key to keep the section together
out = {}
for k, v in data.items():
    out[k] = v
    if k == 'reservationSystem':
        out.update(new)
if not any(k in data for k in new):
    out.update({k: v for k, v in new.items() if k not in out})

with open(path, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
    f.write('\n')
```

Review the diff afterwards — a `json.dump` rewrite of the whole file is acceptable only when you also
intend to fix formatting; otherwise use `edit` on the single line.

## Placeholder rules

| Style | Where | Must match |
| ----- | ----- | ---------- |
| `{}` | `.tr(args: [value])` | number of `{}` == number of args |
| `{0}`, `{1}` | `.tr(namedArgs: ...)` | names/indices identical in ar and en |
| `%s` | legacy strings | keep exact count and order |

Arabic sentence order often needs the placeholder in a different position — that is fine, but the
token itself must be byte-identical.

## Glossary (use these consistently)

| English | Arabic | Notes |
| ------- | ------ | ----- |
| car / cars | السيارة / السيارات | |
| brand | الماركة / الماركات | existing `brands` key has stray spaces; do not copy that |
| model | الموديل | or "الطراز" in formal specs; follow the section |
| manufacturing year | سنة الصنع | |
| mileage | المسافة المقطوعة | with `(كم)` where the unit is shown |
| price | السعر | |
| total | الإجمالي | |
| offer | العرض / العروض | |
| financing | التمويل | |
| installment | القسط / الأقساط | |
| down payment | الدفعة الأولى | |
| bank | البنك | |
| booking | الحجز | |
| reservation | الحجز | reserved car = سيارة محجوزة |
| order | الطلب | |
| delivery | التوصيل | |
| shipping | الشحن | |
| warranty | الضمان | |
| inspection | الفحص | inspection report = تقرير الفحص |
| dealer / agent | الوكيل | agent dashboard = لوحة الوكيل |
| customer | العميل | |
| SAR | ر.س | currency symbol |
| PDF / VIP / OTP / QR | unchanged | do not transliterate |
| Try again | إعادة المحاولة | |
| Cancel / Confirm | إلغاء / تأكيد | |
| No results | لا توجد نتائج | |

## Style examples

| Bad | Why | Better |
| --- | --- | --- |
| `"Save"` → `"حفظ"` in a payment context | ambiguous | `"احفظ البطاقة"` / `"تأكيد الدفع"` |
| `"Error"` → `"خطأ"` | cold, unhelpful | `"تعذّر إتمام العملية. حاول مرة أخرى."` |
| `"Click here"` | not how mobile UI speaks | `"عرض التفاصيل"` |
| `"تم الحفظ بنجاح!"` | exclamation is not used in the app | `"تم الحفظ بنجاح"` |
| `"Car's price"` | literal machine translation | `"سعر السيارة"` |

## Final checks

- [ ] Key exists once in `AppLocaleKey`, once in each JSON.
- [ ] `.tr()` at every user-facing call site; no raw literals in the touched widgets.
- [ ] No unused key left behind if you replaced one (grep before deleting).
- [ ] Arabic checked on a real render (RTL, wrapping, truncation).
- [ ] Parity script prints equal key sets.
- [ ] `git diff i18n/` shows only the intended lines.
