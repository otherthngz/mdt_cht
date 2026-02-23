# MDT FMS PTBA (Offline-First POC)

Mobile Data Terminal (MDT) POC to capture operator + unit activity offline and sync later using an append-only event log.

## Features
- Offline-first core flows (no network required for primary operations)
- Append-only immutable local event log
- Sync queue statuses: `PENDING`, `SENT`, `FAILED`
- Event idempotency (`UUID` + `idempotencyKey`) for safe retries
- PDF-aligned MDT flow from `MDT.pdf`:
  - Login (keypad)
  - CN UNIT + HM Mulai
  - P2H checklist (`1x aman, 2x bermasalah, 3x reset`) + submit confirmation
  - Status Saat Ini (`ACTIVITY`, `STANDBY`, `BREAKDOWN`) + End Shift confirmation
  - CN UNIT + HM Akhir
  - Ringkasan Pekerjaan + Logout
  - Activity Log chooser + Active timer/Stop branch

## Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio or Xcode (for emulator/simulator)

## Setup
```bash
flutter create .
flutter pub get
```

## Run
```bash
flutter run
```

## Implemented MDT screens
- Login
- CN UNIT : H515 (`Masukan Hourmeter`, `Masuk`)
- Pengecekan dan Pemeriksaan Harian (P2H)
- Status Saat Ini
- Activity Log
- Active Timer
- CN UNIT : H515 (`Masukan Hourmeter`, `Konfirmasi`)
- Ringkasan Pekerjaan

## Data model highlights
- Local append-only `event_log` with immutable event payloads
- Correction events reference `correction_of_event_id`
- Sync queue status values stored as `PENDING`, `SENT`, `FAILED`
- Assignment conflicts are retained as `FAILED` and surfaced for correction

## Generate code (if needed)
This project is implemented without required codegen for Drift tables (raw SQL through Drift runtime), but dependencies include generators for extensibility.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Tests
```bash
flutter test
```

## Offline-first notes
- Core actions always write local immutable events first.
- Sync can be triggered manually via **Sync now** or by periodic online checks.
- Failed conflict events are preserved as `FAILED`; operator creates correction events.

## Known POC constraints
- Server is source of truth for assignment state.
- Corrections are append-only events referencing originals.
- Background sync runs while app is active.
