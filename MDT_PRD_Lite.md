# MDT PRD Lite (Offline-First POC)

## Product Goal
Deliver a mobile-only MDT app (Flutter) for mining operators to capture accurate unit and activity data with minimal friction, fully offline, and synchronize later.

## In Scope (MDT only)
- Login
- Select Unit
- HM Start
- P2H
- Activity Timer
- Dispatch Inbox
- End Shift + HM End
- Sync Status

## Out of Scope
- Dashboards
- Web portal
- Reports/analytics screens
- Fleet management back-office workflows

## Primary Users
- Operator (main actor)
- Dispatcher/system assignment source (consumed through sync; no dispatcher UI in app)

## Core Principles
- Offline-first: all core workflows work with no internet.
- Append-only local event log: no silent overwrite/update of historical facts.
- Corrections are explicit new events referencing original event IDs.
- Sync queue status is explicit per event: `PENDING`, `SENT`, `FAILED`.
- Idempotent sync: retries reuse the same event UUID + idempotency key.

## Functional Summary by Flow
1. Login: Operator enters ID + PIN. App validates locally and records `LOGIN_RECORDED`.
2. Select Unit: Operator picks unit and records `UNIT_SELECTED`.
3. HM Start: Operator records start meter; app opens shift session and records `HM_START_RECORDED`.
4. P2H: Operator submits issues (optional reason code; supports Other + note). App calculates:
   - Any CRITICAL issue => `FAIL`
   - Else any issue => `PASS_WITH_NOTES`
   - Else => `PASS`
5. Activity Timer: Operator starts/stops one active activity at a time with category/state.
6. Dispatch Inbox:
   - System assignments fetched when online.
   - Radio assignments logged manually with source `RADIO`.
   - Operator accepts/rejects with reason; event queued for sync.
7. End Shift + HM End: Operator records HM end and closes shift.
8. Sync Status: Shows queue counts and errors, supports manual `Sync now`, and correction-event creation for assignment conflicts.

## Data and Sync Rules
- Every user action persists an immutable event to local DB first.
- Sync service sends queued events to `/v1/events` with `Idempotency-Key`.
- Success (`200/201`) and duplicate responses mark event `SENT`.
- Conflict (`ASSIGNMENT_STATE_MISMATCH`) keeps event `FAILED` and prompts correction event.
- Transient/network failures stay `FAILED` with exponential backoff + jitter for retry scheduling.

## UX Notes (Current MDT build)
- Screen order: Login -> Select Unit -> HM Start -> MDT Menu -> (P2H / Activity Timer / Dispatch Inbox / End Shift + HM End / Sync Status).
- Confirmation modals currently used for:
  - Log Radio Assignment
  - Accept/Reject Assignment (reason capture)
  - Create Correction Event

## Non-Functional Requirements
- Fast local writes and reads on low connectivity.
- Durable storage in SQLite (Drift runtime access).
- Deterministic sync behavior under retry and duplicate delivery.

## Open Alignment Note
`MDT.pdf` was not found in the workspace during documentation generation. Labels/order/modals above reflect current MDT implementation and should be reconciled against `MDT.pdf` once provided.
