# Event Schema (Append-Only)

## Event Envelope
Each record in `event_log` is immutable and written once.

```json
{
  "eventId": "uuid-v4",
  "idempotencyKey": "<deviceId>:<eventId>",
  "eventType": "LOGIN_RECORDED",
  "occurredAtUtc": "2026-02-23T14:00:00Z",
  "deviceId": "POC-DEVICE-001",
  "operatorId": "OP-001",
  "unitId": "DT-101",
  "payloadJson": "{...}",
  "status": "PENDING",
  "retryCount": 0,
  "nextRetryAtUtc": null,
  "lastErrorCode": null,
  "lastErrorMessage": null,
  "correctionOfEventId": null,
  "createdAtUtc": "2026-02-23T14:00:00Z"
}
```

## Event Types
- `LOGIN_RECORDED`
- `UNIT_SELECTED`
- `HM_START_RECORDED`
- `HM_END_RECORDED`
- `P2H_SUBMITTED`
- `ACTIVITY_STARTED`
- `ACTIVITY_STOPPED`
- `ACTIVITY_CORRECTED`
- `ASSIGNMENT_RECEIVED_SYSTEM`
- `ASSIGNMENT_CREATED_RADIO`
- `ASSIGNMENT_DECISION_SUBMITTED`
- `ASSIGNMENT_DECISION_CORRECTION`
- `SHIFT_ENDED`

## Correction Event Pattern
- Original event remains unchanged.
- New correction event is appended with:
  - `correctionOfEventId = <originalEventId>`
  - payload containing `originalEventId`, `originalEventType`, `originalPayload`, and `correction` object.

Example payload snippet:
```json
{
  "originalEventId": "evt-123",
  "originalEventType": "ASSIGNMENT_DECISION_SUBMITTED",
  "originalPayload": {"assignmentId": "A-1001", "decision": "reject"},
  "correction": {"decision": "accept", "note": "Corrected after dispatcher confirmation"}
}
```

## Sync + Idempotency Semantics
- `eventId` is globally unique UUID.
- `idempotencyKey` is stable per event and reused on retries.
- Duplicate server acknowledge must be treated as success (`SENT`).
- State mismatch (`ASSIGNMENT_STATE_MISMATCH`) must stay `FAILED`; operator creates explicit correction event.
