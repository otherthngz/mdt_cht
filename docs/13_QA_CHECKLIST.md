# 13. QA Checklist

## Legend

- ✅ = Verified via code review AND automated test
- 🟢 = Verified via code review only
- 🔲 = Requires manual testing on device/emulator

---

## Core System Rules (10_PROMPT.md §3)

| # | Check | Status | Test |
|---|-------|--------|------|
| 1 | No idle state after Start Shift | ✅ | `shift_controller_test: auto-starts standby/changeShift` |
| 2 | Only ONE activity active at a time | ✅ | `shift_controller_test: only one active activity exists` |
| 3 | Start Shift: SHIFT_STARTED → ACTIVITY_STARTED | ✅ | `shift_controller_test: SHIFT_STARTED comes before ACTIVITY_STARTED` |
| 4 | Start Shift: both share same timestamp | ✅ | `shift_controller_test: both events share same timestamp` |
| 5 | Switch: ACTIVITY_ENDED → ACTIVITY_STARTED | ✅ | `shift_controller_test: creates ACTIVITY_ENDED + ACTIVITY_STARTED` |
| 6 | Switch: both share same timestamp | ✅ | `shift_controller_test: share same timestamp` |
| 7 | Same subtype tapped = no-op | ✅ | `shift_controller_test: same subtype tapped returns false` |
| 8 | Same subtype = no events generated | ✅ | `shift_controller_test: does NOT generate any events` |
| 9 | Cancel = no change, no events | 🟢 | Sheet/modal return null → early return |
| 10 | Modal only for loading/hauling | 🟢 | `main_activity_page.dart:87-97` |
| 11 | Dumping starts immediately, no codes | ✅ | `shift_controller_test: dumping has no codes` |

---

## Data Rules (10_PROMPT.md §3)

| # | Check | Status | Test |
|---|-------|--------|------|
| 12 | Only ShiftSession + ActivityEvent[] persisted | ✅ | `timesheet_builder_test: TimesheetRow has no Hive annotations` |
| 13 | Counts are derived, not stored | ✅ | `timesheet_builder_test: cumulative counts` |
| 14 | Duration is derived from timestamps | ✅ | `timesheet_builder_test: durationSeconds = 600` |
| 15 | All events carry source = MDT | ✅ | `shift_controller_test: all events carry source = MDT` |

---

## Input Validation (10_PROMPT.md §3)

| # | Check | Status | Test |
|---|-------|--------|------|
| 16 | loaderCode = alphanumeric string | 🟢 | `code_input_modal.dart:43` regex `[a-zA-Z0-9\-]+` |
| 17 | haulingCode = alphanumeric string | 🟢 | Same widget for both |
| 18 | loaderCode NOT restricted to numeric only | ✅ | `models_test: loaderCode 'HL-088' accepted as string` |
| 19 | HM Start > 0 validation | 🟢 | `start_shift_page.dart:186` |
| 20 | Unit ID / Operator ID required | 🟢 | Form validators |

---

## Timer Rule (10_PROMPT.md §6)

| # | Check | Status | Test |
|---|-------|--------|------|
| 21 | Timer = now - startedAt | 🟢 | `main_activity_page.dart:57-59` |
| 22 | Timer NOT increment-only | 🟢 | Every tick recomputes from stored timestamp |
| 23 | Timer resumes after restart | ✅ | `shift_controller_test: preserves timer source` |
| 24 | Timer NOT persisted | 🟢 | No timer field in any Hive model |

---

## State Restoration (10_PROMPT.md §7)

| # | Check | Status | Test |
|---|-------|--------|------|
| 25 | Restore active shift on reopen | ✅ | `shift_controller_test: restores active shift` |
| 26 | Restore current activity | ✅ | `shift_controller_test: currentCategory = operation` |
| 27 | Do NOT auto-create new shift | ✅ | `shift_controller_test: does NOT auto-create` |
| 28 | Single restore entry point | 🟢 | Only in `_AppRestorer` |

---

## Event Sequence Integrity

| # | Check | Status | Test |
|---|-------|--------|------|
| 29 | No two consecutive ACTIVITY_STARTED | ✅ | `shift_controller_test: no invalid patterns` |
| 30 | No two consecutive ACTIVITY_ENDED | ✅ | Same test |
| 31 | Timestamps non-decreasing | ✅ | `shift_controller_test: timestamps are non-decreasing` |
| 32 | All events valid ISO 8601 | ✅ | `shift_controller_test: timestamps are valid ISO 8601` |
| 33 | All eventIds unique | ✅ | `shift_controller_test: all events have unique eventIds` |
| 34 | shiftSessionId consistent | ✅ | `shift_controller_test: shiftSessionId is consistent` |

---

## Timesheet Derivation

| # | Check | Status | Test |
|---|-------|--------|------|
| 35 | Pair START with END | ✅ | `timesheet_builder_test: single completed activity` |
| 36 | Active row = endTime null | ✅ | `timesheet_builder_test: active row` |
| 37 | loadingCount cumulative | ✅ | `timesheet_builder_test: cumulative counts` |
| 38 | HM null when hmEnd not set | ✅ | `timesheet_builder_test: HM null when hmEnd null` |
| 39 | HM proportional when set | ✅ | `timesheet_builder_test: HM derivation works` |
| 40 | Full Flow A verified | ✅ | `timesheet_builder_test: full Flow A` |

---

## Edge Cases

| # | Check | Status | Test |
|---|-------|--------|------|
| 41 | Orphan ACTIVITY_ENDED ignored | ✅ | `edge_cases_test: orphan ENDED is ignored` |
| 42 | Extra ENDED after close ignored | ✅ | `edge_cases_test: extra ENDED ignored` |
| 43 | Timestamp collision = 0 duration | ✅ | `edge_cases_test: same start and end produces 0` |
| 44 | Rapid switches pair correctly | ✅ | `edge_cases_test: rapid switches pair correctly` + `shift_controller_test: rapid sequential` |
| 45 | Mid-activity restart preserves startTime | ✅ | `edge_cases_test: active row has correct startTime` |
| 46 | Non-loading/hauling = 0 counts | ✅ | `edge_cases_test: counts only increment on loading/hauling` |
| 47 | Switch when no shift = false | ✅ | `shift_controller_test: returns false when no active shift` |

---

## Naming (10_PROMPT.md §4)

| # | Check | Status | Test |
|---|-------|--------|------|
| 48 | All enum names match docs | ✅ | `enums_test` |
| 49 | break_ ↔ "break" round-trip | ✅ | `enums_test: round-trip all subtypes` |
| 50 | All 4 categories correct | ✅ | `enums_test: values match doc names` |
| 51 | All 20 subtypes present | ✅ | `enums_test: has exactly 20 values` |

---

## UI Rules (10_PROMPT.md §8)

| # | Check | Status |
|---|-------|--------|
| 52 | Light theme only | 🟢 |
| 53 | Material 3 | 🟢 |
| 54 | Large touch targets | 🔲 |
| 55 | Active activity card always visible | 🔲 |
| 56 | Tablet-first layout | 🔲 |

---

## Summary

| Category | ✅ Tested | 🟢 Reviewed | 🔲 Manual |
|----------|-----------|-------------|-----------|
| Core rules | 11 | 0 | 0 |
| Data rules | 4 | 0 | 0 |
| Input validation | 1 | 4 | 0 |
| Timer | 1 | 3 | 0 |
| Restoration | 3 | 1 | 0 |
| Event integrity | 6 | 0 | 0 |
| Timesheet | 6 | 0 | 0 |
| Edge cases | 7 | 0 | 0 |
| Naming | 4 | 0 | 0 |
| UI | 0 | 2 | 3 |
| **Total** | **43** | **10** | **3** |
