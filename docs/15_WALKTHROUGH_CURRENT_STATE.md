# 15. Walkthrough — Current State

## Overview

The MDT Phase 1 POC implements 4 of 8 planned steps. The app runs on Android tablets and provides offline shift and activity tracking for heavy equipment operators.

---

## Implemented Features

### 1. Start Shift

**Screen**: `StartShiftPage`  
**Flow**: User enters Unit ID, Operator ID, HM Start → taps "Mulai Shift"

**Events generated**:
```
SHIFT_STARTED   (shiftSessionId, unitId, operatorId, hmStart, occurredAt)
ACTIVITY_STARTED (standby/changeShift, occurredAt = same)
```

**Validation**:
- All fields required
- HM Start > 0, max 1 decimal place
- Debounced submit button

**Navigation**: On success → `MainActivityPage` (pushReplacement)

---

### 2. Main Activity Screen

**Screen**: `MainActivityPage`  
**Components**:

| Widget | Description |
|--------|-------------|
| `StatusBar` | Unit ID, Operator ID, live device clock |
| `ActiveActivityCard` | Category + subtype + elapsed timer (HH:MM:SS) |
| `CategoryGrid` | 2×2 grid: Operation, Standby, Delay, Breakdown |
| Bottom bar | "Lihat Timesheet" + "Akhiri Shift" buttons |

**Timer**:
- Source: `DateTime.now() - DateTime.parse(currentActivityStartedAt)`
- Updates every 1 second via `Timer.periodic`
- Never uses increment counter
- Resumes correctly after app restart

---

### 3. Activity Switching

**Flow**: Category button tap → `SubActivitySheet` → (optional `CodeInputModal`) → `switchActivity()`

```
User taps Category
  → SubActivitySheet shows subtypes
    → User selects subtype
      → loading: CodeInputModal (loaderCode) → switch
      → hauling: CodeInputModal (haulingCode) → switch
      → all others: switch immediately
      → cancel: no change
      → same subtype: no-op
```

**Events generated**:
```
ACTIVITY_ENDED   (current category/subtype, timestamp T)
ACTIVITY_STARTED (new category/subtype, timestamp T, loaderCode?, haulingCode?)
```

Both events share the **same timestamp T**.

---

### 4. Timesheet

**Screen**: `TimesheetPage`  
**Source**: Fully derived from `ActivityEvent[]` via `TimesheetBuilder`

**Derivation**:
- Pairs each `ACTIVITY_STARTED` with its `ACTIVITY_ENDED`
- Computes `durationSeconds` from timestamps
- Accumulates `loadingCount` / `haulingCount` cumulatively
- Derives HM values proportionally (only when `hmEnd` is set)
- Marks last unpaired row as `isActive = true`

**Table columns**: #, Waktu Mulai, Waktu Selesai, Kategori, Aktivitas, Durasi, HM Mulai, HM Akhir, Delta HM, Loader Code, Hauling Code, Loading #, Hauling #

**Active row**: Shows "Sedang berjalan" with live-updating duration.

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    (_AppRestorer → state restoration)
│   ├── routes.dart                 (/, /main-activity, /timesheet)
│   └── theme/theme.dart            (M3 Light, category accent colors)
├── data/
│   ├── local_storage/hive_storage.dart
│   └── repository_impl/
│       ├── shift_repository_impl.dart
│       └── activity_event_repository_impl.dart
├── domain/
│   ├── models/
│   │   ├── enums.dart              (4 categories, 20 subtypes, 4 events)
│   │   ├── shift_session.dart      (Hive persisted)
│   │   ├── activity_event.dart     (Hive persisted)
│   │   └── timesheet_row.dart      (derived, NOT persisted)
│   ├── repositories/
│   │   ├── shift_repository.dart
│   │   └── activity_event_repository.dart
│   └── services/
│       └── timesheet_builder.dart
├── features/
│   ├── shift/
│   │   ├── shift_state.dart
│   │   ├── shift_controller.dart   (startShift, switchActivity, restoreShift)
│   │   └── start_shift_page.dart
│   ├── activity/
│   │   └── main_activity_page.dart
│   └── timesheet/
│       ├── timesheet_provider.dart
│       └── timesheet_page.dart
└── shared/
    ├── utils/display_helpers.dart
    └── widgets/
        ├── status_bar.dart
        ├── active_activity_card.dart
        ├── category_button.dart
        ├── category_grid.dart
        ├── sub_activity_sheet.dart
        └── code_input_modal.dart
```

---

## Verification Results

| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ 0 issues |
| `flutter test` | ✅ 63 tests passed |

---

## Not Yet Implemented

| Feature | Why |
|---------|-----|
| End Shift | Deferred — next step |
| Summary | Deferred — next step |
| Mock API | Phase 1 is offline-only |
