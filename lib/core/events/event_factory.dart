import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

import 'event_models.dart';

class EventFactory {
  EventFactory({
    required this.deviceId,
    Uuid? uuid,
    Clock? clockSource,
  })  : _uuid = uuid ?? const Uuid(),
        _clock = clockSource ?? clock;

  final String deviceId;
  final Uuid _uuid;
  final Clock _clock;

  EventEnvelope create({
    required EventType eventType,
    required String operatorId,
    required String? unitId,
    required Map<String, dynamic> payload,
    String? correctionOfEventId,
  }) {
    final now = _clock.now().toUtc();
    final eventId = _uuid.v4();
    return EventEnvelope(
      eventId: eventId,
      idempotencyKey: '$deviceId:$eventId',
      eventType: eventType,
      occurredAtUtc: now,
      deviceId: deviceId,
      operatorId: operatorId,
      unitId: unitId,
      payloadJson: jsonEncode(payload),
      status: SyncStatus.pending,
      retryCount: 0,
      createdAtUtc: now,
      correctionOfEventId: correctionOfEventId,
    );
  }
}
