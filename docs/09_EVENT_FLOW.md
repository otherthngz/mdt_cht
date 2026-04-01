# 09_EVENT_FLOW.md

# MDT Phase 1 POC — Event Flow Reference

**Version:** 3.0  
**Status:** Optional / Recommended  

---

## 1. Purpose

Provides real examples of expected event sequences.

Useful for:
- QA
- debugging
- Flutter sanity check
- AI-assisted generation checks

---

## 2. Core Rules Reminder

- no idle state
- Start Shift auto-starts `standby / changeShift`
- one active activity at a time
- switch:
  - `ACTIVITY_ENDED`
  - `ACTIVITY_STARTED`
- end shift:
  - `ACTIVITY_ENDED`
  - `SHIFT_ENDED`

---

## 3. Flow A — Standard Productive Flow

```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. ACTIVITY_ENDED     standby / changeShift
4. ACTIVITY_STARTED   operation / loading   loaderCode=LDR-201
5. ACTIVITY_ENDED     operation / loading
6. ACTIVITY_STARTED   operation / hauling   haulingCode=HL-088
7. ACTIVITY_ENDED     operation / hauling
8. ACTIVITY_STARTED   operation / dumping
9. ACTIVITY_ENDED     operation / dumping
10. ACTIVITY_STARTED  standby / waiting
11. ACTIVITY_ENDED    standby / waiting
12. ACTIVITY_STARTED  operation / loading   loaderCode=EX202
13. ACTIVITY_ENDED    operation / loading
14. SHIFT_ENDED
```

---

## 4. Flow B — Breakdown During Shift

```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. ACTIVITY_ENDED     standby / changeShift
4. ACTIVITY_STARTED   operation / hauling   haulingCode=TRIP12
5. ACTIVITY_ENDED     operation / hauling
6. ACTIVITY_STARTED   breakdown / engine
7. ACTIVITY_ENDED     breakdown / engine
8. ACTIVITY_STARTED   standby / refueling
9. ACTIVITY_ENDED     standby / refueling
10. SHIFT_ENDED
```

---

## 5. Flow C — Delay During Shift

```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. ACTIVITY_ENDED     standby / changeShift
4. ACTIVITY_STARTED   operation / loading   loaderCode=LDR200
5. ACTIVITY_ENDED     operation / loading
6. ACTIVITY_STARTED   delay / rain
7. ACTIVITY_ENDED     delay / rain
8. ACTIVITY_STARTED   operation / hauling   haulingCode=H15
9. ACTIVITY_ENDED     operation / hauling
10. SHIFT_ENDED
```

---

## 6. Flow D — End Shift While Activity Running

```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. ACTIVITY_ENDED     standby / changeShift
4. ACTIVITY_STARTED   standby / waiting
5. ACTIVITY_ENDED     standby / waiting
6. SHIFT_ENDED
```

---

## 7. Flow E — Modal Cancel

### Loading cancel
```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. User selects loading
4. Loading modal opens
5. User taps Cancel
6. No event generated
7. Current activity remains standby / changeShift
```

### Hauling cancel
```text
1. SHIFT_STARTED
2. ACTIVITY_STARTED   standby / changeShift
3. User selects hauling
4. Hauling modal opens
5. User taps Cancel
6. No event generated
7. Current activity remains standby / changeShift
```

---

## 8. Flow F — Same Activity Tapped Again

```text
1. Current activity = standby / waiting
2. User taps standby / waiting again
3. No event generated
4. No state change
```

---

## 9. Derived Output Expectations

- Loading Count increments only on `ACTIVITY_STARTED` with subtype `loading`
- Hauling Count increments only on `ACTIVITY_STARTED` with subtype `hauling`
- Timesheet rows come from paired start/end events
- Summary comes from shift session + full event history

---

## 10. QA Checklist

- Start Shift always creates 2 events
- no idle state ever appears
- one active activity at a time
- Loading requires loaderCode
- Hauling requires haulingCode
- both codes are alphanumeric
- Dumping requires no modal
- modal cancel creates no event
- End Shift always ends current activity first

---

**End of Document**
