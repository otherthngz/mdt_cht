# MDT Phase 1 POC — Master Prompt (FINAL)

You are building a **Flutter-based Android tablet application** for the **Mobile Dispatch Terminal (MDT)** system.

This is a **Phase 1 POC** and must strictly follow the provided documentation.

---

## 1. SOURCE OF TRUTH

If any conflict exists, follow this order:

1. 01_PRD.md
2. 02_EVENT_DICTIONARY.md
3. 03_STATE_MACHINE.md
4. 04_UI_MAPPING.md
5. 05_DATA_MODEL.md
6. 06_ARCHITECTURE.md
7. 07_MOCK_API_SPEC.md
8. 08_COMPONENT_SPEC.md
9. 09_EVENT_FLOW.md

Do not invent logic outside these files.

---

## 2. TECHNOLOGY (MANDATORY)

* Framework: Flutter (Android Tablet ONLY)
* Language: Dart
* State Management: Riverpod (MANDATORY)
* Storage: Hive (MANDATORY)
* UI: Material 3 (Light Theme ONLY)

DO NOT generate:

* React
* Vue
* Web apps
* Kotlin native apps

---

## 3. CORE SYSTEM RULES

### State Rules

* No idle state
* After Start Shift → auto start:

  * standby / changeShift
* Only ONE activity active at a time

---

### Event Rules

Start Shift:

* SHIFT_STARTED
* ACTIVITY_STARTED (standby/changeShift)

Switch Activity:

* ACTIVITY_ENDED
* ACTIVITY_STARTED

End Shift:

* ACTIVITY_ENDED
* SHIFT_ENDED

Both switch events MUST share the same timestamp.

---

### Input Rules

Loading:

* requires `loaderCode`
* must be **alphanumeric (string)**

Hauling:

* requires `haulingCode`
* must be **alphanumeric (string)**

Dumping:

* no input

---

### Data Rules

Persist ONLY:

* ShiftSession
* ActivityEvent[]

DO NOT persist:

* timesheet
* summary
* counts
* duration

Everything must be derived.

---

## 4. NAMING RULE (STRICT)

Use EXACT names from docs. Do not rename.

Fields:

* shiftSessionId
* activityCategory
* activitySubtype
* loaderCode
* haulingCode

Enums:

* changeShift
* nonProductive
* roadIssue
* extremeDust
* lightningStorm
* undercarriageBody
* brakeSteering

---

## 5. ARCHITECTURE RULES

Follow layered architecture:

UI → State → Controller → Repository → Storage

Rules:

* UI = presentation only
* Controller = business logic
* Repository = data access
* No business logic inside widgets

---

## 6. TIMER RULE

* Timer = device time
* elapsed = now - startedAt
* Do NOT persist timer
* Must resume correctly after app restart

---

## 7. STATE RESTORATION

When app reopens:

* restore active shift session
* restore current activity
* restore timer source

Do NOT auto-create new shift.

---

## 8. UI RULES

* Tablet-first layout
* Light theme only
* High contrast
* Large touch targets
* Active activity card always visible

Modal ONLY for:

* Loading
* Hauling

---

## 9. MCP / FIGMA RULE

If UI is generated from MCP:

* Treat it as layout reference ONLY
* DO NOT extract business logic from Figma
* DO NOT infer new state or events

All logic must come from:

* Event Dictionary
* State Machine

---

## 10. FILE CHANGE RULE

* Modify only relevant files
* DO NOT rewrite entire project
* DO NOT touch unrelated modules
* Prefer incremental updates

---

## 11. IMPLEMENTATION RULES

* Use strongly typed Dart models
* Use null safety
* Keep widgets reusable and small
* Use Riverpod providers properly
* No placeholder logic

---

## 12. EXECUTION STRATEGY

DO NOT build everything at once.

Work in steps:

1. Setup project structure
2. Data models
3. Repositories + storage
4. Start Shift flow
5. Main Activity screen
6. Loading / Hauling modal
7. Timesheet
8. Summary

---

## 13. QUALITY GUARDRAILS

Reject any implementation that:

* introduces idle state
* requires loading location
* requires dumping input
* stores derived data
* allows multiple active activities
* uses dark mode as primary theme
* restricts loaderCode/haulingCode to numeric only

---

## 14. OUTPUT RULE

* Generate clean production-ready Flutter code
* Follow folder structure from Architecture
* Keep naming consistent with docs
* No unnecessary explanation unless asked

---

## 15. HOW TO USE

First send this prompt.

Then send specific tasks like:

* “Implement Start Shift flow”
* “Implement Main Activity screen”
* “Implement Loading modal”
* “Implement Timesheet builder”

Never ask to generate full app in one step.

