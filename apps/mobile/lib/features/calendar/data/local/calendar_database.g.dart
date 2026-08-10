// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_database.dart';

// ignore_for_file: type=lint
class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startUtcMeta = const VerificationMeta(
    'startUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startUtc = GeneratedColumn<DateTime>(
    'start_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<DateTime> endUtc = GeneratedColumn<DateTime>(
    'end_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timezoneNameMeta = const VerificationMeta(
    'timezoneName',
  );
  @override
  late final GeneratedColumn<String> timezoneName = GeneratedColumn<String>(
    'timezone_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalProviderMeta = const VerificationMeta(
    'externalProvider',
  );
  @override
  late final GeneratedColumn<String> externalProvider = GeneratedColumn<String>(
    'external_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalCalendarIdMeta =
      const VerificationMeta('externalCalendarId');
  @override
  late final GeneratedColumn<String> externalCalendarId =
      GeneratedColumn<String>(
        'external_calendar_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _externalEventIdMeta = const VerificationMeta(
    'externalEventId',
  );
  @override
  late final GeneratedColumn<String> externalEventId = GeneratedColumn<String>(
    'external_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMinutesJsonMeta =
      const VerificationMeta('reminderMinutesJson');
  @override
  late final GeneratedColumn<String> reminderMinutesJson =
      GeneratedColumn<String>(
        'reminder_minutes_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAtUtc = GeneratedColumn<DateTime>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    location,
    startUtc,
    endUtc,
    isAllDay,
    timezoneName,
    origin,
    syncStatus,
    externalProvider,
    externalCalendarId,
    externalEventId,
    reminderMinutesJson,
    version,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('start_utc')) {
      context.handle(
        _startUtcMeta,
        startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(
        _endUtcMeta,
        endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_endUtcMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('timezone_name')) {
      context.handle(
        _timezoneNameMeta,
        timezoneName.isAcceptableOrUnknown(
          data['timezone_name']!,
          _timezoneNameMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('external_provider')) {
      context.handle(
        _externalProviderMeta,
        externalProvider.isAcceptableOrUnknown(
          data['external_provider']!,
          _externalProviderMeta,
        ),
      );
    }
    if (data.containsKey('external_calendar_id')) {
      context.handle(
        _externalCalendarIdMeta,
        externalCalendarId.isAcceptableOrUnknown(
          data['external_calendar_id']!,
          _externalCalendarIdMeta,
        ),
      );
    }
    if (data.containsKey('external_event_id')) {
      context.handle(
        _externalEventIdMeta,
        externalEventId.isAcceptableOrUnknown(
          data['external_event_id']!,
          _externalEventIdMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes_json')) {
      context.handle(
        _reminderMinutesJsonMeta,
        reminderMinutesJson.isAcceptableOrUnknown(
          data['reminder_minutes_json']!,
          _reminderMinutesJsonMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {externalCalendarId, externalEventId},
  ];
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      startUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_utc'],
      )!,
      endUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_utc'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      timezoneName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone_name'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      externalProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_provider'],
      ),
      externalCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_calendar_id'],
      ),
      externalEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_event_id'],
      ),
      reminderMinutesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_minutes_json'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at_utc'],
      ),
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String id;
  final String title;
  final String? notes;
  final String? location;
  final DateTime startUtc;
  final DateTime endUtc;
  final bool isAllDay;
  final String? timezoneName;
  final String origin;
  final String syncStatus;
  final String? externalProvider;
  final String? externalCalendarId;
  final String? externalEventId;
  final String reminderMinutesJson;
  final int version;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;
  const CalendarEvent({
    required this.id,
    required this.title,
    this.notes,
    this.location,
    required this.startUtc,
    required this.endUtc,
    required this.isAllDay,
    this.timezoneName,
    required this.origin,
    required this.syncStatus,
    this.externalProvider,
    this.externalCalendarId,
    this.externalEventId,
    required this.reminderMinutesJson,
    required this.version,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['start_utc'] = Variable<DateTime>(startUtc);
    map['end_utc'] = Variable<DateTime>(endUtc);
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || timezoneName != null) {
      map['timezone_name'] = Variable<String>(timezoneName);
    }
    map['origin'] = Variable<String>(origin);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || externalProvider != null) {
      map['external_provider'] = Variable<String>(externalProvider);
    }
    if (!nullToAbsent || externalCalendarId != null) {
      map['external_calendar_id'] = Variable<String>(externalCalendarId);
    }
    if (!nullToAbsent || externalEventId != null) {
      map['external_event_id'] = Variable<String>(externalEventId);
    }
    map['reminder_minutes_json'] = Variable<String>(reminderMinutesJson);
    map['version'] = Variable<int>(version);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc);
    }
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      isAllDay: Value(isAllDay),
      timezoneName: timezoneName == null && nullToAbsent
          ? const Value.absent()
          : Value(timezoneName),
      origin: Value(origin),
      syncStatus: Value(syncStatus),
      externalProvider: externalProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(externalProvider),
      externalCalendarId: externalCalendarId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalCalendarId),
      externalEventId: externalEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalEventId),
      reminderMinutesJson: Value(reminderMinutesJson),
      version: Value(version),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
    );
  }

  factory CalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      location: serializer.fromJson<String?>(json['location']),
      startUtc: serializer.fromJson<DateTime>(json['startUtc']),
      endUtc: serializer.fromJson<DateTime>(json['endUtc']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      timezoneName: serializer.fromJson<String?>(json['timezoneName']),
      origin: serializer.fromJson<String>(json['origin']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      externalProvider: serializer.fromJson<String?>(json['externalProvider']),
      externalCalendarId: serializer.fromJson<String?>(
        json['externalCalendarId'],
      ),
      externalEventId: serializer.fromJson<String?>(json['externalEventId']),
      reminderMinutesJson: serializer.fromJson<String>(
        json['reminderMinutesJson'],
      ),
      version: serializer.fromJson<int>(json['version']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      deletedAtUtc: serializer.fromJson<DateTime?>(json['deletedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'location': serializer.toJson<String?>(location),
      'startUtc': serializer.toJson<DateTime>(startUtc),
      'endUtc': serializer.toJson<DateTime>(endUtc),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'timezoneName': serializer.toJson<String?>(timezoneName),
      'origin': serializer.toJson<String>(origin),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'externalProvider': serializer.toJson<String?>(externalProvider),
      'externalCalendarId': serializer.toJson<String?>(externalCalendarId),
      'externalEventId': serializer.toJson<String?>(externalEventId),
      'reminderMinutesJson': serializer.toJson<String>(reminderMinutesJson),
      'version': serializer.toJson<int>(version),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'deletedAtUtc': serializer.toJson<DateTime?>(deletedAtUtc),
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? startUtc,
    DateTime? endUtc,
    bool? isAllDay,
    Value<String?> timezoneName = const Value.absent(),
    String? origin,
    String? syncStatus,
    Value<String?> externalProvider = const Value.absent(),
    Value<String?> externalCalendarId = const Value.absent(),
    Value<String?> externalEventId = const Value.absent(),
    String? reminderMinutesJson,
    int? version,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> deletedAtUtc = const Value.absent(),
  }) => CalendarEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    location: location.present ? location.value : this.location,
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc ?? this.endUtc,
    isAllDay: isAllDay ?? this.isAllDay,
    timezoneName: timezoneName.present ? timezoneName.value : this.timezoneName,
    origin: origin ?? this.origin,
    syncStatus: syncStatus ?? this.syncStatus,
    externalProvider: externalProvider.present
        ? externalProvider.value
        : this.externalProvider,
    externalCalendarId: externalCalendarId.present
        ? externalCalendarId.value
        : this.externalCalendarId,
    externalEventId: externalEventId.present
        ? externalEventId.value
        : this.externalEventId,
    reminderMinutesJson: reminderMinutesJson ?? this.reminderMinutesJson,
    version: version ?? this.version,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
  );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      location: data.location.present ? data.location.value : this.location,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      timezoneName: data.timezoneName.present
          ? data.timezoneName.value
          : this.timezoneName,
      origin: data.origin.present ? data.origin.value : this.origin,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      externalProvider: data.externalProvider.present
          ? data.externalProvider.value
          : this.externalProvider,
      externalCalendarId: data.externalCalendarId.present
          ? data.externalCalendarId.value
          : this.externalCalendarId,
      externalEventId: data.externalEventId.present
          ? data.externalEventId.value
          : this.externalEventId,
      reminderMinutesJson: data.reminderMinutesJson.present
          ? data.reminderMinutesJson.value
          : this.reminderMinutesJson,
      version: data.version.present ? data.version.value : this.version,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('timezoneName: $timezoneName, ')
          ..write('origin: $origin, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('externalProvider: $externalProvider, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('reminderMinutesJson: $reminderMinutesJson, ')
          ..write('version: $version, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    location,
    startUtc,
    endUtc,
    isAllDay,
    timezoneName,
    origin,
    syncStatus,
    externalProvider,
    externalCalendarId,
    externalEventId,
    reminderMinutesJson,
    version,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.location == this.location &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.isAllDay == this.isAllDay &&
          other.timezoneName == this.timezoneName &&
          other.origin == this.origin &&
          other.syncStatus == this.syncStatus &&
          other.externalProvider == this.externalProvider &&
          other.externalCalendarId == this.externalCalendarId &&
          other.externalEventId == this.externalEventId &&
          other.reminderMinutesJson == this.reminderMinutesJson &&
          other.version == this.version &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String?> location;
  final Value<DateTime> startUtc;
  final Value<DateTime> endUtc;
  final Value<bool> isAllDay;
  final Value<String?> timezoneName;
  final Value<String> origin;
  final Value<String> syncStatus;
  final Value<String?> externalProvider;
  final Value<String?> externalCalendarId;
  final Value<String?> externalEventId;
  final Value<String> reminderMinutesJson;
  final Value<int> version;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> deletedAtUtc;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.timezoneName = const Value.absent(),
    this.origin = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.externalProvider = const Value.absent(),
    this.externalCalendarId = const Value.absent(),
    this.externalEventId = const Value.absent(),
    this.reminderMinutesJson = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime startUtc,
    required DateTime endUtc,
    this.isAllDay = const Value.absent(),
    this.timezoneName = const Value.absent(),
    required String origin,
    required String syncStatus,
    this.externalProvider = const Value.absent(),
    this.externalCalendarId = const Value.absent(),
    this.externalEventId = const Value.absent(),
    this.reminderMinutesJson = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.deletedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       startUtc = Value(startUtc),
       endUtc = Value(endUtc),
       origin = Value(origin),
       syncStatus = Value(syncStatus),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CalendarEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? location,
    Expression<DateTime>? startUtc,
    Expression<DateTime>? endUtc,
    Expression<bool>? isAllDay,
    Expression<String>? timezoneName,
    Expression<String>? origin,
    Expression<String>? syncStatus,
    Expression<String>? externalProvider,
    Expression<String>? externalCalendarId,
    Expression<String>? externalEventId,
    Expression<String>? reminderMinutesJson,
    Expression<int>? version,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? deletedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (timezoneName != null) 'timezone_name': timezoneName,
      if (origin != null) 'origin': origin,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (externalProvider != null) 'external_provider': externalProvider,
      if (externalCalendarId != null)
        'external_calendar_id': externalCalendarId,
      if (externalEventId != null) 'external_event_id': externalEventId,
      if (reminderMinutesJson != null)
        'reminder_minutes_json': reminderMinutesJson,
      if (version != null) 'version': version,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String?>? location,
    Value<DateTime>? startUtc,
    Value<DateTime>? endUtc,
    Value<bool>? isAllDay,
    Value<String?>? timezoneName,
    Value<String>? origin,
    Value<String>? syncStatus,
    Value<String?>? externalProvider,
    Value<String?>? externalCalendarId,
    Value<String?>? externalEventId,
    Value<String>? reminderMinutesJson,
    Value<int>? version,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? deletedAtUtc,
    Value<int>? rowid,
  }) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      isAllDay: isAllDay ?? this.isAllDay,
      timezoneName: timezoneName ?? this.timezoneName,
      origin: origin ?? this.origin,
      syncStatus: syncStatus ?? this.syncStatus,
      externalProvider: externalProvider ?? this.externalProvider,
      externalCalendarId: externalCalendarId ?? this.externalCalendarId,
      externalEventId: externalEventId ?? this.externalEventId,
      reminderMinutesJson: reminderMinutesJson ?? this.reminderMinutesJson,
      version: version ?? this.version,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<DateTime>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<DateTime>(endUtc.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (timezoneName.present) {
      map['timezone_name'] = Variable<String>(timezoneName.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (externalProvider.present) {
      map['external_provider'] = Variable<String>(externalProvider.value);
    }
    if (externalCalendarId.present) {
      map['external_calendar_id'] = Variable<String>(externalCalendarId.value);
    }
    if (externalEventId.present) {
      map['external_event_id'] = Variable<String>(externalEventId.value);
    }
    if (reminderMinutesJson.present) {
      map['reminder_minutes_json'] = Variable<String>(
        reminderMinutesJson.value,
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('timezoneName: $timezoneName, ')
          ..write('origin: $origin, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('externalProvider: $externalProvider, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('reminderMinutesJson: $reminderMinutesJson, ')
          ..write('version: $version, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventLinksTable extends CalendarEventLinks
    with TableInfo<$CalendarEventLinksTable, CalendarEventLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memyEventIdMeta = const VerificationMeta(
    'memyEventId',
  );
  @override
  late final GeneratedColumn<String> memyEventId = GeneratedColumn<String>(
    'memy_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalCalendarIdMeta =
      const VerificationMeta('externalCalendarId');
  @override
  late final GeneratedColumn<String> externalCalendarId =
      GeneratedColumn<String>(
        'external_calendar_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _externalEventIdMeta = const VerificationMeta(
    'externalEventId',
  );
  @override
  late final GeneratedColumn<String> externalEventId = GeneratedColumn<String>(
    'external_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtUtcMeta = const VerificationMeta(
    'lastSyncedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAtUtc =
      GeneratedColumn<DateTime>(
        'last_synced_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastKnownExternalUpdatedAtUtcMeta =
      const VerificationMeta('lastKnownExternalUpdatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastKnownExternalUpdatedAtUtc =
      GeneratedColumn<DateTime>(
        'last_known_external_updated_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memyEventId,
    provider,
    externalCalendarId,
    externalEventId,
    lastSyncedAtUtc,
    lastKnownExternalUpdatedAtUtc,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_event_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEventLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memy_event_id')) {
      context.handle(
        _memyEventIdMeta,
        memyEventId.isAcceptableOrUnknown(
          data['memy_event_id']!,
          _memyEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memyEventIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('external_calendar_id')) {
      context.handle(
        _externalCalendarIdMeta,
        externalCalendarId.isAcceptableOrUnknown(
          data['external_calendar_id']!,
          _externalCalendarIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalCalendarIdMeta);
    }
    if (data.containsKey('external_event_id')) {
      context.handle(
        _externalEventIdMeta,
        externalEventId.isAcceptableOrUnknown(
          data['external_event_id']!,
          _externalEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalEventIdMeta);
    }
    if (data.containsKey('last_synced_at_utc')) {
      context.handle(
        _lastSyncedAtUtcMeta,
        lastSyncedAtUtc.isAcceptableOrUnknown(
          data['last_synced_at_utc']!,
          _lastSyncedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtUtcMeta);
    }
    if (data.containsKey('last_known_external_updated_at_utc')) {
      context.handle(
        _lastKnownExternalUpdatedAtUtcMeta,
        lastKnownExternalUpdatedAtUtc.isAcceptableOrUnknown(
          data['last_known_external_updated_at_utc']!,
          _lastKnownExternalUpdatedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {memyEventId},
    {provider, externalCalendarId, externalEventId},
  ];
  @override
  CalendarEventLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEventLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memyEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memy_event_id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      externalCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_calendar_id'],
      )!,
      externalEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_event_id'],
      )!,
      lastSyncedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at_utc'],
      )!,
      lastKnownExternalUpdatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_known_external_updated_at_utc'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $CalendarEventLinksTable createAlias(String alias) {
    return $CalendarEventLinksTable(attachedDatabase, alias);
  }
}

class CalendarEventLink extends DataClass
    implements Insertable<CalendarEventLink> {
  final String id;
  final String memyEventId;
  final String provider;
  final String externalCalendarId;
  final String externalEventId;
  final DateTime lastSyncedAtUtc;
  final DateTime? lastKnownExternalUpdatedAtUtc;
  final DateTime createdAtUtc;
  const CalendarEventLink({
    required this.id,
    required this.memyEventId,
    required this.provider,
    required this.externalCalendarId,
    required this.externalEventId,
    required this.lastSyncedAtUtc,
    this.lastKnownExternalUpdatedAtUtc,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memy_event_id'] = Variable<String>(memyEventId);
    map['provider'] = Variable<String>(provider);
    map['external_calendar_id'] = Variable<String>(externalCalendarId);
    map['external_event_id'] = Variable<String>(externalEventId);
    map['last_synced_at_utc'] = Variable<DateTime>(lastSyncedAtUtc);
    if (!nullToAbsent || lastKnownExternalUpdatedAtUtc != null) {
      map['last_known_external_updated_at_utc'] = Variable<DateTime>(
        lastKnownExternalUpdatedAtUtc,
      );
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  CalendarEventLinksCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventLinksCompanion(
      id: Value(id),
      memyEventId: Value(memyEventId),
      provider: Value(provider),
      externalCalendarId: Value(externalCalendarId),
      externalEventId: Value(externalEventId),
      lastSyncedAtUtc: Value(lastSyncedAtUtc),
      lastKnownExternalUpdatedAtUtc:
          lastKnownExternalUpdatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownExternalUpdatedAtUtc),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory CalendarEventLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEventLink(
      id: serializer.fromJson<String>(json['id']),
      memyEventId: serializer.fromJson<String>(json['memyEventId']),
      provider: serializer.fromJson<String>(json['provider']),
      externalCalendarId: serializer.fromJson<String>(
        json['externalCalendarId'],
      ),
      externalEventId: serializer.fromJson<String>(json['externalEventId']),
      lastSyncedAtUtc: serializer.fromJson<DateTime>(json['lastSyncedAtUtc']),
      lastKnownExternalUpdatedAtUtc: serializer.fromJson<DateTime?>(
        json['lastKnownExternalUpdatedAtUtc'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memyEventId': serializer.toJson<String>(memyEventId),
      'provider': serializer.toJson<String>(provider),
      'externalCalendarId': serializer.toJson<String>(externalCalendarId),
      'externalEventId': serializer.toJson<String>(externalEventId),
      'lastSyncedAtUtc': serializer.toJson<DateTime>(lastSyncedAtUtc),
      'lastKnownExternalUpdatedAtUtc': serializer.toJson<DateTime?>(
        lastKnownExternalUpdatedAtUtc,
      ),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  CalendarEventLink copyWith({
    String? id,
    String? memyEventId,
    String? provider,
    String? externalCalendarId,
    String? externalEventId,
    DateTime? lastSyncedAtUtc,
    Value<DateTime?> lastKnownExternalUpdatedAtUtc = const Value.absent(),
    DateTime? createdAtUtc,
  }) => CalendarEventLink(
    id: id ?? this.id,
    memyEventId: memyEventId ?? this.memyEventId,
    provider: provider ?? this.provider,
    externalCalendarId: externalCalendarId ?? this.externalCalendarId,
    externalEventId: externalEventId ?? this.externalEventId,
    lastSyncedAtUtc: lastSyncedAtUtc ?? this.lastSyncedAtUtc,
    lastKnownExternalUpdatedAtUtc: lastKnownExternalUpdatedAtUtc.present
        ? lastKnownExternalUpdatedAtUtc.value
        : this.lastKnownExternalUpdatedAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  CalendarEventLink copyWithCompanion(CalendarEventLinksCompanion data) {
    return CalendarEventLink(
      id: data.id.present ? data.id.value : this.id,
      memyEventId: data.memyEventId.present
          ? data.memyEventId.value
          : this.memyEventId,
      provider: data.provider.present ? data.provider.value : this.provider,
      externalCalendarId: data.externalCalendarId.present
          ? data.externalCalendarId.value
          : this.externalCalendarId,
      externalEventId: data.externalEventId.present
          ? data.externalEventId.value
          : this.externalEventId,
      lastSyncedAtUtc: data.lastSyncedAtUtc.present
          ? data.lastSyncedAtUtc.value
          : this.lastSyncedAtUtc,
      lastKnownExternalUpdatedAtUtc: data.lastKnownExternalUpdatedAtUtc.present
          ? data.lastKnownExternalUpdatedAtUtc.value
          : this.lastKnownExternalUpdatedAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventLink(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('provider: $provider, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('lastSyncedAtUtc: $lastSyncedAtUtc, ')
          ..write(
            'lastKnownExternalUpdatedAtUtc: $lastKnownExternalUpdatedAtUtc, ',
          )
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memyEventId,
    provider,
    externalCalendarId,
    externalEventId,
    lastSyncedAtUtc,
    lastKnownExternalUpdatedAtUtc,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventLink &&
          other.id == this.id &&
          other.memyEventId == this.memyEventId &&
          other.provider == this.provider &&
          other.externalCalendarId == this.externalCalendarId &&
          other.externalEventId == this.externalEventId &&
          other.lastSyncedAtUtc == this.lastSyncedAtUtc &&
          other.lastKnownExternalUpdatedAtUtc ==
              this.lastKnownExternalUpdatedAtUtc &&
          other.createdAtUtc == this.createdAtUtc);
}

class CalendarEventLinksCompanion extends UpdateCompanion<CalendarEventLink> {
  final Value<String> id;
  final Value<String> memyEventId;
  final Value<String> provider;
  final Value<String> externalCalendarId;
  final Value<String> externalEventId;
  final Value<DateTime> lastSyncedAtUtc;
  final Value<DateTime?> lastKnownExternalUpdatedAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<int> rowid;
  const CalendarEventLinksCompanion({
    this.id = const Value.absent(),
    this.memyEventId = const Value.absent(),
    this.provider = const Value.absent(),
    this.externalCalendarId = const Value.absent(),
    this.externalEventId = const Value.absent(),
    this.lastSyncedAtUtc = const Value.absent(),
    this.lastKnownExternalUpdatedAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventLinksCompanion.insert({
    required String id,
    required String memyEventId,
    required String provider,
    required String externalCalendarId,
    required String externalEventId,
    required DateTime lastSyncedAtUtc,
    this.lastKnownExternalUpdatedAtUtc = const Value.absent(),
    required DateTime createdAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memyEventId = Value(memyEventId),
       provider = Value(provider),
       externalCalendarId = Value(externalCalendarId),
       externalEventId = Value(externalEventId),
       lastSyncedAtUtc = Value(lastSyncedAtUtc),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<CalendarEventLink> custom({
    Expression<String>? id,
    Expression<String>? memyEventId,
    Expression<String>? provider,
    Expression<String>? externalCalendarId,
    Expression<String>? externalEventId,
    Expression<DateTime>? lastSyncedAtUtc,
    Expression<DateTime>? lastKnownExternalUpdatedAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memyEventId != null) 'memy_event_id': memyEventId,
      if (provider != null) 'provider': provider,
      if (externalCalendarId != null)
        'external_calendar_id': externalCalendarId,
      if (externalEventId != null) 'external_event_id': externalEventId,
      if (lastSyncedAtUtc != null) 'last_synced_at_utc': lastSyncedAtUtc,
      if (lastKnownExternalUpdatedAtUtc != null)
        'last_known_external_updated_at_utc': lastKnownExternalUpdatedAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventLinksCompanion copyWith({
    Value<String>? id,
    Value<String>? memyEventId,
    Value<String>? provider,
    Value<String>? externalCalendarId,
    Value<String>? externalEventId,
    Value<DateTime>? lastSyncedAtUtc,
    Value<DateTime?>? lastKnownExternalUpdatedAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return CalendarEventLinksCompanion(
      id: id ?? this.id,
      memyEventId: memyEventId ?? this.memyEventId,
      provider: provider ?? this.provider,
      externalCalendarId: externalCalendarId ?? this.externalCalendarId,
      externalEventId: externalEventId ?? this.externalEventId,
      lastSyncedAtUtc: lastSyncedAtUtc ?? this.lastSyncedAtUtc,
      lastKnownExternalUpdatedAtUtc:
          lastKnownExternalUpdatedAtUtc ?? this.lastKnownExternalUpdatedAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memyEventId.present) {
      map['memy_event_id'] = Variable<String>(memyEventId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (externalCalendarId.present) {
      map['external_calendar_id'] = Variable<String>(externalCalendarId.value);
    }
    if (externalEventId.present) {
      map['external_event_id'] = Variable<String>(externalEventId.value);
    }
    if (lastSyncedAtUtc.present) {
      map['last_synced_at_utc'] = Variable<DateTime>(lastSyncedAtUtc.value);
    }
    if (lastKnownExternalUpdatedAtUtc.present) {
      map['last_known_external_updated_at_utc'] = Variable<DateTime>(
        lastKnownExternalUpdatedAtUtc.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventLinksCompanion(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('provider: $provider, ')
          ..write('externalCalendarId: $externalCalendarId, ')
          ..write('externalEventId: $externalEventId, ')
          ..write('lastSyncedAtUtc: $lastSyncedAtUtc, ')
          ..write(
            'lastKnownExternalUpdatedAtUtc: $lastKnownExternalUpdatedAtUtc, ',
          )
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarConflictsTable extends CalendarConflicts
    with TableInfo<$CalendarConflictsTable, CalendarConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memyEventIdMeta = const VerificationMeta(
    'memyEventId',
  );
  @override
  late final GeneratedColumn<String> memyEventId = GeneratedColumn<String>(
    'memy_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkIdMeta = const VerificationMeta('linkId');
  @override
  late final GeneratedColumn<String> linkId = GeneratedColumn<String>(
    'link_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localSnapshotJsonMeta = const VerificationMeta(
    'localSnapshotJson',
  );
  @override
  late final GeneratedColumn<String> localSnapshotJson =
      GeneratedColumn<String>(
        'local_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _externalSnapshotJsonMeta =
      const VerificationMeta('externalSnapshotJson');
  @override
  late final GeneratedColumn<String> externalSnapshotJson =
      GeneratedColumn<String>(
        'external_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAtUtc =
      GeneratedColumn<DateTime>(
        'detected_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _resolvedAtUtcMeta = const VerificationMeta(
    'resolvedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAtUtc =
      GeneratedColumn<DateTime>(
        'resolved_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memyEventId,
    linkId,
    localSnapshotJson,
    externalSnapshotJson,
    detectedAtUtc,
    resolvedAtUtc,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memy_event_id')) {
      context.handle(
        _memyEventIdMeta,
        memyEventId.isAcceptableOrUnknown(
          data['memy_event_id']!,
          _memyEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memyEventIdMeta);
    }
    if (data.containsKey('link_id')) {
      context.handle(
        _linkIdMeta,
        linkId.isAcceptableOrUnknown(data['link_id']!, _linkIdMeta),
      );
    }
    if (data.containsKey('local_snapshot_json')) {
      context.handle(
        _localSnapshotJsonMeta,
        localSnapshotJson.isAcceptableOrUnknown(
          data['local_snapshot_json']!,
          _localSnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localSnapshotJsonMeta);
    }
    if (data.containsKey('external_snapshot_json')) {
      context.handle(
        _externalSnapshotJsonMeta,
        externalSnapshotJson.isAcceptableOrUnknown(
          data['external_snapshot_json']!,
          _externalSnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalSnapshotJsonMeta);
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('resolved_at_utc')) {
      context.handle(
        _resolvedAtUtcMeta,
        resolvedAtUtc.isAcceptableOrUnknown(
          data['resolved_at_utc']!,
          _resolvedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memyEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memy_event_id'],
      )!,
      linkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_id'],
      ),
      localSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_snapshot_json'],
      )!,
      externalSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_snapshot_json'],
      )!,
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      resolvedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at_utc'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $CalendarConflictsTable createAlias(String alias) {
    return $CalendarConflictsTable(attachedDatabase, alias);
  }
}

class CalendarConflict extends DataClass
    implements Insertable<CalendarConflict> {
  final String id;
  final String memyEventId;
  final String? linkId;
  final String localSnapshotJson;
  final String externalSnapshotJson;
  final DateTime detectedAtUtc;
  final DateTime? resolvedAtUtc;
  final String? resolution;
  const CalendarConflict({
    required this.id,
    required this.memyEventId,
    this.linkId,
    required this.localSnapshotJson,
    required this.externalSnapshotJson,
    required this.detectedAtUtc,
    this.resolvedAtUtc,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memy_event_id'] = Variable<String>(memyEventId);
    if (!nullToAbsent || linkId != null) {
      map['link_id'] = Variable<String>(linkId);
    }
    map['local_snapshot_json'] = Variable<String>(localSnapshotJson);
    map['external_snapshot_json'] = Variable<String>(externalSnapshotJson);
    map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc);
    if (!nullToAbsent || resolvedAtUtc != null) {
      map['resolved_at_utc'] = Variable<DateTime>(resolvedAtUtc);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  CalendarConflictsCompanion toCompanion(bool nullToAbsent) {
    return CalendarConflictsCompanion(
      id: Value(id),
      memyEventId: Value(memyEventId),
      linkId: linkId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkId),
      localSnapshotJson: Value(localSnapshotJson),
      externalSnapshotJson: Value(externalSnapshotJson),
      detectedAtUtc: Value(detectedAtUtc),
      resolvedAtUtc: resolvedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAtUtc),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory CalendarConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarConflict(
      id: serializer.fromJson<String>(json['id']),
      memyEventId: serializer.fromJson<String>(json['memyEventId']),
      linkId: serializer.fromJson<String?>(json['linkId']),
      localSnapshotJson: serializer.fromJson<String>(json['localSnapshotJson']),
      externalSnapshotJson: serializer.fromJson<String>(
        json['externalSnapshotJson'],
      ),
      detectedAtUtc: serializer.fromJson<DateTime>(json['detectedAtUtc']),
      resolvedAtUtc: serializer.fromJson<DateTime?>(json['resolvedAtUtc']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memyEventId': serializer.toJson<String>(memyEventId),
      'linkId': serializer.toJson<String?>(linkId),
      'localSnapshotJson': serializer.toJson<String>(localSnapshotJson),
      'externalSnapshotJson': serializer.toJson<String>(externalSnapshotJson),
      'detectedAtUtc': serializer.toJson<DateTime>(detectedAtUtc),
      'resolvedAtUtc': serializer.toJson<DateTime?>(resolvedAtUtc),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  CalendarConflict copyWith({
    String? id,
    String? memyEventId,
    Value<String?> linkId = const Value.absent(),
    String? localSnapshotJson,
    String? externalSnapshotJson,
    DateTime? detectedAtUtc,
    Value<DateTime?> resolvedAtUtc = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => CalendarConflict(
    id: id ?? this.id,
    memyEventId: memyEventId ?? this.memyEventId,
    linkId: linkId.present ? linkId.value : this.linkId,
    localSnapshotJson: localSnapshotJson ?? this.localSnapshotJson,
    externalSnapshotJson: externalSnapshotJson ?? this.externalSnapshotJson,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    resolvedAtUtc: resolvedAtUtc.present
        ? resolvedAtUtc.value
        : this.resolvedAtUtc,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  CalendarConflict copyWithCompanion(CalendarConflictsCompanion data) {
    return CalendarConflict(
      id: data.id.present ? data.id.value : this.id,
      memyEventId: data.memyEventId.present
          ? data.memyEventId.value
          : this.memyEventId,
      linkId: data.linkId.present ? data.linkId.value : this.linkId,
      localSnapshotJson: data.localSnapshotJson.present
          ? data.localSnapshotJson.value
          : this.localSnapshotJson,
      externalSnapshotJson: data.externalSnapshotJson.present
          ? data.externalSnapshotJson.value
          : this.externalSnapshotJson,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      resolvedAtUtc: data.resolvedAtUtc.present
          ? data.resolvedAtUtc.value
          : this.resolvedAtUtc,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarConflict(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('linkId: $linkId, ')
          ..write('localSnapshotJson: $localSnapshotJson, ')
          ..write('externalSnapshotJson: $externalSnapshotJson, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('resolvedAtUtc: $resolvedAtUtc, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memyEventId,
    linkId,
    localSnapshotJson,
    externalSnapshotJson,
    detectedAtUtc,
    resolvedAtUtc,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarConflict &&
          other.id == this.id &&
          other.memyEventId == this.memyEventId &&
          other.linkId == this.linkId &&
          other.localSnapshotJson == this.localSnapshotJson &&
          other.externalSnapshotJson == this.externalSnapshotJson &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.resolvedAtUtc == this.resolvedAtUtc &&
          other.resolution == this.resolution);
}

class CalendarConflictsCompanion extends UpdateCompanion<CalendarConflict> {
  final Value<String> id;
  final Value<String> memyEventId;
  final Value<String?> linkId;
  final Value<String> localSnapshotJson;
  final Value<String> externalSnapshotJson;
  final Value<DateTime> detectedAtUtc;
  final Value<DateTime?> resolvedAtUtc;
  final Value<String?> resolution;
  final Value<int> rowid;
  const CalendarConflictsCompanion({
    this.id = const Value.absent(),
    this.memyEventId = const Value.absent(),
    this.linkId = const Value.absent(),
    this.localSnapshotJson = const Value.absent(),
    this.externalSnapshotJson = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.resolvedAtUtc = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarConflictsCompanion.insert({
    required String id,
    required String memyEventId,
    this.linkId = const Value.absent(),
    required String localSnapshotJson,
    required String externalSnapshotJson,
    required DateTime detectedAtUtc,
    this.resolvedAtUtc = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memyEventId = Value(memyEventId),
       localSnapshotJson = Value(localSnapshotJson),
       externalSnapshotJson = Value(externalSnapshotJson),
       detectedAtUtc = Value(detectedAtUtc);
  static Insertable<CalendarConflict> custom({
    Expression<String>? id,
    Expression<String>? memyEventId,
    Expression<String>? linkId,
    Expression<String>? localSnapshotJson,
    Expression<String>? externalSnapshotJson,
    Expression<DateTime>? detectedAtUtc,
    Expression<DateTime>? resolvedAtUtc,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memyEventId != null) 'memy_event_id': memyEventId,
      if (linkId != null) 'link_id': linkId,
      if (localSnapshotJson != null) 'local_snapshot_json': localSnapshotJson,
      if (externalSnapshotJson != null)
        'external_snapshot_json': externalSnapshotJson,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (resolvedAtUtc != null) 'resolved_at_utc': resolvedAtUtc,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? memyEventId,
    Value<String?>? linkId,
    Value<String>? localSnapshotJson,
    Value<String>? externalSnapshotJson,
    Value<DateTime>? detectedAtUtc,
    Value<DateTime?>? resolvedAtUtc,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return CalendarConflictsCompanion(
      id: id ?? this.id,
      memyEventId: memyEventId ?? this.memyEventId,
      linkId: linkId ?? this.linkId,
      localSnapshotJson: localSnapshotJson ?? this.localSnapshotJson,
      externalSnapshotJson: externalSnapshotJson ?? this.externalSnapshotJson,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      resolvedAtUtc: resolvedAtUtc ?? this.resolvedAtUtc,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memyEventId.present) {
      map['memy_event_id'] = Variable<String>(memyEventId.value);
    }
    if (linkId.present) {
      map['link_id'] = Variable<String>(linkId.value);
    }
    if (localSnapshotJson.present) {
      map['local_snapshot_json'] = Variable<String>(localSnapshotJson.value);
    }
    if (externalSnapshotJson.present) {
      map['external_snapshot_json'] = Variable<String>(
        externalSnapshotJson.value,
      );
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc.value);
    }
    if (resolvedAtUtc.present) {
      map['resolved_at_utc'] = Variable<DateTime>(resolvedAtUtc.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarConflictsCompanion(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('linkId: $linkId, ')
          ..write('localSnapshotJson: $localSnapshotJson, ')
          ..write('externalSnapshotJson: $externalSnapshotJson, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('resolvedAtUtc: $resolvedAtUtc, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarConfigRowsTable extends CalendarConfigRows
    with TableInfo<$CalendarConfigRowsTable, CalendarConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarConfigRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _selectedCalendarIdsJsonMeta =
      const VerificationMeta('selectedCalendarIdsJson');
  @override
  late final GeneratedColumn<String> selectedCalendarIdsJson =
      GeneratedColumn<String>(
        'selected_calendar_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _lastFullSyncAtUtcMeta = const VerificationMeta(
    'lastFullSyncAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastFullSyncAtUtc =
      GeneratedColumn<DateTime>(
        'last_full_sync_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _initialSyncAnchorPastUtcMeta =
      const VerificationMeta('initialSyncAnchorPastUtc');
  @override
  late final GeneratedColumn<DateTime> initialSyncAnchorPastUtc =
      GeneratedColumn<DateTime>(
        'initial_sync_anchor_past_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _initialSyncAnchorFutureUtcMeta =
      const VerificationMeta('initialSyncAnchorFutureUtc');
  @override
  late final GeneratedColumn<DateTime> initialSyncAnchorFutureUtc =
      GeneratedColumn<DateTime>(
        'initial_sync_anchor_future_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    selectedCalendarIdsJson,
    lastFullSyncAtUtc,
    initialSyncAnchorPastUtc,
    initialSyncAnchorFutureUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_config_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('selected_calendar_ids_json')) {
      context.handle(
        _selectedCalendarIdsJsonMeta,
        selectedCalendarIdsJson.isAcceptableOrUnknown(
          data['selected_calendar_ids_json']!,
          _selectedCalendarIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_full_sync_at_utc')) {
      context.handle(
        _lastFullSyncAtUtcMeta,
        lastFullSyncAtUtc.isAcceptableOrUnknown(
          data['last_full_sync_at_utc']!,
          _lastFullSyncAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('initial_sync_anchor_past_utc')) {
      context.handle(
        _initialSyncAnchorPastUtcMeta,
        initialSyncAnchorPastUtc.isAcceptableOrUnknown(
          data['initial_sync_anchor_past_utc']!,
          _initialSyncAnchorPastUtcMeta,
        ),
      );
    }
    if (data.containsKey('initial_sync_anchor_future_utc')) {
      context.handle(
        _initialSyncAnchorFutureUtcMeta,
        initialSyncAnchorFutureUtc.isAcceptableOrUnknown(
          data['initial_sync_anchor_future_utc']!,
          _initialSyncAnchorFutureUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      selectedCalendarIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_calendar_ids_json'],
      )!,
      lastFullSyncAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_full_sync_at_utc'],
      ),
      initialSyncAnchorPastUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}initial_sync_anchor_past_utc'],
      ),
      initialSyncAnchorFutureUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}initial_sync_anchor_future_utc'],
      ),
    );
  }

  @override
  $CalendarConfigRowsTable createAlias(String alias) {
    return $CalendarConfigRowsTable(attachedDatabase, alias);
  }
}

class CalendarConfigRow extends DataClass
    implements Insertable<CalendarConfigRow> {
  final int id;
  final String selectedCalendarIdsJson;
  final DateTime? lastFullSyncAtUtc;
  final DateTime? initialSyncAnchorPastUtc;
  final DateTime? initialSyncAnchorFutureUtc;
  const CalendarConfigRow({
    required this.id,
    required this.selectedCalendarIdsJson,
    this.lastFullSyncAtUtc,
    this.initialSyncAnchorPastUtc,
    this.initialSyncAnchorFutureUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['selected_calendar_ids_json'] = Variable<String>(
      selectedCalendarIdsJson,
    );
    if (!nullToAbsent || lastFullSyncAtUtc != null) {
      map['last_full_sync_at_utc'] = Variable<DateTime>(lastFullSyncAtUtc);
    }
    if (!nullToAbsent || initialSyncAnchorPastUtc != null) {
      map['initial_sync_anchor_past_utc'] = Variable<DateTime>(
        initialSyncAnchorPastUtc,
      );
    }
    if (!nullToAbsent || initialSyncAnchorFutureUtc != null) {
      map['initial_sync_anchor_future_utc'] = Variable<DateTime>(
        initialSyncAnchorFutureUtc,
      );
    }
    return map;
  }

  CalendarConfigRowsCompanion toCompanion(bool nullToAbsent) {
    return CalendarConfigRowsCompanion(
      id: Value(id),
      selectedCalendarIdsJson: Value(selectedCalendarIdsJson),
      lastFullSyncAtUtc: lastFullSyncAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFullSyncAtUtc),
      initialSyncAnchorPastUtc: initialSyncAnchorPastUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(initialSyncAnchorPastUtc),
      initialSyncAnchorFutureUtc:
          initialSyncAnchorFutureUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(initialSyncAnchorFutureUtc),
    );
  }

  factory CalendarConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarConfigRow(
      id: serializer.fromJson<int>(json['id']),
      selectedCalendarIdsJson: serializer.fromJson<String>(
        json['selectedCalendarIdsJson'],
      ),
      lastFullSyncAtUtc: serializer.fromJson<DateTime?>(
        json['lastFullSyncAtUtc'],
      ),
      initialSyncAnchorPastUtc: serializer.fromJson<DateTime?>(
        json['initialSyncAnchorPastUtc'],
      ),
      initialSyncAnchorFutureUtc: serializer.fromJson<DateTime?>(
        json['initialSyncAnchorFutureUtc'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selectedCalendarIdsJson': serializer.toJson<String>(
        selectedCalendarIdsJson,
      ),
      'lastFullSyncAtUtc': serializer.toJson<DateTime?>(lastFullSyncAtUtc),
      'initialSyncAnchorPastUtc': serializer.toJson<DateTime?>(
        initialSyncAnchorPastUtc,
      ),
      'initialSyncAnchorFutureUtc': serializer.toJson<DateTime?>(
        initialSyncAnchorFutureUtc,
      ),
    };
  }

  CalendarConfigRow copyWith({
    int? id,
    String? selectedCalendarIdsJson,
    Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
    Value<DateTime?> initialSyncAnchorPastUtc = const Value.absent(),
    Value<DateTime?> initialSyncAnchorFutureUtc = const Value.absent(),
  }) => CalendarConfigRow(
    id: id ?? this.id,
    selectedCalendarIdsJson:
        selectedCalendarIdsJson ?? this.selectedCalendarIdsJson,
    lastFullSyncAtUtc: lastFullSyncAtUtc.present
        ? lastFullSyncAtUtc.value
        : this.lastFullSyncAtUtc,
    initialSyncAnchorPastUtc: initialSyncAnchorPastUtc.present
        ? initialSyncAnchorPastUtc.value
        : this.initialSyncAnchorPastUtc,
    initialSyncAnchorFutureUtc: initialSyncAnchorFutureUtc.present
        ? initialSyncAnchorFutureUtc.value
        : this.initialSyncAnchorFutureUtc,
  );
  CalendarConfigRow copyWithCompanion(CalendarConfigRowsCompanion data) {
    return CalendarConfigRow(
      id: data.id.present ? data.id.value : this.id,
      selectedCalendarIdsJson: data.selectedCalendarIdsJson.present
          ? data.selectedCalendarIdsJson.value
          : this.selectedCalendarIdsJson,
      lastFullSyncAtUtc: data.lastFullSyncAtUtc.present
          ? data.lastFullSyncAtUtc.value
          : this.lastFullSyncAtUtc,
      initialSyncAnchorPastUtc: data.initialSyncAnchorPastUtc.present
          ? data.initialSyncAnchorPastUtc.value
          : this.initialSyncAnchorPastUtc,
      initialSyncAnchorFutureUtc: data.initialSyncAnchorFutureUtc.present
          ? data.initialSyncAnchorFutureUtc.value
          : this.initialSyncAnchorFutureUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarConfigRow(')
          ..write('id: $id, ')
          ..write('selectedCalendarIdsJson: $selectedCalendarIdsJson, ')
          ..write('lastFullSyncAtUtc: $lastFullSyncAtUtc, ')
          ..write('initialSyncAnchorPastUtc: $initialSyncAnchorPastUtc, ')
          ..write('initialSyncAnchorFutureUtc: $initialSyncAnchorFutureUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    selectedCalendarIdsJson,
    lastFullSyncAtUtc,
    initialSyncAnchorPastUtc,
    initialSyncAnchorFutureUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarConfigRow &&
          other.id == this.id &&
          other.selectedCalendarIdsJson == this.selectedCalendarIdsJson &&
          other.lastFullSyncAtUtc == this.lastFullSyncAtUtc &&
          other.initialSyncAnchorPastUtc == this.initialSyncAnchorPastUtc &&
          other.initialSyncAnchorFutureUtc == this.initialSyncAnchorFutureUtc);
}

class CalendarConfigRowsCompanion extends UpdateCompanion<CalendarConfigRow> {
  final Value<int> id;
  final Value<String> selectedCalendarIdsJson;
  final Value<DateTime?> lastFullSyncAtUtc;
  final Value<DateTime?> initialSyncAnchorPastUtc;
  final Value<DateTime?> initialSyncAnchorFutureUtc;
  const CalendarConfigRowsCompanion({
    this.id = const Value.absent(),
    this.selectedCalendarIdsJson = const Value.absent(),
    this.lastFullSyncAtUtc = const Value.absent(),
    this.initialSyncAnchorPastUtc = const Value.absent(),
    this.initialSyncAnchorFutureUtc = const Value.absent(),
  });
  CalendarConfigRowsCompanion.insert({
    this.id = const Value.absent(),
    this.selectedCalendarIdsJson = const Value.absent(),
    this.lastFullSyncAtUtc = const Value.absent(),
    this.initialSyncAnchorPastUtc = const Value.absent(),
    this.initialSyncAnchorFutureUtc = const Value.absent(),
  });
  static Insertable<CalendarConfigRow> custom({
    Expression<int>? id,
    Expression<String>? selectedCalendarIdsJson,
    Expression<DateTime>? lastFullSyncAtUtc,
    Expression<DateTime>? initialSyncAnchorPastUtc,
    Expression<DateTime>? initialSyncAnchorFutureUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selectedCalendarIdsJson != null)
        'selected_calendar_ids_json': selectedCalendarIdsJson,
      if (lastFullSyncAtUtc != null) 'last_full_sync_at_utc': lastFullSyncAtUtc,
      if (initialSyncAnchorPastUtc != null)
        'initial_sync_anchor_past_utc': initialSyncAnchorPastUtc,
      if (initialSyncAnchorFutureUtc != null)
        'initial_sync_anchor_future_utc': initialSyncAnchorFutureUtc,
    });
  }

  CalendarConfigRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? selectedCalendarIdsJson,
    Value<DateTime?>? lastFullSyncAtUtc,
    Value<DateTime?>? initialSyncAnchorPastUtc,
    Value<DateTime?>? initialSyncAnchorFutureUtc,
  }) {
    return CalendarConfigRowsCompanion(
      id: id ?? this.id,
      selectedCalendarIdsJson:
          selectedCalendarIdsJson ?? this.selectedCalendarIdsJson,
      lastFullSyncAtUtc: lastFullSyncAtUtc ?? this.lastFullSyncAtUtc,
      initialSyncAnchorPastUtc:
          initialSyncAnchorPastUtc ?? this.initialSyncAnchorPastUtc,
      initialSyncAnchorFutureUtc:
          initialSyncAnchorFutureUtc ?? this.initialSyncAnchorFutureUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (selectedCalendarIdsJson.present) {
      map['selected_calendar_ids_json'] = Variable<String>(
        selectedCalendarIdsJson.value,
      );
    }
    if (lastFullSyncAtUtc.present) {
      map['last_full_sync_at_utc'] = Variable<DateTime>(
        lastFullSyncAtUtc.value,
      );
    }
    if (initialSyncAnchorPastUtc.present) {
      map['initial_sync_anchor_past_utc'] = Variable<DateTime>(
        initialSyncAnchorPastUtc.value,
      );
    }
    if (initialSyncAnchorFutureUtc.present) {
      map['initial_sync_anchor_future_utc'] = Variable<DateTime>(
        initialSyncAnchorFutureUtc.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarConfigRowsCompanion(')
          ..write('id: $id, ')
          ..write('selectedCalendarIdsJson: $selectedCalendarIdsJson, ')
          ..write('lastFullSyncAtUtc: $lastFullSyncAtUtc, ')
          ..write('initialSyncAnchorPastUtc: $initialSyncAnchorPastUtc, ')
          ..write('initialSyncAnchorFutureUtc: $initialSyncAnchorFutureUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$CalendarDatabase extends GeneratedDatabase {
  _$CalendarDatabase(QueryExecutor e) : super(e);
  $CalendarDatabaseManager get managers => $CalendarDatabaseManager(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $CalendarEventLinksTable calendarEventLinks =
      $CalendarEventLinksTable(this);
  late final $CalendarConflictsTable calendarConflicts =
      $CalendarConflictsTable(this);
  late final $CalendarConfigRowsTable calendarConfigRows =
      $CalendarConfigRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    calendarEvents,
    calendarEventLinks,
    calendarConflicts,
    calendarConfigRows,
  ];
}

typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      required String id,
      required String title,
      Value<String?> notes,
      Value<String?> location,
      required DateTime startUtc,
      required DateTime endUtc,
      Value<bool> isAllDay,
      Value<String?> timezoneName,
      required String origin,
      required String syncStatus,
      Value<String?> externalProvider,
      Value<String?> externalCalendarId,
      Value<String?> externalEventId,
      Value<String> reminderMinutesJson,
      Value<int> version,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
      Value<int> rowid,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<String?> location,
      Value<DateTime> startUtc,
      Value<DateTime> endUtc,
      Value<bool> isAllDay,
      Value<String?> timezoneName,
      Value<String> origin,
      Value<String> syncStatus,
      Value<String?> externalProvider,
      Value<String?> externalCalendarId,
      Value<String?> externalEventId,
      Value<String> reminderMinutesJson,
      Value<int> version,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
      Value<int> rowid,
    });

class $$CalendarEventsTableFilterComposer
    extends Composer<_$CalendarDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endUtc => $composableBuilder(
    column: $table.endUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezoneName => $composableBuilder(
    column: $table.timezoneName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderMinutesJson => $composableBuilder(
    column: $table.reminderMinutesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$CalendarDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endUtc => $composableBuilder(
    column: $table.endUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezoneName => $composableBuilder(
    column: $table.timezoneName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderMinutesJson => $composableBuilder(
    column: $table.reminderMinutesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$CalendarDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get timezoneName => $composableBuilder(
    column: $table.timezoneName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderMinutesJson => $composableBuilder(
    column: $table.reminderMinutesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$CalendarDatabase,
          $CalendarEventsTable,
          CalendarEvent,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (
            CalendarEvent,
            BaseReferences<
              _$CalendarDatabase,
              $CalendarEventsTable,
              CalendarEvent
            >,
          ),
          CalendarEvent,
          PrefetchHooks Function()
        > {
  $$CalendarEventsTableTableManager(
    _$CalendarDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> startUtc = const Value.absent(),
                Value<DateTime> endUtc = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> timezoneName = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> externalProvider = const Value.absent(),
                Value<String?> externalCalendarId = const Value.absent(),
                Value<String?> externalEventId = const Value.absent(),
                Value<String> reminderMinutesJson = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion(
                id: id,
                title: title,
                notes: notes,
                location: location,
                startUtc: startUtc,
                endUtc: endUtc,
                isAllDay: isAllDay,
                timezoneName: timezoneName,
                origin: origin,
                syncStatus: syncStatus,
                externalProvider: externalProvider,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                reminderMinutesJson: reminderMinutesJson,
                version: version,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime startUtc,
                required DateTime endUtc,
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> timezoneName = const Value.absent(),
                required String origin,
                required String syncStatus,
                Value<String?> externalProvider = const Value.absent(),
                Value<String?> externalCalendarId = const Value.absent(),
                Value<String?> externalEventId = const Value.absent(),
                Value<String> reminderMinutesJson = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> deletedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                location: location,
                startUtc: startUtc,
                endUtc: endUtc,
                isAllDay: isAllDay,
                timezoneName: timezoneName,
                origin: origin,
                syncStatus: syncStatus,
                externalProvider: externalProvider,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                reminderMinutesJson: reminderMinutesJson,
                version: version,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalendarDatabase,
      $CalendarEventsTable,
      CalendarEvent,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (
        CalendarEvent,
        BaseReferences<_$CalendarDatabase, $CalendarEventsTable, CalendarEvent>,
      ),
      CalendarEvent,
      PrefetchHooks Function()
    >;
typedef $$CalendarEventLinksTableCreateCompanionBuilder =
    CalendarEventLinksCompanion Function({
      required String id,
      required String memyEventId,
      required String provider,
      required String externalCalendarId,
      required String externalEventId,
      required DateTime lastSyncedAtUtc,
      Value<DateTime?> lastKnownExternalUpdatedAtUtc,
      required DateTime createdAtUtc,
      Value<int> rowid,
    });
typedef $$CalendarEventLinksTableUpdateCompanionBuilder =
    CalendarEventLinksCompanion Function({
      Value<String> id,
      Value<String> memyEventId,
      Value<String> provider,
      Value<String> externalCalendarId,
      Value<String> externalEventId,
      Value<DateTime> lastSyncedAtUtc,
      Value<DateTime?> lastKnownExternalUpdatedAtUtc,
      Value<DateTime> createdAtUtc,
      Value<int> rowid,
    });

class $$CalendarEventLinksTableFilterComposer
    extends Composer<_$CalendarDatabase, $CalendarEventLinksTable> {
  $$CalendarEventLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAtUtc => $composableBuilder(
    column: $table.lastSyncedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastKnownExternalUpdatedAtUtc =>
      $composableBuilder(
        column: $table.lastKnownExternalUpdatedAtUtc,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventLinksTableOrderingComposer
    extends Composer<_$CalendarDatabase, $CalendarEventLinksTable> {
  $$CalendarEventLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAtUtc => $composableBuilder(
    column: $table.lastSyncedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastKnownExternalUpdatedAtUtc =>
      $composableBuilder(
        column: $table.lastKnownExternalUpdatedAtUtc,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventLinksTableAnnotationComposer
    extends Composer<_$CalendarDatabase, $CalendarEventLinksTable> {
  $$CalendarEventLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get externalCalendarId => $composableBuilder(
    column: $table.externalCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalEventId => $composableBuilder(
    column: $table.externalEventId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAtUtc => $composableBuilder(
    column: $table.lastSyncedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastKnownExternalUpdatedAtUtc =>
      $composableBuilder(
        column: $table.lastKnownExternalUpdatedAtUtc,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$CalendarEventLinksTableTableManager
    extends
        RootTableManager<
          _$CalendarDatabase,
          $CalendarEventLinksTable,
          CalendarEventLink,
          $$CalendarEventLinksTableFilterComposer,
          $$CalendarEventLinksTableOrderingComposer,
          $$CalendarEventLinksTableAnnotationComposer,
          $$CalendarEventLinksTableCreateCompanionBuilder,
          $$CalendarEventLinksTableUpdateCompanionBuilder,
          (
            CalendarEventLink,
            BaseReferences<
              _$CalendarDatabase,
              $CalendarEventLinksTable,
              CalendarEventLink
            >,
          ),
          CalendarEventLink,
          PrefetchHooks Function()
        > {
  $$CalendarEventLinksTableTableManager(
    _$CalendarDatabase db,
    $CalendarEventLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memyEventId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> externalCalendarId = const Value.absent(),
                Value<String> externalEventId = const Value.absent(),
                Value<DateTime> lastSyncedAtUtc = const Value.absent(),
                Value<DateTime?> lastKnownExternalUpdatedAtUtc =
                    const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventLinksCompanion(
                id: id,
                memyEventId: memyEventId,
                provider: provider,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                lastSyncedAtUtc: lastSyncedAtUtc,
                lastKnownExternalUpdatedAtUtc: lastKnownExternalUpdatedAtUtc,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memyEventId,
                required String provider,
                required String externalCalendarId,
                required String externalEventId,
                required DateTime lastSyncedAtUtc,
                Value<DateTime?> lastKnownExternalUpdatedAtUtc =
                    const Value.absent(),
                required DateTime createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventLinksCompanion.insert(
                id: id,
                memyEventId: memyEventId,
                provider: provider,
                externalCalendarId: externalCalendarId,
                externalEventId: externalEventId,
                lastSyncedAtUtc: lastSyncedAtUtc,
                lastKnownExternalUpdatedAtUtc: lastKnownExternalUpdatedAtUtc,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$CalendarDatabase,
      $CalendarEventLinksTable,
      CalendarEventLink,
      $$CalendarEventLinksTableFilterComposer,
      $$CalendarEventLinksTableOrderingComposer,
      $$CalendarEventLinksTableAnnotationComposer,
      $$CalendarEventLinksTableCreateCompanionBuilder,
      $$CalendarEventLinksTableUpdateCompanionBuilder,
      (
        CalendarEventLink,
        BaseReferences<
          _$CalendarDatabase,
          $CalendarEventLinksTable,
          CalendarEventLink
        >,
      ),
      CalendarEventLink,
      PrefetchHooks Function()
    >;
typedef $$CalendarConflictsTableCreateCompanionBuilder =
    CalendarConflictsCompanion Function({
      required String id,
      required String memyEventId,
      Value<String?> linkId,
      required String localSnapshotJson,
      required String externalSnapshotJson,
      required DateTime detectedAtUtc,
      Value<DateTime?> resolvedAtUtc,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$CalendarConflictsTableUpdateCompanionBuilder =
    CalendarConflictsCompanion Function({
      Value<String> id,
      Value<String> memyEventId,
      Value<String?> linkId,
      Value<String> localSnapshotJson,
      Value<String> externalSnapshotJson,
      Value<DateTime> detectedAtUtc,
      Value<DateTime?> resolvedAtUtc,
      Value<String?> resolution,
      Value<int> rowid,
    });

class $$CalendarConflictsTableFilterComposer
    extends Composer<_$CalendarDatabase, $CalendarConflictsTable> {
  $$CalendarConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkId => $composableBuilder(
    column: $table.linkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalSnapshotJson => $composableBuilder(
    column: $table.externalSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAtUtc => $composableBuilder(
    column: $table.resolvedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarConflictsTableOrderingComposer
    extends Composer<_$CalendarDatabase, $CalendarConflictsTable> {
  $$CalendarConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkId => $composableBuilder(
    column: $table.linkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalSnapshotJson => $composableBuilder(
    column: $table.externalSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAtUtc => $composableBuilder(
    column: $table.resolvedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarConflictsTableAnnotationComposer
    extends Composer<_$CalendarDatabase, $CalendarConflictsTable> {
  $$CalendarConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memyEventId => $composableBuilder(
    column: $table.memyEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkId =>
      $composableBuilder(column: $table.linkId, builder: (column) => column);

  GeneratedColumn<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalSnapshotJson => $composableBuilder(
    column: $table.externalSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAtUtc => $composableBuilder(
    column: $table.resolvedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$CalendarConflictsTableTableManager
    extends
        RootTableManager<
          _$CalendarDatabase,
          $CalendarConflictsTable,
          CalendarConflict,
          $$CalendarConflictsTableFilterComposer,
          $$CalendarConflictsTableOrderingComposer,
          $$CalendarConflictsTableAnnotationComposer,
          $$CalendarConflictsTableCreateCompanionBuilder,
          $$CalendarConflictsTableUpdateCompanionBuilder,
          (
            CalendarConflict,
            BaseReferences<
              _$CalendarDatabase,
              $CalendarConflictsTable,
              CalendarConflict
            >,
          ),
          CalendarConflict,
          PrefetchHooks Function()
        > {
  $$CalendarConflictsTableTableManager(
    _$CalendarDatabase db,
    $CalendarConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarConflictsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memyEventId = const Value.absent(),
                Value<String?> linkId = const Value.absent(),
                Value<String> localSnapshotJson = const Value.absent(),
                Value<String> externalSnapshotJson = const Value.absent(),
                Value<DateTime> detectedAtUtc = const Value.absent(),
                Value<DateTime?> resolvedAtUtc = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarConflictsCompanion(
                id: id,
                memyEventId: memyEventId,
                linkId: linkId,
                localSnapshotJson: localSnapshotJson,
                externalSnapshotJson: externalSnapshotJson,
                detectedAtUtc: detectedAtUtc,
                resolvedAtUtc: resolvedAtUtc,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memyEventId,
                Value<String?> linkId = const Value.absent(),
                required String localSnapshotJson,
                required String externalSnapshotJson,
                required DateTime detectedAtUtc,
                Value<DateTime?> resolvedAtUtc = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarConflictsCompanion.insert(
                id: id,
                memyEventId: memyEventId,
                linkId: linkId,
                localSnapshotJson: localSnapshotJson,
                externalSnapshotJson: externalSnapshotJson,
                detectedAtUtc: detectedAtUtc,
                resolvedAtUtc: resolvedAtUtc,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalendarDatabase,
      $CalendarConflictsTable,
      CalendarConflict,
      $$CalendarConflictsTableFilterComposer,
      $$CalendarConflictsTableOrderingComposer,
      $$CalendarConflictsTableAnnotationComposer,
      $$CalendarConflictsTableCreateCompanionBuilder,
      $$CalendarConflictsTableUpdateCompanionBuilder,
      (
        CalendarConflict,
        BaseReferences<
          _$CalendarDatabase,
          $CalendarConflictsTable,
          CalendarConflict
        >,
      ),
      CalendarConflict,
      PrefetchHooks Function()
    >;
typedef $$CalendarConfigRowsTableCreateCompanionBuilder =
    CalendarConfigRowsCompanion Function({
      Value<int> id,
      Value<String> selectedCalendarIdsJson,
      Value<DateTime?> lastFullSyncAtUtc,
      Value<DateTime?> initialSyncAnchorPastUtc,
      Value<DateTime?> initialSyncAnchorFutureUtc,
    });
typedef $$CalendarConfigRowsTableUpdateCompanionBuilder =
    CalendarConfigRowsCompanion Function({
      Value<int> id,
      Value<String> selectedCalendarIdsJson,
      Value<DateTime?> lastFullSyncAtUtc,
      Value<DateTime?> initialSyncAnchorPastUtc,
      Value<DateTime?> initialSyncAnchorFutureUtc,
    });

class $$CalendarConfigRowsTableFilterComposer
    extends Composer<_$CalendarDatabase, $CalendarConfigRowsTable> {
  $$CalendarConfigRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedCalendarIdsJson => $composableBuilder(
    column: $table.selectedCalendarIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get initialSyncAnchorPastUtc => $composableBuilder(
    column: $table.initialSyncAnchorPastUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get initialSyncAnchorFutureUtc => $composableBuilder(
    column: $table.initialSyncAnchorFutureUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarConfigRowsTableOrderingComposer
    extends Composer<_$CalendarDatabase, $CalendarConfigRowsTable> {
  $$CalendarConfigRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedCalendarIdsJson => $composableBuilder(
    column: $table.selectedCalendarIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get initialSyncAnchorPastUtc => $composableBuilder(
    column: $table.initialSyncAnchorPastUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get initialSyncAnchorFutureUtc =>
      $composableBuilder(
        column: $table.initialSyncAnchorFutureUtc,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$CalendarConfigRowsTableAnnotationComposer
    extends Composer<_$CalendarDatabase, $CalendarConfigRowsTable> {
  $$CalendarConfigRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedCalendarIdsJson => $composableBuilder(
    column: $table.selectedCalendarIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get initialSyncAnchorPastUtc => $composableBuilder(
    column: $table.initialSyncAnchorPastUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get initialSyncAnchorFutureUtc =>
      $composableBuilder(
        column: $table.initialSyncAnchorFutureUtc,
        builder: (column) => column,
      );
}

class $$CalendarConfigRowsTableTableManager
    extends
        RootTableManager<
          _$CalendarDatabase,
          $CalendarConfigRowsTable,
          CalendarConfigRow,
          $$CalendarConfigRowsTableFilterComposer,
          $$CalendarConfigRowsTableOrderingComposer,
          $$CalendarConfigRowsTableAnnotationComposer,
          $$CalendarConfigRowsTableCreateCompanionBuilder,
          $$CalendarConfigRowsTableUpdateCompanionBuilder,
          (
            CalendarConfigRow,
            BaseReferences<
              _$CalendarDatabase,
              $CalendarConfigRowsTable,
              CalendarConfigRow
            >,
          ),
          CalendarConfigRow,
          PrefetchHooks Function()
        > {
  $$CalendarConfigRowsTableTableManager(
    _$CalendarDatabase db,
    $CalendarConfigRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarConfigRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarConfigRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarConfigRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> selectedCalendarIdsJson = const Value.absent(),
                Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
                Value<DateTime?> initialSyncAnchorPastUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorFutureUtc =
                    const Value.absent(),
              }) => CalendarConfigRowsCompanion(
                id: id,
                selectedCalendarIdsJson: selectedCalendarIdsJson,
                lastFullSyncAtUtc: lastFullSyncAtUtc,
                initialSyncAnchorPastUtc: initialSyncAnchorPastUtc,
                initialSyncAnchorFutureUtc: initialSyncAnchorFutureUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> selectedCalendarIdsJson = const Value.absent(),
                Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
                Value<DateTime?> initialSyncAnchorPastUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorFutureUtc =
                    const Value.absent(),
              }) => CalendarConfigRowsCompanion.insert(
                id: id,
                selectedCalendarIdsJson: selectedCalendarIdsJson,
                lastFullSyncAtUtc: lastFullSyncAtUtc,
                initialSyncAnchorPastUtc: initialSyncAnchorPastUtc,
                initialSyncAnchorFutureUtc: initialSyncAnchorFutureUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarConfigRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalendarDatabase,
      $CalendarConfigRowsTable,
      CalendarConfigRow,
      $$CalendarConfigRowsTableFilterComposer,
      $$CalendarConfigRowsTableOrderingComposer,
      $$CalendarConfigRowsTableAnnotationComposer,
      $$CalendarConfigRowsTableCreateCompanionBuilder,
      $$CalendarConfigRowsTableUpdateCompanionBuilder,
      (
        CalendarConfigRow,
        BaseReferences<
          _$CalendarDatabase,
          $CalendarConfigRowsTable,
          CalendarConfigRow
        >,
      ),
      CalendarConfigRow,
      PrefetchHooks Function()
    >;

class $CalendarDatabaseManager {
  final _$CalendarDatabase _db;
  $CalendarDatabaseManager(this._db);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$CalendarEventLinksTableTableManager get calendarEventLinks =>
      $$CalendarEventLinksTableTableManager(_db, _db.calendarEventLinks);
  $$CalendarConflictsTableTableManager get calendarConflicts =>
      $$CalendarConflictsTableTableManager(_db, _db.calendarConflicts);
  $$CalendarConfigRowsTableTableManager get calendarConfigRows =>
      $$CalendarConfigRowsTableTableManager(_db, _db.calendarConfigRows);
}
