# 04_UI_MAPPING.md

# UI State & Event Mapping — MDT Phase 1 POC

**Version:** 3.0  
**Status:** Refactored / Aligned  

---

## 1. Purpose

Maps each UI screen to:
- state context
- visible elements
- user actions
- generated events
- next state

This is the bridge between design (Figma) and implementation (Flutter).

---

## 2. Mapping Principles

- state-driven UI
- no hidden states
- no idle screen
- business labels can differ, logic cannot
- PRD / Event Dictionary / State Machine take precedence

---

## 3. Screen Mapping

### 3.1 Start Shift Screen

State:
- `shiftState = notStarted`

Visible:
- unitId input
- operatorId input
- hmStart input
- Start Shift button

Action mapping:

| Action | Event(s) | Next State |
|---|---|---|
| valid Start Shift | `SHIFT_STARTED`, `ACTIVITY_STARTED (standby/changeShift)` | `active / standby` |
| invalid Start Shift | none | no change |

---

### 3.2 Main Activity Screen — Active

State:
- `shiftState = active`
- `activityState = operation | standby | delay | breakdown`

Visible:
- status bar
- active activity card
- timer
- category buttons
- View Timesheet
- End Shift

Right after Start Shift:
- active card must show `Standby / Change Shift`
- timer starts immediately

Action mapping:

| Action | Event(s) | Next State |
|---|---|---|
| tap category | none | open subtype sheet |
| tap same active subtype | none | no change |
| tap End Shift | none | open End Shift flow |

---

### 3.3 Sub-Activity Selection Sheet

Visible:
- selected category
- subtype list
- active subtype indicator
- cancel

Subtype rules:

| Subtype | Modal? | Required Field |
|---|---|---|
| Loading | yes | `loaderCode` |
| Hauling | yes | `haulingCode` |
| Dumping | no | — |
| Others | no | — |

Action mapping:

| Action | Event(s) | Next State |
|---|---|---|
| select subtype without modal | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` | active / selected category |
| select Loading then submit modal | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` | active / operation |
| select Hauling then submit modal | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` | active / operation |
| cancel | none | no change |

---

### 3.4 Conditional Input Modal

#### Loading Modal
Fields:
- `loaderCode` (required, alphanumeric)

#### Hauling Modal
Fields:
- `haulingCode` (required, alphanumeric)

Behavior:
- submit button disabled until valid
- cancel closes modal with no change
- on submit:
  - end current activity
  - start selected activity

---

### 3.5 Timesheet Screen

State:
- `shiftState = active` or `ended`

Visible:
- shift header
- summary strip
- timesheet table
- back button

Columns:
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

Rules:
- read-only
- counts are derived
- irrelevant fields remain empty

---

### 3.6 End Shift Flow

State:
- `shiftState = active`

Visible:
- hmEnd input
- Confirm End Shift
- Cancel
- confirmation message

Action mapping:

| Action | Event(s) | Next State |
|---|---|---|
| confirm valid hmEnd | `ACTIVITY_ENDED`, `SHIFT_ENDED` | ended |
| cancel | none | no change |

---

### 3.7 Summary Screen

State:
- `shiftState = ended`

Visible:
- shift info
- operation / standby / delay / breakdown totals
- PA / UA
- HM summary
- View Detailed Timesheet
- Start New Shift

Rules:
- read-only
- no events generated here

---

## 4. Screen-to-Event Master Table

| Screen | Action | Events |
|---|---|---|
| Start Shift | submit valid form | `SHIFT_STARTED`, `ACTIVITY_STARTED` |
| Main Screen | tap category | none |
| Subtype Sheet | select subtype without modal | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` |
| Loading Modal | submit valid code | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` |
| Hauling Modal | submit valid code | `ACTIVITY_ENDED`, `ACTIVITY_STARTED` |
| End Shift | confirm | `ACTIVITY_ENDED`, `SHIFT_ENDED` |
| Timesheet | any | none |
| Summary | any | none |

---

## 5. Figma Alignment Notes

1. each frame should represent one state context
2. there must be no idle frame
3. after Start Shift, first active frame must already show:
   - `Standby / Change Shift`
   - running timer
4. Loading and Hauling must use modal flow
5. Dumping must not use modal flow
6. Figma labels may differ from internal field names, but logic must follow docs

---

## 6. POC Constraints

- no idle state
- no manual timesheet editing
- no pause/resume
- no undo
- no correction flow
- no loading location
- no dumping input

---

**End of Document**
