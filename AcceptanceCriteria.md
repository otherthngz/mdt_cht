# Acceptance Criteria (MDT Screens)

## Login
- Operator can enter ID and PIN with no network.
- Invalid input (empty ID, short PIN) blocks submission with clear feedback.
- Successful submit appends `LOGIN_RECORDED` as `PENDING`.
- Navigates to Select Unit after successful local write.

## Select Unit
- Operator can select exactly one unit.
- Continue is disabled until a unit is selected.
- Successful submit appends `UNIT_SELECTED` event.
- Navigates to HM Start.

## HM Start
- Operator sees selected operator + unit context.
- HM Start requires valid numeric input.
- Successful submit creates/opens shift session and appends `HM_START_RECORDED`.
- Navigates to MDT menu.

## P2H
- Operator can submit with no issues (PASS path).
- Operator can add issues with severity, optional reason code, and optional notes.
- “Other” reason supports free-text notes.
- Outcome rule is deterministic:
  - Any critical issue => `FAIL`
  - Else any issue => `PASS_WITH_NOTES`
  - Else => `PASS`
- Submit appends `P2H_SUBMITTED` event.

## Activity Timer
- Operator can start one activity only when no activity is active.
- Activity requires category + state; reason/note optional.
- Stop only works if an activity is active.
- Stop appends `ACTIVITY_STOPPED` with elapsed duration.
- Start/stop fully works offline.

## Dispatch Inbox
- Operator can manually refresh system assignments when online.
- Operator can log radio assignment via modal; source is `RADIO`.
- Operator can accept/reject assignment with reason via confirmation modal.
- Decision appends `ASSIGNMENT_DECISION_SUBMITTED` event.
- Assignment state conflict does not auto-overwrite; handled via sync failure + correction flow.

## End Shift + HM End
- Requires active shift session and numeric HM End.
- Submission appends `HM_END_RECORDED` and `SHIFT_ENDED`.
- Shift is closed locally even if offline.

## Sync Status
- Shows counts for `PENDING`, `SENT`, `FAILED`.
- Manual `Sync now` processes eligible queue events.
- Applied/duplicate sync responses mark events `SENT`.
- Transient failures remain `FAILED` with scheduled retry metadata.
- Conflict failures (`ASSIGNMENT_STATE_MISMATCH`) remain `FAILED` and expose “Create correction” action.

## Global Offline + Data Integrity
- All primary user actions write to local event log before network calls.
- Existing events are never silently edited or deleted.
- Corrections are appended as new events linked to originals.
- Retries must reuse original idempotency key and must not create duplicates server-side.
