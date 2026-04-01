# 07_MOCK_API_SPEC.md

# MDT Phase 1 POC — Mock API Specification

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Purpose

Defines the local/mock API contract used by Flutter repositories or fake data sources.

Even though Phase 1 is local-first, this contract:
- standardizes request/response shapes
- separates UI from persistence logic
- keeps future backend migration easier

---

## 2. Conventions

### Base path
```text
/mock-api
```

### Response envelope
```json
{
  "success": true,
  "message": "string",
  "data": {}
}
```

---

## 3. Endpoints

### 3.1 Start Shift
`POST /mock-api/shift/start`

Request:
```json
{
  "unitId": "DT-021",
  "operatorId": "OPR-045",
  "hmStart": 4521.3
}
```

Behavior:
- create shift session
- append `SHIFT_STARTED`
- append `ACTIVITY_STARTED (standby/changeShift)`

---

### 3.2 Switch Activity
`POST /mock-api/activity/switch`

#### Loading request
```json
{
  "shiftSessionId": "shift-001",
  "nextActivityCategory": "operation",
  "nextActivitySubtype": "loading",
  "loaderCode": "LDR-201"
}
```

#### Hauling request
```json
{
  "shiftSessionId": "shift-001",
  "nextActivityCategory": "operation",
  "nextActivitySubtype": "hauling",
  "haulingCode": "HL-088"
}
```

#### Dumping request
```json
{
  "shiftSessionId": "shift-001",
  "nextActivityCategory": "operation",
  "nextActivitySubtype": "dumping"
}
```

Validation:
- `loaderCode` required for Loading
- `haulingCode` required for Hauling
- both codes are alphanumeric

---

### 3.3 Get Active Shift
`GET /mock-api/shift/active`

---

### 3.4 Get Current Activity
`GET /mock-api/activity/current?shiftSessionId=shift-001`

---

### 3.5 Get Events
`GET /mock-api/events?shiftSessionId=shift-001`

---

### 3.6 Get Timesheet
`GET /mock-api/timesheet?shiftSessionId=shift-001`

Timesheet row shape:
- Start Time
- End Time
- Category
- Activity
- Duration
- HM Start
- HM End
- Delta HM
- Loader Code
- Hauling Code
- Loading Count
- Hauling Count

---

### 3.7 Get Summary
`GET /mock-api/summary?shiftSessionId=shift-001`

---

### 3.8 End Shift
`POST /mock-api/shift/end`

Request:
```json
{
  "shiftSessionId": "shift-001",
  "hmEnd": 4531.3
}
```

Behavior:
- append `ACTIVITY_ENDED`
- append `SHIFT_ENDED`
- update session

---

### 3.9 Reset Mock Data
`POST /mock-api/dev/reset`

Optional dev utility.

---

## 4. Derived Logic Notes

### HM
```text
HM(activity) = Shift HM Start + elapsed time in hours
```

### Counts
- Loading Count = cumulative count of `ACTIVITY_STARTED` subtype `loading`
- Hauling Count = cumulative count of `ACTIVITY_STARTED` subtype `hauling`

### Persistence
- raw events persisted
- timesheet and summary generated on request

---

## 5. Error Cases

- missing unitId
- missing operatorId
- invalid hmStart
- invalid hmEnd
- hmEnd < hmStart
- missing loaderCode for Loading
- missing haulingCode for Hauling
- invalid alphanumeric code
- invalid transition
- no active shift

---

## 6. Suggested Flutter Mapping

Implement as:
- repository methods
- fake datasource adapters
- local services

Suggested methods:
- `startShift()`
- `switchActivity()`
- `getActiveShift()`
- `getCurrentActivity()`
- `getEvents()`
- `getTimesheet()`
- `getSummary()`
- `endShift()`
- `resetMockData()`

---

## 7. Constraints

- local only
- no auth
- no sync
- no edit/delete events
- no correction endpoint

---

**End of Document**
