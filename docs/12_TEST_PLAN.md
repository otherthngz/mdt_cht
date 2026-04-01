# 12. Test Plan

## Test Inventory

| File | Group | Tests | Scope |
|------|-------|-------|-------|
| `test/widget_test.dart` | placeholder | 1 | Sanity check |
| `test/display_helpers_test.dart` | formatElapsed | 6 | Zero, negative, seconds, minutes, hours, boundary |
| | formatClock | 3 | Midnight, afternoon, single-digit padding |
| | categoryDisplayLabel | 6 | All 4 categories + null + unknown |
| | subtypeDisplayLabel | 8 | All subtypes incl. break/break_ and naming variants |
| `test/enums_test.dart` | ActivityCategory | 2 | Count and exact names |
| | ActivitySubtype | 4 | Count per category |
| | subtypeCategoryMap | 5 | Coverage and representative mappings |
| | subtypeToString/FromString | 4 | break_ round-trip + normal round-trip |
| | EventName | 2 | Count and exact names |
| | ShiftStatus | 2 | Count and exact names |
| `test/timesheet_builder_test.dart` | TimesheetBuilder | 10 | See below |
| `test/models_test.dart` | ShiftSession | 3 | Fields, copyWith, hmStart as double |
| | ActivityEvent | 3 | Fields, optional codes, string type |
| | ShiftState | 3 | Initial, copyWith, error clearing |
| **Total** | | **63** | |

---

## TimesheetBuilder Test Cases

| # | Test | What It Verifies |
|---|------|------------------|
| 1 | empty events → empty rows | No crash on empty input |
| 2 | SHIFT_STARTED only → empty | SHIFT_STARTED is not an activity row |
| 3 | single completed activity | Correct fields, duration, isActive=false |
| 4 | active row (no ENDED) | isActive=true, endTime=null, duration=null |
| 5 | loading/hauling codes preserved | loaderCode/haulingCode on correct rows |
| 6 | cumulative counts | loadingCount/haulingCount increment correctly |
| 7 | HM null when hmEnd null | No derivation without hmEnd |
| 8 | HM derivation with hmEnd | Proportional HM values correct |
| 9 | TimesheetRow not persisted | Plain Dart class, no Hive annotations |
| 10 | Full Flow A (09_EVENT_FLOW) | 6 rows, all fields verified end-to-end |

---

## Coverage Gaps (Acknowledged)

| Area | Why Not Tested | Priority |
|------|----------------|----------|
| ShiftController (startShift, switchActivity) | Requires Hive initialization — needs integration test setup | High (future) |
| Widget tests (StartShiftPage, MainActivityPage) | Requires ProviderScope + mock repos | Medium (future) |
| Repository implementations | Depends on Hive runtime | Medium (future) |
| State restoration flow | Requires full app lifecycle test | Medium (future) |
| CodeInputModal validation | Interactive widget test needed | Low |

---

## How to Run

```bash
flutter analyze
flutter test
```
