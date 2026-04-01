# MDT Phase 1 POC — Component Specification

Version: 4.0  
Status: Aligned with Event-First Data Model  

---

# 1. Purpose

Defines reusable Flutter UI components and screen-level composition aligned with:

- Event-driven architecture
- Derived state rendering
- Stateless UI principles

This document ensures:
- Figma ↔ Flutter consistency
- strict separation of concerns
- no business logic leakage into UI

---

# 2. Core Principles

- UI is presentation-only
- state is reconstructed from ActivityEvent[]
- no derived data stored in widgets
- reusable + composable components
- tablet-first usability
- high readability for operators

---

# 3. Architecture Alignment

## 3.1 Source of Truth
- ShiftSession
- ActivityEvent[]

## 3.2 Derived (DO NOT STORE IN UI)
- TimesheetRow[]
- ShiftSummary

## 3.3 UI Responsibility

UI MUST:
- emit user intent (actions)
- render derived state

UI MUST NOT:
- compute duration
- compute totals
- store HM delta
- generate timesheet rows

---

# 4. Screen-Level Components

---

## 4.1 StartShiftPage

### Purpose
Initialize ShiftSession

### Contains:
- Header
- Input: Unit ID
- Input: Operator ID
- Input: HM Start
- PrimaryActionButton: Start Shift

### Output (Controller):
- Create ShiftSession
- Emit SHIFT_STARTED

---

## 4.2 MainActivityPage

### Purpose
Control and monitor active activity

### Contains:
- StatusBar
- ActiveActivityCard
- CategoryGrid
- SecondaryActionButton: View Timesheet
- PrimaryActionButton: End Shift

### Initial State:
After Start Shift:
- category: standby
- subtype: changeShift

(derived or default fallback)

---

## 4.3 TimesheetPage

### Purpose
Display activity audit log

### Contains:
- Header
- Summary strip (derived)
- TimesheetTable
- SecondaryActionButton: Back

### Data Source:
Derived TimesheetRow[]

---

## 4.4 SummaryPage

### Purpose
Display shift metrics

### Contains:
- Shift info section
- SummaryMetricCards
- PA / UA metrics
- SecondaryActionButton: View Timesheet
- PrimaryActionButton: Start New Shift

### Data Source:
Derived ShiftSummary

---

# 5. Reusable Components

---

## 5.1 StatusBar

### Inputs:
- unitId
- operatorId
- currentTime

### Notes:
- display-only
- no logic

---

## 5.2 ActiveActivityCard

### Inputs (Derived):
- category
- subtype
- elapsedSeconds
- isActive
- loaderCode
- haulingCode

### Notes:
- elapsedSeconds from controller
- no internal timer

---

## 5.3 CategoryButton

### Inputs:
- label
- isActive
- accentColor
- onTap

### Behavior:
- triggers intent only

---

## 5.4 CategoryGrid

### Contains:
- operation
- standby
- delay
- breakdown

### Output:
→ open SubActivitySheet

---

## 5.5 SubActivitySheet

### Purpose:
Select activity subtype

### Inputs:
- category
- subtypes
- currentSubtype
- onSelect
- onCancel

### Output:
→ triggers ACTIVITY_STARTED

---

## 5.6 CodeInputModal

### Modes:
- Loading → requires loaderCode
- Hauling → requires haulingCode

### Inputs:
- title
- fieldLabel
- value
- errorText
- isValid
- onChanged
- onSubmit
- onCancel

### Behavior:
- alphanumeric only
- submit disabled if invalid

### Output:
→ enrich ACTIVITY_STARTED event

---

## 5.7 TimesheetTable

### Data Source:
Derived TimesheetRow[]

### Columns:
- Start Time
- End Time
- Category
- Activity
- Duration (derived)
- HM Start (derived)
- HM End (derived)
- Delta HM (derived)
- Loader Code
- Hauling Code
- Loading Count (derived)
- Hauling Count (derived)

### Rules:
- read-only
- no calculation

---

## 5.8 SummaryMetricCard

### Inputs:
- label
- value
- accent (optional)

---

## 5.9 PrimaryActionButton

### Use Cases:
- Start Shift
- Confirm Activity
- Confirm End Shift
- Start New Shift

---

## 5.10 SecondaryActionButton

### Use Cases:
- Cancel
- Back
- View Timesheet

---

## 5.11 ConfirmationDialog

### Use Case:
- End Shift ONLY

### Output:
→ SHIFT_ENDED

---

# 6. Interaction Flow

---

## Start Activity

CategoryButton  
→ SubActivitySheet  
→ (optional) CodeInputModal  
→ ACTIVITY_STARTED  

---

## Switch Activity

ACTIVITY_ENDED  
→ ACTIVITY_STARTED  

---

## Stop Activity

User stops  
→ ACTIVITY_ENDED  

---

## End Shift

End Shift Button  
→ ConfirmationDialog  
→ SHIFT_ENDED  

---

# 7. Layout Rules

---

## MainActivityPage
- ActiveActivityCard always visible
- CategoryGrid reachable
- End Shift low emphasis

---

## TimesheetPage
- horizontal scroll allowed
- prioritize readability

---

## SummaryPage
- metrics prioritized
- PA / UA emphasized

---

# 8. Visual Rules

- light theme only
- high contrast text
- semantic colors:
  - operation = green
  - standby = blue
  - delay = orange
  - breakdown = red
- timer prominent
- minimum font size = 16sp

---

# 9. Validation Ownership

---

## Controller MUST:
- validate HM input
- validate activity
- validate loaderCode / haulingCode
- enforce event rules

---

## UI MUST:
- display validation
- not own logic

---

# 10. Anti-Patterns

- no business logic inside widgets
- no duration calculation in UI
- no timesheet derivation in UI
- no summary calculation in UI
- no direct event mutation inside widgets

---

# 11. Key Constraint

UI = Stateless Renderer  

Everything displayed must be derived from:
- ActivityEvent[]
- ShiftSession

---

# 12. Future Expansion

- sync status banner
- correction modal
- filter chips
- export feature
- anomaly indicator

---

# 13. Open Questions

- timer ownership (controller vs service)
- offline sync strategy
- conflict resolution

---

**End of Document**