// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EventLogTable extends EventLog
    with TableInfo<$EventLogTable, EventLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtUtcMeta =
      const VerificationMeta('occurredAtUtc');
  @override
  late final GeneratedColumn<String> occurredAtUtc = GeneratedColumn<String>(
      'occurred_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtUtcMeta =
      const VerificationMeta('nextRetryAtUtc');
  @override
  late final GeneratedColumn<String> nextRetryAtUtc = GeneratedColumn<String>(
      'next_retry_at_utc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorCodeMeta =
      const VerificationMeta('lastErrorCode');
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
      'last_error_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMessageMeta =
      const VerificationMeta('lastErrorMessage');
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
      'last_error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _correctionOfEventIdMeta =
      const VerificationMeta('correctionOfEventId');
  @override
  late final GeneratedColumn<String> correctionOfEventId =
      GeneratedColumn<String>('correction_of_event_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        eventId,
        idempotencyKey,
        eventType,
        occurredAtUtc,
        deviceId,
        operatorId,
        unitId,
        payloadJson,
        status,
        retryCount,
        nextRetryAtUtc,
        lastErrorCode,
        lastErrorMessage,
        correctionOfEventId,
        createdAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_log';
  @override
  VerificationContext validateIntegrity(Insertable<EventLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
          _occurredAtUtcMeta,
          occurredAtUtc.isAcceptableOrUnknown(
              data['occurred_at_utc']!, _occurredAtUtcMeta));
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_retry_at_utc')) {
      context.handle(
          _nextRetryAtUtcMeta,
          nextRetryAtUtc.isAcceptableOrUnknown(
              data['next_retry_at_utc']!, _nextRetryAtUtcMeta));
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
          _lastErrorCodeMeta,
          lastErrorCode.isAcceptableOrUnknown(
              data['last_error_code']!, _lastErrorCodeMeta));
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
          _lastErrorMessageMeta,
          lastErrorMessage.isAcceptableOrUnknown(
              data['last_error_message']!, _lastErrorMessageMeta));
    }
    if (data.containsKey('correction_of_event_id')) {
      context.handle(
          _correctionOfEventIdMeta,
          correctionOfEventId.isAcceptableOrUnknown(
              data['correction_of_event_id']!, _correctionOfEventIdMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  EventLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventLogData(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}occurred_at_utc'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextRetryAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}next_retry_at_utc']),
      lastErrorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error_code']),
      lastErrorMessage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_error_message']),
      correctionOfEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}correction_of_event_id']),
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_utc'])!,
    );
  }

  @override
  $EventLogTable createAlias(String alias) {
    return $EventLogTable(attachedDatabase, alias);
  }
}

class EventLogData extends DataClass implements Insertable<EventLogData> {
  final String eventId;
  final String idempotencyKey;
  final String eventType;
  final String occurredAtUtc;
  final String deviceId;
  final String operatorId;
  final String? unitId;
  final String payloadJson;
  final String status;
  final int retryCount;
  final String? nextRetryAtUtc;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final String? correctionOfEventId;
  final String createdAtUtc;
  const EventLogData(
      {required this.eventId,
      required this.idempotencyKey,
      required this.eventType,
      required this.occurredAtUtc,
      required this.deviceId,
      required this.operatorId,
      this.unitId,
      required this.payloadJson,
      required this.status,
      required this.retryCount,
      this.nextRetryAtUtc,
      this.lastErrorCode,
      this.lastErrorMessage,
      this.correctionOfEventId,
      required this.createdAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at_utc'] = Variable<String>(occurredAtUtc);
    map['device_id'] = Variable<String>(deviceId);
    map['operator_id'] = Variable<String>(operatorId);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAtUtc != null) {
      map['next_retry_at_utc'] = Variable<String>(nextRetryAtUtc);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    if (!nullToAbsent || correctionOfEventId != null) {
      map['correction_of_event_id'] = Variable<String>(correctionOfEventId);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    return map;
  }

  EventLogCompanion toCompanion(bool nullToAbsent) {
    return EventLogCompanion(
      eventId: Value(eventId),
      idempotencyKey: Value(idempotencyKey),
      eventType: Value(eventType),
      occurredAtUtc: Value(occurredAtUtc),
      deviceId: Value(deviceId),
      operatorId: Value(operatorId),
      unitId:
          unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryCount: Value(retryCount),
      nextRetryAtUtc: nextRetryAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAtUtc),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      correctionOfEventId: correctionOfEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionOfEventId),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory EventLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventLogData(
      eventId: serializer.fromJson<String>(json['eventId']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAtUtc: serializer.fromJson<String>(json['occurredAtUtc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAtUtc: serializer.fromJson<String?>(json['nextRetryAtUtc']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      correctionOfEventId:
          serializer.fromJson<String?>(json['correctionOfEventId']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAtUtc': serializer.toJson<String>(occurredAtUtc),
      'deviceId': serializer.toJson<String>(deviceId),
      'operatorId': serializer.toJson<String>(operatorId),
      'unitId': serializer.toJson<String?>(unitId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAtUtc': serializer.toJson<String?>(nextRetryAtUtc),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'correctionOfEventId': serializer.toJson<String?>(correctionOfEventId),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
    };
  }

  EventLogData copyWith(
          {String? eventId,
          String? idempotencyKey,
          String? eventType,
          String? occurredAtUtc,
          String? deviceId,
          String? operatorId,
          Value<String?> unitId = const Value.absent(),
          String? payloadJson,
          String? status,
          int? retryCount,
          Value<String?> nextRetryAtUtc = const Value.absent(),
          Value<String?> lastErrorCode = const Value.absent(),
          Value<String?> lastErrorMessage = const Value.absent(),
          Value<String?> correctionOfEventId = const Value.absent(),
          String? createdAtUtc}) =>
      EventLogData(
        eventId: eventId ?? this.eventId,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        eventType: eventType ?? this.eventType,
        occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
        deviceId: deviceId ?? this.deviceId,
        operatorId: operatorId ?? this.operatorId,
        unitId: unitId.present ? unitId.value : this.unitId,
        payloadJson: payloadJson ?? this.payloadJson,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        nextRetryAtUtc:
            nextRetryAtUtc.present ? nextRetryAtUtc.value : this.nextRetryAtUtc,
        lastErrorCode:
            lastErrorCode.present ? lastErrorCode.value : this.lastErrorCode,
        lastErrorMessage: lastErrorMessage.present
            ? lastErrorMessage.value
            : this.lastErrorMessage,
        correctionOfEventId: correctionOfEventId.present
            ? correctionOfEventId.value
            : this.correctionOfEventId,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  EventLogData copyWithCompanion(EventLogCompanion data) {
    return EventLogData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextRetryAtUtc: data.nextRetryAtUtc.present
          ? data.nextRetryAtUtc.value
          : this.nextRetryAtUtc,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      correctionOfEventId: data.correctionOfEventId.present
          ? data.correctionOfEventId.value
          : this.correctionOfEventId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventLogData(')
          ..write('eventId: $eventId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('deviceId: $deviceId, ')
          ..write('operatorId: $operatorId, ')
          ..write('unitId: $unitId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAtUtc: $nextRetryAtUtc, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('correctionOfEventId: $correctionOfEventId, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      eventId,
      idempotencyKey,
      eventType,
      occurredAtUtc,
      deviceId,
      operatorId,
      unitId,
      payloadJson,
      status,
      retryCount,
      nextRetryAtUtc,
      lastErrorCode,
      lastErrorMessage,
      correctionOfEventId,
      createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventLogData &&
          other.eventId == this.eventId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.eventType == this.eventType &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.deviceId == this.deviceId &&
          other.operatorId == this.operatorId &&
          other.unitId == this.unitId &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextRetryAtUtc == this.nextRetryAtUtc &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.correctionOfEventId == this.correctionOfEventId &&
          other.createdAtUtc == this.createdAtUtc);
}

class EventLogCompanion extends UpdateCompanion<EventLogData> {
  final Value<String> eventId;
  final Value<String> idempotencyKey;
  final Value<String> eventType;
  final Value<String> occurredAtUtc;
  final Value<String> deviceId;
  final Value<String> operatorId;
  final Value<String?> unitId;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> nextRetryAtUtc;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<String?> correctionOfEventId;
  final Value<String> createdAtUtc;
  final Value<int> rowid;
  const EventLogCompanion({
    this.eventId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAtUtc = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.correctionOfEventId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventLogCompanion.insert({
    required String eventId,
    required String idempotencyKey,
    required String eventType,
    required String occurredAtUtc,
    required String deviceId,
    required String operatorId,
    this.unitId = const Value.absent(),
    required String payloadJson,
    required String status,
    this.retryCount = const Value.absent(),
    this.nextRetryAtUtc = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.correctionOfEventId = const Value.absent(),
    required String createdAtUtc,
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        idempotencyKey = Value(idempotencyKey),
        eventType = Value(eventType),
        occurredAtUtc = Value(occurredAtUtc),
        deviceId = Value(deviceId),
        operatorId = Value(operatorId),
        payloadJson = Value(payloadJson),
        status = Value(status),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<EventLogData> custom({
    Expression<String>? eventId,
    Expression<String>? idempotencyKey,
    Expression<String>? eventType,
    Expression<String>? occurredAtUtc,
    Expression<String>? deviceId,
    Expression<String>? operatorId,
    Expression<String>? unitId,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? nextRetryAtUtc,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<String>? correctionOfEventId,
    Expression<String>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (eventType != null) 'event_type': eventType,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (deviceId != null) 'device_id': deviceId,
      if (operatorId != null) 'operator_id': operatorId,
      if (unitId != null) 'unit_id': unitId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAtUtc != null) 'next_retry_at_utc': nextRetryAtUtc,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (correctionOfEventId != null)
        'correction_of_event_id': correctionOfEventId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventLogCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? idempotencyKey,
      Value<String>? eventType,
      Value<String>? occurredAtUtc,
      Value<String>? deviceId,
      Value<String>? operatorId,
      Value<String?>? unitId,
      Value<String>? payloadJson,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? nextRetryAtUtc,
      Value<String?>? lastErrorCode,
      Value<String?>? lastErrorMessage,
      Value<String?>? correctionOfEventId,
      Value<String>? createdAtUtc,
      Value<int>? rowid}) {
    return EventLogCompanion(
      eventId: eventId ?? this.eventId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      eventType: eventType ?? this.eventType,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      deviceId: deviceId ?? this.deviceId,
      operatorId: operatorId ?? this.operatorId,
      unitId: unitId ?? this.unitId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAtUtc: nextRetryAtUtc ?? this.nextRetryAtUtc,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      correctionOfEventId: correctionOfEventId ?? this.correctionOfEventId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<String>(occurredAtUtc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAtUtc.present) {
      map['next_retry_at_utc'] = Variable<String>(nextRetryAtUtc.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (correctionOfEventId.present) {
      map['correction_of_event_id'] =
          Variable<String>(correctionOfEventId.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventLogCompanion(')
          ..write('eventId: $eventId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('deviceId: $deviceId, ')
          ..write('operatorId: $operatorId, ')
          ..write('unitId: $unitId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAtUtc: $nextRetryAtUtc, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('correctionOfEventId: $correctionOfEventId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, Assignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverStateMeta =
      const VerificationMeta('serverState');
  @override
  late final GeneratedColumn<String> serverState = GeneratedColumn<String>(
      'server_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receivedAtUtcMeta =
      const VerificationMeta('receivedAtUtc');
  @override
  late final GeneratedColumn<String> receivedAtUtc = GeneratedColumn<String>(
      'received_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        assignmentId,
        source,
        serverState,
        title,
        details,
        receivedAtUtc,
        version,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(Insertable<Assignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('server_state')) {
      context.handle(
          _serverStateMeta,
          serverState.isAcceptableOrUnknown(
              data['server_state']!, _serverStateMeta));
    } else if (isInserting) {
      context.missing(_serverStateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    if (data.containsKey('received_at_utc')) {
      context.handle(
          _receivedAtUtcMeta,
          receivedAtUtc.isAcceptableOrUnknown(
              data['received_at_utc']!, _receivedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_receivedAtUtcMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assignmentId};
  @override
  Assignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assignment(
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assignment_id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      serverState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_state'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
      receivedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}received_at_utc'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class Assignment extends DataClass implements Insertable<Assignment> {
  final String assignmentId;
  final String source;
  final String serverState;
  final String title;
  final String? details;
  final String receivedAtUtc;
  final int version;
  final bool isActive;
  const Assignment(
      {required this.assignmentId,
      required this.source,
      required this.serverState,
      required this.title,
      this.details,
      required this.receivedAtUtc,
      required this.version,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assignment_id'] = Variable<String>(assignmentId);
    map['source'] = Variable<String>(source);
    map['server_state'] = Variable<String>(serverState);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['received_at_utc'] = Variable<String>(receivedAtUtc);
    map['version'] = Variable<int>(version);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      assignmentId: Value(assignmentId),
      source: Value(source),
      serverState: Value(serverState),
      title: Value(title),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      receivedAtUtc: Value(receivedAtUtc),
      version: Value(version),
      isActive: Value(isActive),
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assignment(
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      source: serializer.fromJson<String>(json['source']),
      serverState: serializer.fromJson<String>(json['serverState']),
      title: serializer.fromJson<String>(json['title']),
      details: serializer.fromJson<String?>(json['details']),
      receivedAtUtc: serializer.fromJson<String>(json['receivedAtUtc']),
      version: serializer.fromJson<int>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assignmentId': serializer.toJson<String>(assignmentId),
      'source': serializer.toJson<String>(source),
      'serverState': serializer.toJson<String>(serverState),
      'title': serializer.toJson<String>(title),
      'details': serializer.toJson<String?>(details),
      'receivedAtUtc': serializer.toJson<String>(receivedAtUtc),
      'version': serializer.toJson<int>(version),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Assignment copyWith(
          {String? assignmentId,
          String? source,
          String? serverState,
          String? title,
          Value<String?> details = const Value.absent(),
          String? receivedAtUtc,
          int? version,
          bool? isActive}) =>
      Assignment(
        assignmentId: assignmentId ?? this.assignmentId,
        source: source ?? this.source,
        serverState: serverState ?? this.serverState,
        title: title ?? this.title,
        details: details.present ? details.value : this.details,
        receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
      );
  Assignment copyWithCompanion(AssignmentsCompanion data) {
    return Assignment(
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      source: data.source.present ? data.source.value : this.source,
      serverState:
          data.serverState.present ? data.serverState.value : this.serverState,
      title: data.title.present ? data.title.value : this.title,
      details: data.details.present ? data.details.value : this.details,
      receivedAtUtc: data.receivedAtUtc.present
          ? data.receivedAtUtc.value
          : this.receivedAtUtc,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assignment(')
          ..write('assignmentId: $assignmentId, ')
          ..write('source: $source, ')
          ..write('serverState: $serverState, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assignmentId, source, serverState, title,
      details, receivedAtUtc, version, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assignment &&
          other.assignmentId == this.assignmentId &&
          other.source == this.source &&
          other.serverState == this.serverState &&
          other.title == this.title &&
          other.details == this.details &&
          other.receivedAtUtc == this.receivedAtUtc &&
          other.version == this.version &&
          other.isActive == this.isActive);
}

class AssignmentsCompanion extends UpdateCompanion<Assignment> {
  final Value<String> assignmentId;
  final Value<String> source;
  final Value<String> serverState;
  final Value<String> title;
  final Value<String?> details;
  final Value<String> receivedAtUtc;
  final Value<int> version;
  final Value<bool> isActive;
  final Value<int> rowid;
  const AssignmentsCompanion({
    this.assignmentId = const Value.absent(),
    this.source = const Value.absent(),
    this.serverState = const Value.absent(),
    this.title = const Value.absent(),
    this.details = const Value.absent(),
    this.receivedAtUtc = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    required String assignmentId,
    required String source,
    required String serverState,
    required String title,
    this.details = const Value.absent(),
    required String receivedAtUtc,
    required int version,
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : assignmentId = Value(assignmentId),
        source = Value(source),
        serverState = Value(serverState),
        title = Value(title),
        receivedAtUtc = Value(receivedAtUtc),
        version = Value(version),
        isActive = Value(isActive);
  static Insertable<Assignment> custom({
    Expression<String>? assignmentId,
    Expression<String>? source,
    Expression<String>? serverState,
    Expression<String>? title,
    Expression<String>? details,
    Expression<String>? receivedAtUtc,
    Expression<int>? version,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (source != null) 'source': source,
      if (serverState != null) 'server_state': serverState,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (receivedAtUtc != null) 'received_at_utc': receivedAtUtc,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsCompanion copyWith(
      {Value<String>? assignmentId,
      Value<String>? source,
      Value<String>? serverState,
      Value<String>? title,
      Value<String?>? details,
      Value<String>? receivedAtUtc,
      Value<int>? version,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return AssignmentsCompanion(
      assignmentId: assignmentId ?? this.assignmentId,
      source: source ?? this.source,
      serverState: serverState ?? this.serverState,
      title: title ?? this.title,
      details: details ?? this.details,
      receivedAtUtc: receivedAtUtc ?? this.receivedAtUtc,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (serverState.present) {
      map['server_state'] = Variable<String>(serverState.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (receivedAtUtc.present) {
      map['received_at_utc'] = Variable<String>(receivedAtUtc.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('assignmentId: $assignmentId, ')
          ..write('source: $source, ')
          ..write('serverState: $serverState, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('receivedAtUtc: $receivedAtUtc, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReasonCodesTable extends ReasonCodes
    with TableInfo<$ReasonCodesTable, ReasonCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReasonCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [code, groupName, label, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reason_codes';
  @override
  VerificationContext validateIntegrity(Insertable<ReasonCode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    } else if (isInserting) {
      context.missing(_activeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ReasonCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReasonCode(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $ReasonCodesTable createAlias(String alias) {
    return $ReasonCodesTable(attachedDatabase, alias);
  }
}

class ReasonCode extends DataClass implements Insertable<ReasonCode> {
  final String code;
  final String groupName;
  final String label;
  final bool active;
  const ReasonCode(
      {required this.code,
      required this.groupName,
      required this.label,
      required this.active});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['group_name'] = Variable<String>(groupName);
    map['label'] = Variable<String>(label);
    map['active'] = Variable<bool>(active);
    return map;
  }

  ReasonCodesCompanion toCompanion(bool nullToAbsent) {
    return ReasonCodesCompanion(
      code: Value(code),
      groupName: Value(groupName),
      label: Value(label),
      active: Value(active),
    );
  }

  factory ReasonCode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReasonCode(
      code: serializer.fromJson<String>(json['code']),
      groupName: serializer.fromJson<String>(json['groupName']),
      label: serializer.fromJson<String>(json['label']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'groupName': serializer.toJson<String>(groupName),
      'label': serializer.toJson<String>(label),
      'active': serializer.toJson<bool>(active),
    };
  }

  ReasonCode copyWith(
          {String? code, String? groupName, String? label, bool? active}) =>
      ReasonCode(
        code: code ?? this.code,
        groupName: groupName ?? this.groupName,
        label: label ?? this.label,
        active: active ?? this.active,
      );
  ReasonCode copyWithCompanion(ReasonCodesCompanion data) {
    return ReasonCode(
      code: data.code.present ? data.code.value : this.code,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      label: data.label.present ? data.label.value : this.label,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReasonCode(')
          ..write('code: $code, ')
          ..write('groupName: $groupName, ')
          ..write('label: $label, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, groupName, label, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReasonCode &&
          other.code == this.code &&
          other.groupName == this.groupName &&
          other.label == this.label &&
          other.active == this.active);
}

class ReasonCodesCompanion extends UpdateCompanion<ReasonCode> {
  final Value<String> code;
  final Value<String> groupName;
  final Value<String> label;
  final Value<bool> active;
  final Value<int> rowid;
  const ReasonCodesCompanion({
    this.code = const Value.absent(),
    this.groupName = const Value.absent(),
    this.label = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReasonCodesCompanion.insert({
    required String code,
    required String groupName,
    required String label,
    required bool active,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        groupName = Value(groupName),
        label = Value(label),
        active = Value(active);
  static Insertable<ReasonCode> custom({
    Expression<String>? code,
    Expression<String>? groupName,
    Expression<String>? label,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (groupName != null) 'group_name': groupName,
      if (label != null) 'label': label,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReasonCodesCompanion copyWith(
      {Value<String>? code,
      Value<String>? groupName,
      Value<String>? label,
      Value<bool>? active,
      Value<int>? rowid}) {
    return ReasonCodesCompanion(
      code: code ?? this.code,
      groupName: groupName ?? this.groupName,
      label: label ?? this.label,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReasonCodesCompanion(')
          ..write('code: $code, ')
          ..write('groupName: $groupName, ')
          ..write('label: $label, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftSessionTable extends ShiftSession
    with TableInfo<$ShiftSessionTable, ShiftSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftSessionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hmStartMeta =
      const VerificationMeta('hmStart');
  @override
  late final GeneratedColumn<double> hmStart = GeneratedColumn<double>(
      'hm_start', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hmEndMeta = const VerificationMeta('hmEnd');
  @override
  late final GeneratedColumn<double> hmEnd = GeneratedColumn<double>(
      'hm_end', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _startedAtUtcMeta =
      const VerificationMeta('startedAtUtc');
  @override
  late final GeneratedColumn<String> startedAtUtc = GeneratedColumn<String>(
      'started_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endedAtUtcMeta =
      const VerificationMeta('endedAtUtc');
  @override
  late final GeneratedColumn<String> endedAtUtc = GeneratedColumn<String>(
      'ended_at_utc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [sessionId, operatorId, unitId, hmStart, hmEnd, startedAtUtc, endedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_session';
  @override
  VerificationContext validateIntegrity(Insertable<ShiftSessionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('hm_start')) {
      context.handle(_hmStartMeta,
          hmStart.isAcceptableOrUnknown(data['hm_start']!, _hmStartMeta));
    }
    if (data.containsKey('hm_end')) {
      context.handle(
          _hmEndMeta, hmEnd.isAcceptableOrUnknown(data['hm_end']!, _hmEndMeta));
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
          _startedAtUtcMeta,
          startedAtUtc.isAcceptableOrUnknown(
              data['started_at_utc']!, _startedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('ended_at_utc')) {
      context.handle(
          _endedAtUtcMeta,
          endedAtUtc.isAcceptableOrUnknown(
              data['ended_at_utc']!, _endedAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  ShiftSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftSessionData(
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      hmStart: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hm_start']),
      hmEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hm_end']),
      startedAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}started_at_utc'])!,
      endedAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ended_at_utc']),
    );
  }

  @override
  $ShiftSessionTable createAlias(String alias) {
    return $ShiftSessionTable(attachedDatabase, alias);
  }
}

class ShiftSessionData extends DataClass
    implements Insertable<ShiftSessionData> {
  final String sessionId;
  final String operatorId;
  final String unitId;
  final double? hmStart;
  final double? hmEnd;
  final String startedAtUtc;
  final String? endedAtUtc;
  const ShiftSessionData(
      {required this.sessionId,
      required this.operatorId,
      required this.unitId,
      this.hmStart,
      this.hmEnd,
      required this.startedAtUtc,
      this.endedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['operator_id'] = Variable<String>(operatorId);
    map['unit_id'] = Variable<String>(unitId);
    if (!nullToAbsent || hmStart != null) {
      map['hm_start'] = Variable<double>(hmStart);
    }
    if (!nullToAbsent || hmEnd != null) {
      map['hm_end'] = Variable<double>(hmEnd);
    }
    map['started_at_utc'] = Variable<String>(startedAtUtc);
    if (!nullToAbsent || endedAtUtc != null) {
      map['ended_at_utc'] = Variable<String>(endedAtUtc);
    }
    return map;
  }

  ShiftSessionCompanion toCompanion(bool nullToAbsent) {
    return ShiftSessionCompanion(
      sessionId: Value(sessionId),
      operatorId: Value(operatorId),
      unitId: Value(unitId),
      hmStart: hmStart == null && nullToAbsent
          ? const Value.absent()
          : Value(hmStart),
      hmEnd:
          hmEnd == null && nullToAbsent ? const Value.absent() : Value(hmEnd),
      startedAtUtc: Value(startedAtUtc),
      endedAtUtc: endedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtc),
    );
  }

  factory ShiftSessionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftSessionData(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      unitId: serializer.fromJson<String>(json['unitId']),
      hmStart: serializer.fromJson<double?>(json['hmStart']),
      hmEnd: serializer.fromJson<double?>(json['hmEnd']),
      startedAtUtc: serializer.fromJson<String>(json['startedAtUtc']),
      endedAtUtc: serializer.fromJson<String?>(json['endedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'operatorId': serializer.toJson<String>(operatorId),
      'unitId': serializer.toJson<String>(unitId),
      'hmStart': serializer.toJson<double?>(hmStart),
      'hmEnd': serializer.toJson<double?>(hmEnd),
      'startedAtUtc': serializer.toJson<String>(startedAtUtc),
      'endedAtUtc': serializer.toJson<String?>(endedAtUtc),
    };
  }

  ShiftSessionData copyWith(
          {String? sessionId,
          String? operatorId,
          String? unitId,
          Value<double?> hmStart = const Value.absent(),
          Value<double?> hmEnd = const Value.absent(),
          String? startedAtUtc,
          Value<String?> endedAtUtc = const Value.absent()}) =>
      ShiftSessionData(
        sessionId: sessionId ?? this.sessionId,
        operatorId: operatorId ?? this.operatorId,
        unitId: unitId ?? this.unitId,
        hmStart: hmStart.present ? hmStart.value : this.hmStart,
        hmEnd: hmEnd.present ? hmEnd.value : this.hmEnd,
        startedAtUtc: startedAtUtc ?? this.startedAtUtc,
        endedAtUtc: endedAtUtc.present ? endedAtUtc.value : this.endedAtUtc,
      );
  ShiftSessionData copyWithCompanion(ShiftSessionCompanion data) {
    return ShiftSessionData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      hmStart: data.hmStart.present ? data.hmStart.value : this.hmStart,
      hmEnd: data.hmEnd.present ? data.hmEnd.value : this.hmEnd,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc:
          data.endedAtUtc.present ? data.endedAtUtc.value : this.endedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftSessionData(')
          ..write('sessionId: $sessionId, ')
          ..write('operatorId: $operatorId, ')
          ..write('unitId: $unitId, ')
          ..write('hmStart: $hmStart, ')
          ..write('hmEnd: $hmEnd, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      sessionId, operatorId, unitId, hmStart, hmEnd, startedAtUtc, endedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftSessionData &&
          other.sessionId == this.sessionId &&
          other.operatorId == this.operatorId &&
          other.unitId == this.unitId &&
          other.hmStart == this.hmStart &&
          other.hmEnd == this.hmEnd &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc);
}

class ShiftSessionCompanion extends UpdateCompanion<ShiftSessionData> {
  final Value<String> sessionId;
  final Value<String> operatorId;
  final Value<String> unitId;
  final Value<double?> hmStart;
  final Value<double?> hmEnd;
  final Value<String> startedAtUtc;
  final Value<String?> endedAtUtc;
  final Value<int> rowid;
  const ShiftSessionCompanion({
    this.sessionId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.hmStart = const Value.absent(),
    this.hmEnd = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftSessionCompanion.insert({
    required String sessionId,
    required String operatorId,
    required String unitId,
    this.hmStart = const Value.absent(),
    this.hmEnd = const Value.absent(),
    required String startedAtUtc,
    this.endedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : sessionId = Value(sessionId),
        operatorId = Value(operatorId),
        unitId = Value(unitId),
        startedAtUtc = Value(startedAtUtc);
  static Insertable<ShiftSessionData> custom({
    Expression<String>? sessionId,
    Expression<String>? operatorId,
    Expression<String>? unitId,
    Expression<double>? hmStart,
    Expression<double>? hmEnd,
    Expression<String>? startedAtUtc,
    Expression<String>? endedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (operatorId != null) 'operator_id': operatorId,
      if (unitId != null) 'unit_id': unitId,
      if (hmStart != null) 'hm_start': hmStart,
      if (hmEnd != null) 'hm_end': hmEnd,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftSessionCompanion copyWith(
      {Value<String>? sessionId,
      Value<String>? operatorId,
      Value<String>? unitId,
      Value<double?>? hmStart,
      Value<double?>? hmEnd,
      Value<String>? startedAtUtc,
      Value<String?>? endedAtUtc,
      Value<int>? rowid}) {
    return ShiftSessionCompanion(
      sessionId: sessionId ?? this.sessionId,
      operatorId: operatorId ?? this.operatorId,
      unitId: unitId ?? this.unitId,
      hmStart: hmStart ?? this.hmStart,
      hmEnd: hmEnd ?? this.hmEnd,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (hmStart.present) {
      map['hm_start'] = Variable<double>(hmStart.value);
    }
    if (hmEnd.present) {
      map['hm_end'] = Variable<double>(hmEnd.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<String>(startedAtUtc.value);
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<String>(endedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftSessionCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('operatorId: $operatorId, ')
          ..write('unitId: $unitId, ')
          ..write('hmStart: $hmStart, ')
          ..write('hmEnd: $hmEnd, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventLogTable eventLog = $EventLogTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $ReasonCodesTable reasonCodes = $ReasonCodesTable(this);
  late final $ShiftSessionTable shiftSession = $ShiftSessionTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [eventLog, assignments, reasonCodes, shiftSession];
}

typedef $$EventLogTableCreateCompanionBuilder = EventLogCompanion Function({
  required String eventId,
  required String idempotencyKey,
  required String eventType,
  required String occurredAtUtc,
  required String deviceId,
  required String operatorId,
  Value<String?> unitId,
  required String payloadJson,
  required String status,
  Value<int> retryCount,
  Value<String?> nextRetryAtUtc,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<String?> correctionOfEventId,
  required String createdAtUtc,
  Value<int> rowid,
});
typedef $$EventLogTableUpdateCompanionBuilder = EventLogCompanion Function({
  Value<String> eventId,
  Value<String> idempotencyKey,
  Value<String> eventType,
  Value<String> occurredAtUtc,
  Value<String> deviceId,
  Value<String> operatorId,
  Value<String?> unitId,
  Value<String> payloadJson,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> nextRetryAtUtc,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<String?> correctionOfEventId,
  Value<String> createdAtUtc,
  Value<int> rowid,
});

class $$EventLogTableFilterComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occurredAtUtc => $composableBuilder(
      column: $table.occurredAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextRetryAtUtc => $composableBuilder(
      column: $table.nextRetryAtUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctionOfEventId => $composableBuilder(
      column: $table.correctionOfEventId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));
}

class $$EventLogTableOrderingComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occurredAtUtc => $composableBuilder(
      column: $table.occurredAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextRetryAtUtc => $composableBuilder(
      column: $table.nextRetryAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctionOfEventId => $composableBuilder(
      column: $table.correctionOfEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$EventLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventLogTable> {
  $$EventLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get occurredAtUtc => $composableBuilder(
      column: $table.occurredAtUtc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get nextRetryAtUtc => $composableBuilder(
      column: $table.nextRetryAtUtc, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
      column: $table.lastErrorCode, builder: (column) => column);

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
      column: $table.lastErrorMessage, builder: (column) => column);

  GeneratedColumn<String> get correctionOfEventId => $composableBuilder(
      column: $table.correctionOfEventId, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);
}

class $$EventLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventLogTable,
    EventLogData,
    $$EventLogTableFilterComposer,
    $$EventLogTableOrderingComposer,
    $$EventLogTableAnnotationComposer,
    $$EventLogTableCreateCompanionBuilder,
    $$EventLogTableUpdateCompanionBuilder,
    (EventLogData, BaseReferences<_$AppDatabase, $EventLogTable, EventLogData>),
    EventLogData,
    PrefetchHooks Function()> {
  $$EventLogTableTableManager(_$AppDatabase db, $EventLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> occurredAtUtc = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<String?> unitId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> nextRetryAtUtc = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<String?> correctionOfEventId = const Value.absent(),
            Value<String> createdAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventLogCompanion(
            eventId: eventId,
            idempotencyKey: idempotencyKey,
            eventType: eventType,
            occurredAtUtc: occurredAtUtc,
            deviceId: deviceId,
            operatorId: operatorId,
            unitId: unitId,
            payloadJson: payloadJson,
            status: status,
            retryCount: retryCount,
            nextRetryAtUtc: nextRetryAtUtc,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            correctionOfEventId: correctionOfEventId,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String idempotencyKey,
            required String eventType,
            required String occurredAtUtc,
            required String deviceId,
            required String operatorId,
            Value<String?> unitId = const Value.absent(),
            required String payloadJson,
            required String status,
            Value<int> retryCount = const Value.absent(),
            Value<String?> nextRetryAtUtc = const Value.absent(),
            Value<String?> lastErrorCode = const Value.absent(),
            Value<String?> lastErrorMessage = const Value.absent(),
            Value<String?> correctionOfEventId = const Value.absent(),
            required String createdAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              EventLogCompanion.insert(
            eventId: eventId,
            idempotencyKey: idempotencyKey,
            eventType: eventType,
            occurredAtUtc: occurredAtUtc,
            deviceId: deviceId,
            operatorId: operatorId,
            unitId: unitId,
            payloadJson: payloadJson,
            status: status,
            retryCount: retryCount,
            nextRetryAtUtc: nextRetryAtUtc,
            lastErrorCode: lastErrorCode,
            lastErrorMessage: lastErrorMessage,
            correctionOfEventId: correctionOfEventId,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventLogTable,
    EventLogData,
    $$EventLogTableFilterComposer,
    $$EventLogTableOrderingComposer,
    $$EventLogTableAnnotationComposer,
    $$EventLogTableCreateCompanionBuilder,
    $$EventLogTableUpdateCompanionBuilder,
    (EventLogData, BaseReferences<_$AppDatabase, $EventLogTable, EventLogData>),
    EventLogData,
    PrefetchHooks Function()>;
typedef $$AssignmentsTableCreateCompanionBuilder = AssignmentsCompanion
    Function({
  required String assignmentId,
  required String source,
  required String serverState,
  required String title,
  Value<String?> details,
  required String receivedAtUtc,
  required int version,
  required bool isActive,
  Value<int> rowid,
});
typedef $$AssignmentsTableUpdateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<String> assignmentId,
  Value<String> source,
  Value<String> serverState,
  Value<String> title,
  Value<String?> details,
  Value<String> receivedAtUtc,
  Value<int> version,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverState => $composableBuilder(
      column: $table.serverState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receivedAtUtc => $composableBuilder(
      column: $table.receivedAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverState => $composableBuilder(
      column: $table.serverState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receivedAtUtc => $composableBuilder(
      column: $table.receivedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get serverState => $composableBuilder(
      column: $table.serverState, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get receivedAtUtc => $composableBuilder(
      column: $table.receivedAtUtc, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$AssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment>),
    Assignment,
    PrefetchHooks Function()> {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> assignmentId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> serverState = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<String> receivedAtUtc = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion(
            assignmentId: assignmentId,
            source: source,
            serverState: serverState,
            title: title,
            details: details,
            receivedAtUtc: receivedAtUtc,
            version: version,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assignmentId,
            required String source,
            required String serverState,
            required String title,
            Value<String?> details = const Value.absent(),
            required String receivedAtUtc,
            required int version,
            required bool isActive,
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion.insert(
            assignmentId: assignmentId,
            source: source,
            serverState: serverState,
            title: title,
            details: details,
            receivedAtUtc: receivedAtUtc,
            version: version,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment>),
    Assignment,
    PrefetchHooks Function()>;
typedef $$ReasonCodesTableCreateCompanionBuilder = ReasonCodesCompanion
    Function({
  required String code,
  required String groupName,
  required String label,
  required bool active,
  Value<int> rowid,
});
typedef $$ReasonCodesTableUpdateCompanionBuilder = ReasonCodesCompanion
    Function({
  Value<String> code,
  Value<String> groupName,
  Value<String> label,
  Value<bool> active,
  Value<int> rowid,
});

class $$ReasonCodesTableFilterComposer
    extends Composer<_$AppDatabase, $ReasonCodesTable> {
  $$ReasonCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));
}

class $$ReasonCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReasonCodesTable> {
  $$ReasonCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));
}

class $$ReasonCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReasonCodesTable> {
  $$ReasonCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$ReasonCodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReasonCodesTable,
    ReasonCode,
    $$ReasonCodesTableFilterComposer,
    $$ReasonCodesTableOrderingComposer,
    $$ReasonCodesTableAnnotationComposer,
    $$ReasonCodesTableCreateCompanionBuilder,
    $$ReasonCodesTableUpdateCompanionBuilder,
    (ReasonCode, BaseReferences<_$AppDatabase, $ReasonCodesTable, ReasonCode>),
    ReasonCode,
    PrefetchHooks Function()> {
  $$ReasonCodesTableTableManager(_$AppDatabase db, $ReasonCodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReasonCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReasonCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReasonCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReasonCodesCompanion(
            code: code,
            groupName: groupName,
            label: label,
            active: active,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String groupName,
            required String label,
            required bool active,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReasonCodesCompanion.insert(
            code: code,
            groupName: groupName,
            label: label,
            active: active,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReasonCodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReasonCodesTable,
    ReasonCode,
    $$ReasonCodesTableFilterComposer,
    $$ReasonCodesTableOrderingComposer,
    $$ReasonCodesTableAnnotationComposer,
    $$ReasonCodesTableCreateCompanionBuilder,
    $$ReasonCodesTableUpdateCompanionBuilder,
    (ReasonCode, BaseReferences<_$AppDatabase, $ReasonCodesTable, ReasonCode>),
    ReasonCode,
    PrefetchHooks Function()>;
typedef $$ShiftSessionTableCreateCompanionBuilder = ShiftSessionCompanion
    Function({
  required String sessionId,
  required String operatorId,
  required String unitId,
  Value<double?> hmStart,
  Value<double?> hmEnd,
  required String startedAtUtc,
  Value<String?> endedAtUtc,
  Value<int> rowid,
});
typedef $$ShiftSessionTableUpdateCompanionBuilder = ShiftSessionCompanion
    Function({
  Value<String> sessionId,
  Value<String> operatorId,
  Value<String> unitId,
  Value<double?> hmStart,
  Value<double?> hmEnd,
  Value<String> startedAtUtc,
  Value<String?> endedAtUtc,
  Value<int> rowid,
});

class $$ShiftSessionTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftSessionTable> {
  $$ShiftSessionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hmStart => $composableBuilder(
      column: $table.hmStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hmEnd => $composableBuilder(
      column: $table.hmEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedAtUtc => $composableBuilder(
      column: $table.startedAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endedAtUtc => $composableBuilder(
      column: $table.endedAtUtc, builder: (column) => ColumnFilters(column));
}

class $$ShiftSessionTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftSessionTable> {
  $$ShiftSessionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hmStart => $composableBuilder(
      column: $table.hmStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hmEnd => $composableBuilder(
      column: $table.hmEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedAtUtc => $composableBuilder(
      column: $table.startedAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endedAtUtc => $composableBuilder(
      column: $table.endedAtUtc, builder: (column) => ColumnOrderings(column));
}

class $$ShiftSessionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftSessionTable> {
  $$ShiftSessionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<double> get hmStart =>
      $composableBuilder(column: $table.hmStart, builder: (column) => column);

  GeneratedColumn<double> get hmEnd =>
      $composableBuilder(column: $table.hmEnd, builder: (column) => column);

  GeneratedColumn<String> get startedAtUtc => $composableBuilder(
      column: $table.startedAtUtc, builder: (column) => column);

  GeneratedColumn<String> get endedAtUtc => $composableBuilder(
      column: $table.endedAtUtc, builder: (column) => column);
}

class $$ShiftSessionTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShiftSessionTable,
    ShiftSessionData,
    $$ShiftSessionTableFilterComposer,
    $$ShiftSessionTableOrderingComposer,
    $$ShiftSessionTableAnnotationComposer,
    $$ShiftSessionTableCreateCompanionBuilder,
    $$ShiftSessionTableUpdateCompanionBuilder,
    (
      ShiftSessionData,
      BaseReferences<_$AppDatabase, $ShiftSessionTable, ShiftSessionData>
    ),
    ShiftSessionData,
    PrefetchHooks Function()> {
  $$ShiftSessionTableTableManager(_$AppDatabase db, $ShiftSessionTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftSessionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftSessionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftSessionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sessionId = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<double?> hmStart = const Value.absent(),
            Value<double?> hmEnd = const Value.absent(),
            Value<String> startedAtUtc = const Value.absent(),
            Value<String?> endedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftSessionCompanion(
            sessionId: sessionId,
            operatorId: operatorId,
            unitId: unitId,
            hmStart: hmStart,
            hmEnd: hmEnd,
            startedAtUtc: startedAtUtc,
            endedAtUtc: endedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sessionId,
            required String operatorId,
            required String unitId,
            Value<double?> hmStart = const Value.absent(),
            Value<double?> hmEnd = const Value.absent(),
            required String startedAtUtc,
            Value<String?> endedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftSessionCompanion.insert(
            sessionId: sessionId,
            operatorId: operatorId,
            unitId: unitId,
            hmStart: hmStart,
            hmEnd: hmEnd,
            startedAtUtc: startedAtUtc,
            endedAtUtc: endedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShiftSessionTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShiftSessionTable,
    ShiftSessionData,
    $$ShiftSessionTableFilterComposer,
    $$ShiftSessionTableOrderingComposer,
    $$ShiftSessionTableAnnotationComposer,
    $$ShiftSessionTableCreateCompanionBuilder,
    $$ShiftSessionTableUpdateCompanionBuilder,
    (
      ShiftSessionData,
      BaseReferences<_$AppDatabase, $ShiftSessionTable, ShiftSessionData>
    ),
    ShiftSessionData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventLogTableTableManager get eventLog =>
      $$EventLogTableTableManager(_db, _db.eventLog);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$ReasonCodesTableTableManager get reasonCodes =>
      $$ReasonCodesTableTableManager(_db, _db.reasonCodes);
  $$ShiftSessionTableTableManager get shiftSession =>
      $$ShiftSessionTableTableManager(_db, _db.shiftSession);
}
