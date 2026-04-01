# 01_PRD.md

# Mobile Dispatch Terminal (MDT) — Phase 1 POC

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Background & Objective

### Background
Hauling operations need a structured digital tool to record unit activity in real time. Manual logging creates delays, inconsistencies, and weak operational visibility.

### POC Objective
Prove that operators can log all shift activities using an Android tablet quickly, clearly, and with minimal effort.

### Expected Outputs
- auto-generated timesheet per shift
- shift summary (PA / UA)
- event log usable for cycle/activity reporting

---

## 2. User & Context

### Primary User
Unit operator using an Android tablet inside the unit cabin.

### UX Implications
- large buttons
- simple flow
- high contrast
- light theme
- minimal typing
- max 2 levels of navigation

---

## 3. System Design Principles

- event-based
- single active activity
- automatic transition
- minimal typing
- tap-first interaction
- always-visible active status
- no silent failure

### Naming Rules
UI labels are display-only.  
System values must follow the defined enums and field names.

Examples:
- "Non Produksi" → `nonProductive`
- "Antri" → `waiting`
- "Istirahat" → `break`

---

## 4. Scope

### In Scope
- Start Shift
- 4 activity categories with sub-activities
- conditional input for Loading and Hauling
- auto-generated timesheet
- End Shift + summary
- local storage only

### Out of Scope
- GPS / map
- dispatch assignment
- backend integration
- auth / RBAC
- analytics dashboard
- multi-shift history
- push notification

---

## 5. Functional Specification

### 5.1 Start Shift

Required input:

| Field | Type | Validation |
|---|---|---|
| unitId | text | required |
| operatorId | text | required |
| hmStart | number | required, positive, max 1 decimal |

Behavior:
- create a shift session
- record shift start timestamp
- automatically start default activity:
  - `standby / change_shift`

---

### 5.2 Activities & Sub-Activities

#### Operation

| Sub-Activity | Conditional Input |
|---|---|
| Loading | `loaderCode` (required, alphanumeric) |
| Hauling | `haulingCode` (required, alphanumeric) |
| Dumping | — |
| Non-Productive | — |

#### Standby

| Sub-Activity | Conditional Input |
|---|---|
| Change Shift | default activity after Start Shift |
| Refueling | — |
| Waiting / Queue | — |
| Break / Rest | — |

#### Delay

| Sub-Activity | Conditional Input |
|---|---|
| Rain | — |
| Flood | — |
| Road Issue | — |
| Extreme Dust | — |
| Lightning / Storm | — |
| Landslide | — |

#### Breakdown

| Sub-Activity | Conditional Input |
|---|---|
| Engine | — |
| Hydraulic | — |
| Electrical | — |
| Transmission | — |
| Undercarriage / Body | — |
| Brake & Steering | — |

### Conditional Input Rules

| Activity | Rule |
|---|---|
| Loading | `loaderCode` required before activity starts |
| Hauling | `haulingCode` required before activity starts |
| Dumping | no additional input |
| Others | no additional input |

### Code Format Rule
`loaderCode` and `haulingCode` are **alphanumeric** values.  
Examples:
- `LDR-201`
- `EX201`
- `HL-088`
- `TRIP12`

---

### 5.3 Activity Transition Rules

- only one activity can be active at a time
- selecting a new activity generates:
  - `ACTIVITY_ENDED`
  - `ACTIVITY_STARTED`
- selecting the same active subtype = no-op
- Start Shift generates:
  - `SHIFT_STARTED`
  - `ACTIVITY_STARTED (standby/change_shift)`

---

### 5.4 Timesheet

Each completed activity produces one row.

| Field | Source |
|---|---|
| Start Time | activity start timestamp |
| End Time | activity end timestamp |
| Category | selected category |
| Activity | selected subtype |
| HM Start | derived |
| HM End | derived |
| Delta HM | derived |
| Loader Code | Loading only |
| Hauling Code | Hauling only |
| Loading Count | derived cumulative |
| Hauling Count | derived cumulative |

### HM Rule
- hmStart entered once at Start Shift
- hmEnd entered once at End Shift
- HM per activity is derived from elapsed time
- no manual HM input per activity

### Count Rule
- Loading Count = cumulative count of `ACTIVITY_STARTED` with subtype `loading`
- Hauling Count = cumulative count of `ACTIVITY_STARTED` with subtype `hauling`

---

### 5.5 End Shift

Required input:

| Field | Type | Validation |
|---|---|---|
| hmEnd | number | required, must be >= hmStart |

Behavior:
- auto-end current activity
- generate shift summary
- lock session data

### Summary Output
- total operation time
- total standby time
- total delay time
- total breakdown time
- total shift duration
- total delta HM
- PA
- UA

---

## 6. Event Model

Core events:
- `SHIFT_STARTED`
- `ACTIVITY_STARTED`
- `ACTIVITY_ENDED`
- `SHIFT_ENDED`

Rules:
- one user action may generate multiple events
- Start Shift:
  - `SHIFT_STARTED`
  - `ACTIVITY_STARTED (standby/change_shift)`
- switch activity:
  - `ACTIVITY_ENDED`
  - `ACTIVITY_STARTED`
- End Shift:
  - `ACTIVITY_ENDED`
  - `SHIFT_ENDED`

---

## 7. Screens

1. Start Shift
2. Main Activity
3. Sub-Activity Selection
4. Conditional Input Modal
5. Timesheet
6. Summary

---

## 8. UX Rules

- light theme only
- large touch targets
- no unnecessary popup
- modal only for Loading and Hauling
- active card always visible
- field-ready readability

---

## 9. Technical Direction

- Flutter
- Dart
- Riverpod or Provider
- Hive or SharedPreferences
- Android tablet

---

## 10. Error Scenarios

### HM End < HM Start
- block action
- show validation

### Loading Without Loader Code
- disable start
- show validation

### Hauling Without Hauling Code
- disable start
- show validation

### Invalid Alphanumeric Input
- reject disallowed characters if format is constrained
- otherwise show inline validation if empty/invalid

### Rapid Activity Switching
- ignore duplicate rapid taps
- only latest valid action processed

---

## 11. Open Issues

- Should code format be fully free-form alphanumeric or pattern-constrained?
- Is correction flow needed in Phase 2?
- Should summary export be added later?

---

**End of Document**
