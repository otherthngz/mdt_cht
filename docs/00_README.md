# 00_README.md

# MDT Phase 1 POC — System Documentation

**Project:** Mobile Dispatch Terminal (MDT)  
**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Overview

This repository contains the complete blueprint for the **Mobile Dispatch Terminal (MDT)** Phase 1 POC.

The MDT is a **field-ready Flutter application** used by unit operators on an Android tablet to log shift activities in real time.

The system follows an **event-based model**:
- every meaningful action generates an immutable event
- all outputs are derived from raw event history
- only minimal source-of-truth data is persisted locally

---

## 2. Technology Stack (Mandatory)

- Frontend: **Flutter (Android Tablet — mandatory)**
- Language: Dart
- State Management: Riverpod or Provider
- Storage: Hive or SharedPreferences
- Backend: Not used in Phase 1 (local-first)

> No other frontend framework should be used for Phase 1.

---

## 3. Locked Core Rules

- No idle state
- Start Shift automatically starts:
  - `standby / change_shift`
- Only one activity can be active at a time
- Loading requires `loaderCode` (**alphanumeric**)
- Hauling requires `haulingCode` (**alphanumeric**)
- Dumping has no additional input
- No location fields in Phase 1
- Timesheet and summary are derived, not persisted as source-of-truth
- Raw persisted source-of-truth:
  - `ShiftSession`
  - `ActivityEvent[]`

---

## 4. Recommended Read Order

1. `01_PRD.md`
2. `02_EVENT_DICTIONARY.md`
3. `03_STATE_MACHINE.md`
4. `04_UI_MAPPING.md`
5. `05_DATA_MODEL.md`
6. `06_ARCHITECTURE.md`
7. `07_MOCK_API_SPEC.md`
8. `08_COMPONENT_SPEC.md`
9. `09_EVENT_FLOW.md`
10. `10_PROMPT.md`

---

## 5. System Flow

```text
Start Shift
  ↓
SHIFT_STARTED
ACTIVITY_STARTED (standby/change_shift)
  ↓
User switches activity
  ↓
ACTIVITY_ENDED
ACTIVITY_STARTED
  ↓
(repeat)
  ↓
End Shift
  ↓
ACTIVITY_ENDED
SHIFT_ENDED
```

---

## 6. Out of Scope

- GPS tracking
- dispatch system
- backend integration
- authentication
- edit past events
- multi-device sync
- offline conflict resolution

---

## 7. Success Criteria

The POC is successful if:
- operator can complete a full shift flow
- event sequence is valid and consistent
- timesheet is generated correctly
- summary metrics are generated correctly
- UI is readable in field conditions

---

## 8. Notes

If a conflict exists, use this order of truth:
1. PRD
2. Event Dictionary
3. State Machine
4. UI Mapping
5. Data Model
6. Architecture
7. Mock API Spec
8. Component Spec
9. Event Flow
10. Prompt

---

**End of Document**
