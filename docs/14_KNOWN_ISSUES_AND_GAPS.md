# 14. Known Issues and Gaps

## Critical Issues

None found. All 107 tests pass.

---

## Bugs Found During Review

### BUG-01: ShiftSession.copyWith cannot reset nullable fields to null

**Severity**: Medium (blocks End Shift implementation)  
**File**: `lib/domain/models/shift_session.dart:49-71`  
**Description**: `copyWith` uses `??` for nullable fields (`hmEnd`, `endedAt`). Once set, they cannot be reset to `null`.  
**Impact**: None in current scope. Will need a sentinel value pattern or a separate reset method for End Shift.  
**Tested**: N/A — not triggered by current features.

### BUG-02: ShiftState.copyWith cannot set currentCategory/currentSubtype to null

**Severity**: Low  
**File**: `lib/features/shift/shift_state.dart:39-57`  
**Description**: Same `??` pattern. Cannot clear activity info via `copyWith`.  
**Impact**: None. `ShiftState.initial()` constructor is used as a full reset.  
**Workaround**: Use `ShiftState.initial()` or direct constructor instead of `copyWith`.

---

## Edge Case Audit Results

All edge cases below have been tested and pass:

| Edge Case | Status | Test File |
|-----------|--------|-----------|
| Rapid switching (3+ sequential) | ✅ Pass | `shift_controller_test.dart` |
| App restart mid-activity | ✅ Pass | `shift_controller_test.dart` |
| Orphan ACTIVITY_ENDED | ✅ Pass | `timesheet_builder_edge_cases_test.dart` |
| Timestamp collision (0-second activity) | ✅ Pass | `timesheet_builder_edge_cases_test.dart` |
| Null hmEnd behavior | ✅ Pass | `timesheet_builder_test.dart` + `edge_cases_test.dart` |
| Only one active activity invariant | ✅ Pass | `shift_controller_test.dart` |
| No invalid event sequence | ✅ Pass | `shift_controller_test.dart` |
| switchActivity with no active shift | ✅ Pass | `shift_controller_test.dart` |
| Non-loading/hauling count stays 0 | ✅ Pass | `timesheet_builder_edge_cases_test.dart` |

---

## Design Gaps

### GAP-01: No widget tests for UI components *(unchanged)*

**Severity**: Low  
**Description**: Widget tests for StartShiftPage, MainActivityPage, CodeInputModal would validate form behavior and navigation. These require `ProviderScope` + mock repos (now available).  
**Recommendation**: Can be added using `test/mocks/mock_repositories.dart`.

### GAP-02: Timesheet provider does NOT auto-refresh *(unchanged)*

**Severity**: Low  
**Description**: `timesheetProvider` is `FutureProvider.autoDispose`. It does not refresh while TimesheetPage is visible and the user switches activities on another page.  
**Impact**: Acceptable — user navigates to timesheet, views, navigates back. Data is fresh on each open.

### GAP-03: `_AppRestorer` uses pushReplacementNamed *(by design)*

**Severity**: None  
**Description**: After restoration, can't navigate back to StartShiftPage. This is intended — a new shift can only start after the current one ends.

---

## Scope Not Implemented (By Design)

| Feature | Status | Blocking? |
|---------|--------|-----------|
| End Shift flow | Not implemented | No |
| Summary page | Not implemented | No |
| SummaryCalculator | Not implemented | No |
| PA / UA calculation | Not implemented | No |
| HM End input | Not implemented | No |
| Mock API integration | Not implemented | No |

---

## Quality Guardrail Verification (10_PROMPT.md §13)

All guardrails pass and are now tested:

| Guardrail | Status | Test |
|-----------|--------|------|
| No idle state | ✅ PASS | `shift_controller_test: auto-starts standby/changeShift` |
| No loading location required | ✅ PASS | No location field in any model |
| No dumping input required | ✅ PASS | `shift_controller_test: dumping has no codes` |
| No stored derived data | ✅ PASS | `timesheet_builder_test: no Hive annotations` |
| No multiple active activities | ✅ PASS | `shift_controller_test: only one active activity` |
| No dark mode as primary | ✅ PASS | `theme.dart: Brightness.light` |
| No numeric-only code restriction | ✅ PASS | `code_input_modal: regex allows alphanumeric + hyphen` |
