# User Stories (MDT Offline-First POC)

1. As an operator, I want to log in offline with Operator ID + PIN so I can start work even without network.
2. As an operator, I want to select my unit before starting so all events are tied to the correct equipment.
3. As an operator, I want to record HM Start offline so shift baseline meter data is never lost.
4. As an operator, I want to submit P2H issues with optional reason codes and notes so I can capture safety/mechanical context quickly.
5. As an operator, I want the app to auto-derive P2H outcome (PASS, PASS_WITH_NOTES, FAIL) so rule handling is consistent.
6. As an operator, I want to start and stop exactly one activity timer at a time so my activity log is unambiguous.
7. As an operator, I want to categorize activity as Production/Non-Production and Running/Standby-Delay/Breakdown so recorded utilization is structured.
8. As an operator, I want to create radio assignments manually when dispatch comes over radio so I can still track work when system assignments are unavailable.
9. As an operator, I want to accept or reject assignments with a reason so dispatch decisions are auditable.
10. As an operator, I want all actions stored locally first so I do not lose data when connectivity drops mid-shift.
11. As an operator, I want sync retries to avoid creating duplicates so server data stays clean after flaky network periods.
12. As an operator, I want failed conflict events to remain visible (not overwritten) so I can understand what failed and create an explicit correction.
13. As an operator, I want to run manual “Sync now” so I can force upload when I know connectivity is back.
14. As an operator, I want to end shift with HM End offline so closing records are captured immediately.
15. As a system owner, I want immutable append-only events with correction links so all historical changes are traceable.
