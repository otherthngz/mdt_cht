import 'package:flutter_test/flutter_test.dart';
import 'package:mdt_fms_ptba/core/events/event_factory.dart';
import 'package:mdt_fms_ptba/core/events/event_models.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('EventFactory', () {
    test('creates UUID event with stable idempotency and pending status', () {
      final factory = EventFactory(deviceId: 'DEVICE-1');

      final event = factory.create(
        eventType: EventType.loginRecorded,
        operatorId: 'OP-1',
        unitId: null,
        payload: const {'x': 'y'},
      );

      expect(Uuid.isValidUUID(fromString: event.eventId), isTrue);
      expect(event.idempotencyKey, 'DEVICE-1:${event.eventId}');
      expect(event.status, SyncStatus.pending);
      expect(event.retryCount, 0);
    });

    test('preserves correction linkage', () {
      final factory = EventFactory(deviceId: 'DEVICE-1');
      final event = factory.create(
        eventType: EventType.assignmentDecisionCorrection,
        operatorId: 'OP-2',
        unitId: 'DT-101',
        payload: const {'correction': true},
        correctionOfEventId: 'orig-123',
      );

      expect(event.correctionOfEventId, 'orig-123');
    });
  });
}
