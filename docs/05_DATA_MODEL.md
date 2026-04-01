# 05_DATA_MODEL.md

# MDT Phase 1 POC — Data Model

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Purpose

Defines:
- persisted entities
- derived entities
- field ownership
- runtime reconstruction rules

This is the foundation for:
- local storage
- repository design
- state persistence
- timesheet and summary generation

---

## 2. Core Principles

- event-first model
- minimal persisted state
- derive instead of duplicate
- local-first POC
- no idle activity

---

## 3. Core Entities

1. `ShiftSession`
2. `ActivityEvent`
3. `TimesheetRow` (derived)
4. `ShiftSummary` (derived)

---

## 4. Relationship Overview

```text
ShiftSession
   ├── has many ActivityEvent
   ├── derives many TimesheetRow
   └── derives one ShiftSummary
```

---

## 5. ShiftSession

| Field | Type | Description |
|---|---|---|
| `shiftSessionId` | string | unique shift ID |
| `unitId` | string | unit ID |
| `operatorId` | string | operator ID |
| `shiftDate` | string | ISO date |
| `hmStart` | number | HM at shift start |
| `hmEnd` | number \| null | HM at shift end |
| `startedAt` | string | ISO datetime |
| `endedAt` | string \| null | ISO datetime |
| `status` | string | `active` \| `ended` |

---

## 6. ActivityEvent

### 6.1 Supported event names
- `SHIFT_STARTED`
- `ACTIVITY_STARTED`
- `ACTIVITY_ENDED`
- `SHIFT_ENDED`

### 6.2 Common fields

| Field | Type | Description |
|---|---|---|
| `eventId` | string | unique event ID |
| `eventName` | string | event type |
| `shiftSessionId` | string | parent shift |
| `unitId` | string | unit ID |
| `operatorId` | string | operator ID |
| `occurredAt` | string | ISO datetime |
| `source` | string | always `MDT` |

### 6.3 Activity-specific fields

| Field | Type | Description |
|---|---|---|
| `activityCategory` | string \| null | category |
| `activitySubtype` | string \| null | subtype |
| `loaderCode` | string \| null | only for loading |
| `haulingCode` | string \| null | only for hauling |

Rules:
- `loaderCode` is alphanumeric
- `haulingCode` is alphanumeric
- dumping has no extra field

---

## 7. TimesheetRow (Derived)

Derived by pairing:
- one `ACTIVITY_STARTED`
- one matching `ACTIVITY_ENDED`

Fields:

| Field | Type |
|---|---|
| `rowId` | string |
| `shiftSessionId` | string |
| `category` | string |
| `activity` | string |
| `startTime` | string |
| `endTime` | string \| null |
| `durationSeconds` | number \| null |
| `hmStartDerived` | number |
| `hmEndDerived` | number \| null |
| `deltaHmDerived` | number \| null |
| `loaderCode` | string \| null |
| `haulingCode` | string \| null |
| `loadingCount` | number \| null |
| `haulingCount` | number \| null |
| `isActive` | boolean |

---

## 8. ShiftSummary (Derived)

| Field | Type |
|---|---|
| `shiftSessionId` | string |
| `totalShiftSeconds` | number |
| `totalOperationSeconds` | number |
| `totalStandbySeconds` | number |
| `totalDelaySeconds` | number |
| `totalBreakdownSeconds` | number |
| `hmStart` | number |
| `hmEnd` | number \| null |
| `totalDeltaHm` | number \| null |
| `pa` | number \| null |
| `ua` | number \| null |
| `loadingCountTotal` | number |
| `haulingCountTotal` | number |

---

## 9. Enums

### Shift Status
- `active`
- `ended`

### Activity Category
- `operation`
- `standby`
- `delay`
- `breakdown`

### Activity Subtype

#### Operation
- `loading`
- `hauling`
- `dumping`
- `nonProductive`

#### Standby
- `changeShift`
- `refueling`
- `waiting`
- `break`

#### Delay
- `rain`
- `flood`
- `roadIssue`
- `extremeDust`
- `lightningStorm`
- `landslide`

#### Breakdown
- `engine`
- `hydraulic`
- `electrical`
- `transmission`
- `undercarriageBody`
- `brakeSteering`

---

## 10. Persistence Rules

Persist locally:
- `ShiftSession`
- raw `ActivityEvent[]`

Do not persist as source-of-truth:
- `TimesheetRow[]`
- `ShiftSummary`
- counts
- duration
- derived HM values

---

## 11. Suggested Storage Keys

```text
mdt_shift_session
mdt_activity_events
```

---

## 12. Repository Expectations

### Session
- create active shift
- get active shift
- update end values

### Events
- append event
- get events by shift
- get current active activity
- rebuild current state from events

### Derived outputs
- build timesheet from events
- build summary from events + shift session

---

## 13. Validation Rules

### ShiftSession
- `unitId` required
- `operatorId` required
- `hmStart > 0`
- `hmEnd == null or hmEnd >= hmStart`

### ActivityEvent
- valid `eventName`
- valid timestamp
- `activityCategory` and `activitySubtype` required for activity events
- `loaderCode` required only for `loading`
- `haulingCode` required only for `hauling`

---

## 14. Simplifications

- no idle state
- no loading location
- no dumping input
- no sync queue
- no backend schema
- no correction records

---

**End of Document**
