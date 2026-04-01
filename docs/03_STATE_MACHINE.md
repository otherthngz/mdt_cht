# 03_STATE_MACHINE.md

# State Machine — MDT Phase 1 POC

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Purpose

Defines valid states, transitions, and event generation rules for MDT Phase 1.

This is the authoritative reference for:
- valid transitions
- invalid transitions
- modal behavior
- event generation order
- UI behavior by state

---

## 2. State Definitions

### 2.1 Shift State

| State | Description |
|---|---|
| `notStarted` | no shift has begun |
| `active` | shift in progress |
| `ended` | shift finalized |

### 2.2 Activity State

| State | Description |
|---|---|
| `operation` | operation subtype active |
| `standby` | standby subtype active |
| `delay` | delay subtype active |
| `breakdown` | breakdown subtype active |

Rules:
- activity state only exists when shift is active
- only one activity can be active at a time
- there is no idle state
- after Start Shift:
  - `standby / changeShift` starts automatically

---

## 3. High-Level Flow

```text
notStarted
  ↓ Start Shift
active / standby(changeShift)
  ↓ select activity
active / [operation | standby | delay | breakdown]
  ↓ repeat switches
ended
```

---

## 4. Shift State Transitions

### 4.1 notStarted → active

Preconditions:
- unitId valid
- operatorId valid
- hmStart valid

System actions:
1. generate `SHIFT_STARTED`
2. create shift session
3. generate `ACTIVITY_STARTED (standby/changeShift)`
4. set shift state = active
5. set activity state = standby

### 4.2 active → ended

Preconditions:
- hmEnd valid
- hmEnd >= hmStart
- confirmation accepted

System actions:
1. generate `ACTIVITY_ENDED`
2. generate `SHIFT_ENDED`
3. set shift state = ended
4. clear current activity

---

## 5. Activity State Transitions

### 5.1 Any active state → different activity

System actions:
1. if new subtype needs input:
   - open modal
   - validate input
2. generate `ACTIVITY_ENDED`
3. generate `ACTIVITY_STARTED`
4. set new activity state
5. reset timer

### 5.2 Same active subtype tapped again

System action:
- no-op
- no event
- no state change

---

## 6. Valid / Invalid Transitions

### Valid
- standby → operation
- standby → delay
- standby → breakdown
- operation → standby
- operation → operation (different subtype)
- delay → operation
- breakdown → standby
- any active state → ended

### Invalid
- activity selection before Start Shift
- End Shift before Start Shift
- activity selection after shift ended

---

## 7. Conditional Input Rules

### Loading
- requires `loaderCode`
- value must be alphanumeric
- if cancel → no state change

### Hauling
- requires `haulingCode`
- value must be alphanumeric
- if cancel → no state change

### Dumping
- no input
- starts immediately

### Other activities
- no modal
- start immediately

---

## 8. Confirmation Rules

| Action | Confirmation |
|---|---|
| select category | no |
| select subtype | no |
| submit Loading / Hauling modal | no |
| End Shift | yes |

---

## 9. UI State Rules

### notStarted
- show Start Shift form
- hide activity controls
- hide End Shift

### active
- show active card
- show timer
- show category buttons
- show End Shift
- right after Start Shift:
  - active card = `Standby / Change Shift`

### ended
- show summary
- hide activity controls
- data becomes read-only

---

## 10. Event Generation by Transition

| Transition | Events |
|---|---|
| Start Shift | `SHIFT_STARTED`, `ACTIVITY_STARTED` |
| Switch activity | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` |
| Same subtype again | none |
| End Shift | `ACTIVITY_ENDED`, `SHIFT_ENDED` |

---

## 11. Transition Examples

### Example A
Start Shift  
→ `standby/changeShift`  
→ `loading` with `loaderCode=LDR-201`  
→ `hauling` with `haulingCode=HL-088`  
→ `dumping`  
→ End Shift

### Example B
Start Shift  
→ `standby/changeShift`  
→ `hauling` with `haulingCode=TRIP12`  
→ `engine`  
→ `refueling`  
→ End Shift

---

## 12. Simplifications

- no idle state
- no loading location
- no dumping input
- no pause/resume
- no undo
- no concurrent activities
- no conflict handling

---

**End of Document**
