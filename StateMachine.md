# State Machine (MDT POC)

## 1) ShiftSession

### States
- `NOT_STARTED`
- `ACTIVE`
- `ENDED`

### Transitions
- `NOT_STARTED --(HM_START_RECORDED)--> ACTIVE`
- `ACTIVE --(HM_END_RECORDED + SHIFT_ENDED)--> ENDED`

### Guards
- HM start requires logged-in operator + selected unit.
- HM end requires active shift session ID.

### Invalid/Edge Cases
- HM End without active session => reject action.
- Starting a second shift while one is active => reject action.

---

## 2) ActivityTimer

### States
- `IDLE`
- `RUNNING`

### Transitions
- `IDLE --(ACTIVITY_STARTED)--> RUNNING`
- `RUNNING --(ACTIVITY_STOPPED)--> IDLE`
- `RUNNING --(ACTIVITY_CORRECTED)--> RUNNING or IDLE` (correction event semantics depend on corrected data)

### Guards
- Single active timer per unit/session.
- Stop timestamp must be >= start timestamp.

### Invalid/Edge Cases
- Start while already RUNNING => reject.
- Stop while IDLE => reject.
- Correction does not mutate old events; emits a new event with `correctionOfEventId`.

---

## 3) SyncQueue (per event)

### States
- `PENDING`
- `SENT`
- `FAILED`

### Transitions
- `PENDING --(sync applied or duplicate)--> SENT`
- `PENDING --(network/transient/server 5xx)--> FAILED`
- `FAILED --(retry due + transient/network again)--> FAILED` (retryCount++, nextRetryAt updated)
- `FAILED --(retry due + applied/duplicate)--> SENT`
- `FAILED --(ASSIGNMENT_STATE_MISMATCH)--> FAILED` (no auto-retry schedule required; user correction path)

### Retry Policy
- Exponential backoff + jitter: `min(300, 2^retryCount * 5 + jitter(0..3))` seconds.

### Notes
- Queue selection: `PENDING` OR `FAILED` with `nextRetryAtUtc <= now`.
- Conflict failures stay failed until operator creates correction event.
