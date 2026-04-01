# 06_ARCHITECTURE.md

# MDT Phase 1 POC — System Architecture

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Purpose

Defines:
- Flutter application structure
- data flow between layers
- event-based implementation
- local storage model
- controller / repository responsibilities

---

## 2. Architecture Principles

### 2.1 Event-driven core
Business logic revolves around:
- `ShiftSession`
- `ActivityEvent[]`

### 2.2 Single source of truth
Persist only:
- `ShiftSession`
- `ActivityEvent[]`

Everything else is derived.

### 2.3 Unidirectional flow
```text
UI → Action → Controller → Repository → Storage → State → UI
```

### 2.4 Local-first
- no backend
- no sync
- no remote dependency

### 2.5 Presentation-only UI
Widgets render state and trigger actions.  
They do not own business rules.

---

## 3. High-Level Layers

```text
Flutter UI
  ↓
State Layer (Riverpod / Provider)
  ↓
Controller / Use Case Layer
  ↓
Repository Layer
  ↓
Local Storage
```

---

## 4. Layer Breakdown

### 4.1 UI Layer
Screens:
- StartShiftPage
- MainActivityPage
- SubActivitySheet
- ConditionalInputModal
- TimesheetPage
- SummaryPage

### 4.2 State Layer
Suggested state:
- `ShiftState`
- `CurrentActivityState`
- `TimesheetState`
- `SummaryState`

### 4.3 Controller / Use Case Layer
Suggested use cases:
- `startShift()`
- `switchActivity()`
- `endShift()`
- `buildTimesheet()`
- `buildSummary()`

### 4.4 Repository Layer
Repositories:
- `ShiftRepository`
- `ActivityEventRepository`

Derived services:
- `TimesheetBuilder`
- `SummaryCalculator`

### 4.5 Storage Layer
- Hive recommended
- SharedPreferences fallback

Persist:
- `ShiftSession`
- `ActivityEvent[]`

---

## 5. Main Flows

### 5.1 Start Shift
```text
UI validates
→ startShift()
→ create ShiftSession
→ append SHIFT_STARTED
→ append ACTIVITY_STARTED (standby/changeShift)
→ rebuild state
→ navigate to MainActivityPage
```

### 5.2 Switch Activity
```text
User selects subtype
→ if Loading/Hauling: show modal first
→ switchActivity()
→ append ACTIVITY_ENDED
→ append ACTIVITY_STARTED
→ rebuild current activity state
→ UI re-render
```

### 5.3 End Shift
```text
validate hmEnd
→ endShift()
→ append ACTIVITY_ENDED
→ append SHIFT_ENDED
→ update ShiftSession
→ build summary
→ navigate to SummaryPage
```

---

## 6. State Design

### ShiftState
```ts
{
  shiftSession: ShiftSession | null,
  isActive: boolean
}
```

### CurrentActivityState
```ts
{
  category: string | null,
  subtype: string | null,
  startedAt: string | null,
  loaderCode: string | null,
  haulingCode: string | null
}
```

### TimesheetState
```ts
{
  rows: TimesheetRow[]
}
```

### SummaryState
```ts
{
  totalShiftSeconds: number,
  totalOperationSeconds: number,
  totalStandbySeconds: number,
  totalDelaySeconds: number,
  totalBreakdownSeconds: number,
  totalDeltaHm: number | null,
  pa: number | null,
  ua: number | null,
  loadingCountTotal: number,
  haulingCountTotal: number
}
```

---

## 7. Domain Rules

- default activity = `standby / changeShift`
- no idle state
- one active activity only
- `loaderCode` required for Loading
- `haulingCode` required for Hauling
- both codes are alphanumeric
- dumping requires no input
- all timesheet / summary values are derived

---

## 8. Derived Calculation Responsibility

### TimesheetBuilder
- pair start/end events
- compute duration
- derive HM values
- assign cumulative counts

### SummaryCalculator
- sum durations by category
- calculate shift totals
- calculate PA / UA
- calculate total counts

---

## 9. Timer Strategy

Timer is not persisted.

```text
elapsed = deviceNow - currentActivity.startedAt
```

For Phase 1:
- use device time for runtime display
- use same device time source for event creation
- if app restarts, timer resumes from stored event timestamp

---

## 10. Validation / Error Handling

| Scenario | Handling |
|---|---|
| invalid hmStart | block submit |
| invalid hmEnd | block end shift |
| hmEnd < hmStart | block end shift |
| missing loaderCode | disable submit |
| missing haulingCode | disable submit |
| invalid alphanumeric code | show inline validation |
| duplicate rapid tap | debounce / ignore |
| invalid transition | block and preserve current state |

---

## 11. Recommended Flutter Structure

```text
/lib
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
├── features/
│   ├── shift/
│   ├── activity/
│   ├── timesheet/
│   └── summary/
├── domain/
│   ├── models/
│   ├── repositories/
│   └── services/
├── data/
│   ├── local_storage/
│   └── repository_impl/
└── shared/
```

---

## 12. Anti-Patterns

- do not store timesheet as source-of-truth
- do not store summary as source-of-truth
- do not allow multiple active activities
- do not introduce idle state
- do not put business logic in widgets
- do not mutate event history

---

## 13. Constraints

- single device
- single active shift
- no backend
- no sync
- no correction flow
- no external integration

---

**End of Document**
