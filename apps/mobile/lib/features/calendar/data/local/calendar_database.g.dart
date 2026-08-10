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
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringInstanceMeta =
      const VerificationMeta('isRecurringInstance');
  @override
  late final GeneratedColumn<bool> isRecurringInstance = GeneratedColumn<bool>(
    'is_recurring_instance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring_instance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seriesExternalEventIdMeta =
      const VerificationMeta('seriesExternalEventId');
  @override
  late final GeneratedColumn<String> seriesExternalEventId =
      GeneratedColumn<String>(
        'series_external_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    recurrenceRule,
    isRecurringInstance,
    seriesExternalEventId,
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
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring_instance')) {
      context.handle(
        _isRecurringInstanceMeta,
        isRecurringInstance.isAcceptableOrUnknown(
          data['is_recurring_instance']!,
          _isRecurringInstanceMeta,
        ),
      );
    }
    if (data.containsKey('series_external_event_id')) {
      context.handle(
        _seriesExternalEventIdMeta,
        seriesExternalEventId.isAcceptableOrUnknown(
          data['series_external_event_id']!,
          _seriesExternalEventIdMeta,
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
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      isRecurringInstance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring_instance'],
      )!,
      seriesExternalEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_external_event_id'],
      ),
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
  final String? recurrenceRule;
  final bool isRecurringInstance;
  final String? seriesExternalEventId;
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
    this.recurrenceRule,
    required this.isRecurringInstance,
    this.seriesExternalEventId,
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
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['is_recurring_instance'] = Variable<bool>(isRecurringInstance);
    if (!nullToAbsent || seriesExternalEventId != null) {
      map['series_external_event_id'] = Variable<String>(seriesExternalEventId);
    }
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
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      isRecurringInstance: Value(isRecurringInstance),
      seriesExternalEventId: seriesExternalEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesExternalEventId),
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
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      isRecurringInstance: serializer.fromJson<bool>(
        json['isRecurringInstance'],
      ),
      seriesExternalEventId: serializer.fromJson<String?>(
        json['seriesExternalEventId'],
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
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'isRecurringInstance': serializer.toJson<bool>(isRecurringInstance),
      'seriesExternalEventId': serializer.toJson<String?>(
        seriesExternalEventId,
      ),
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
    Value<String?> recurrenceRule = const Value.absent(),
    bool? isRecurringInstance,
    Value<String?> seriesExternalEventId = const Value.absent(),
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
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    isRecurringInstance: isRecurringInstance ?? this.isRecurringInstance,
    seriesExternalEventId: seriesExternalEventId.present
        ? seriesExternalEventId.value
        : this.seriesExternalEventId,
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
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      isRecurringInstance: data.isRecurringInstance.present
          ? data.isRecurringInstance.value
          : this.isRecurringInstance,
      seriesExternalEventId: data.seriesExternalEventId.present
          ? data.seriesExternalEventId.value
          : this.seriesExternalEventId,
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
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isRecurringInstance: $isRecurringInstance, ')
          ..write('seriesExternalEventId: $seriesExternalEventId, ')
          ..write('version: $version, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    recurrenceRule,
    isRecurringInstance,
    seriesExternalEventId,
    version,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  ]);
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
          other.recurrenceRule == this.recurrenceRule &&
          other.isRecurringInstance == this.isRecurringInstance &&
          other.seriesExternalEventId == this.seriesExternalEventId &&
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
  final Value<String?> recurrenceRule;
  final Value<bool> isRecurringInstance;
  final Value<String?> seriesExternalEventId;
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
    this.recurrenceRule = const Value.absent(),
    this.isRecurringInstance = const Value.absent(),
    this.seriesExternalEventId = const Value.absent(),
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
    this.recurrenceRule = const Value.absent(),
    this.isRecurringInstance = const Value.absent(),
    this.seriesExternalEventId = const Value.absent(),
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
    Expression<String>? recurrenceRule,
    Expression<bool>? isRecurringInstance,
    Expression<String>? seriesExternalEventId,
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
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (isRecurringInstance != null)
        'is_recurring_instance': isRecurringInstance,
      if (seriesExternalEventId != null)
        'series_external_event_id': seriesExternalEventId,
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
    Value<String?>? recurrenceRule,
    Value<bool>? isRecurringInstance,
    Value<String?>? seriesExternalEventId,
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
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isRecurringInstance: isRecurringInstance ?? this.isRecurringInstance,
      seriesExternalEventId:
          seriesExternalEventId ?? this.seriesExternalEventId,
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
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (isRecurringInstance.present) {
      map['is_recurring_instance'] = Variable<bool>(isRecurringInstance.value);
    }
    if (seriesExternalEventId.present) {
      map['series_external_event_id'] = Variable<String>(
        seriesExternalEventId.value,
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
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isRecurringInstance: $isRecurringInstance, ')
          ..write('seriesExternalEventId: $seriesExternalEventId, ')
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
  static const VerificationMeta _presenceStatusMeta = const VerificationMeta(
    'presenceStatus',
  );
  @override
  late final GeneratedColumn<String> presenceStatus = GeneratedColumn<String>(
    'presence_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('present'),
  );
  static const VerificationMeta _lastSeenExternallyAtUtcMeta =
      const VerificationMeta('lastSeenExternallyAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastSeenExternallyAtUtc =
      GeneratedColumn<DateTime>(
        'last_seen_externally_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _firstMissingObservationAtUtcMeta =
      const VerificationMeta('firstMissingObservationAtUtc');
  @override
  late final GeneratedColumn<DateTime> firstMissingObservationAtUtc =
      GeneratedColumn<DateTime>(
        'first_missing_observation_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMissingObservationAtUtcMeta =
      const VerificationMeta('lastMissingObservationAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastMissingObservationAtUtc =
      GeneratedColumn<DateTime>(
        'last_missing_observation_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _missingObservationCountMeta =
      const VerificationMeta('missingObservationCount');
  @override
  late final GeneratedColumn<int> missingObservationCount =
      GeneratedColumn<int>(
        'missing_observation_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastCompleteQueryStartUtcMeta =
      const VerificationMeta('lastCompleteQueryStartUtc');
  @override
  late final GeneratedColumn<DateTime> lastCompleteQueryStartUtc =
      GeneratedColumn<DateTime>(
        'last_complete_query_start_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastCompleteQueryEndUtcMeta =
      const VerificationMeta('lastCompleteQueryEndUtc');
  @override
  late final GeneratedColumn<DateTime> lastCompleteQueryEndUtc =
      GeneratedColumn<DateTime>(
        'last_complete_query_end_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hiddenLocallyMeta = const VerificationMeta(
    'hiddenLocally',
  );
  @override
  late final GeneratedColumn<bool> hiddenLocally = GeneratedColumn<bool>(
    'hidden_locally',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden_locally" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memyMarkerMeta = const VerificationMeta(
    'memyMarker',
  );
  @override
  late final GeneratedColumn<String> memyMarker = GeneratedColumn<String>(
    'memy_marker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    presenceStatus,
    lastSeenExternallyAtUtc,
    firstMissingObservationAtUtc,
    lastMissingObservationAtUtc,
    missingObservationCount,
    lastCompleteQueryStartUtc,
    lastCompleteQueryEndUtc,
    hiddenLocally,
    memyMarker,
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
    if (data.containsKey('presence_status')) {
      context.handle(
        _presenceStatusMeta,
        presenceStatus.isAcceptableOrUnknown(
          data['presence_status']!,
          _presenceStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_externally_at_utc')) {
      context.handle(
        _lastSeenExternallyAtUtcMeta,
        lastSeenExternallyAtUtc.isAcceptableOrUnknown(
          data['last_seen_externally_at_utc']!,
          _lastSeenExternallyAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('first_missing_observation_at_utc')) {
      context.handle(
        _firstMissingObservationAtUtcMeta,
        firstMissingObservationAtUtc.isAcceptableOrUnknown(
          data['first_missing_observation_at_utc']!,
          _firstMissingObservationAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_missing_observation_at_utc')) {
      context.handle(
        _lastMissingObservationAtUtcMeta,
        lastMissingObservationAtUtc.isAcceptableOrUnknown(
          data['last_missing_observation_at_utc']!,
          _lastMissingObservationAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('missing_observation_count')) {
      context.handle(
        _missingObservationCountMeta,
        missingObservationCount.isAcceptableOrUnknown(
          data['missing_observation_count']!,
          _missingObservationCountMeta,
        ),
      );
    }
    if (data.containsKey('last_complete_query_start_utc')) {
      context.handle(
        _lastCompleteQueryStartUtcMeta,
        lastCompleteQueryStartUtc.isAcceptableOrUnknown(
          data['last_complete_query_start_utc']!,
          _lastCompleteQueryStartUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_complete_query_end_utc')) {
      context.handle(
        _lastCompleteQueryEndUtcMeta,
        lastCompleteQueryEndUtc.isAcceptableOrUnknown(
          data['last_complete_query_end_utc']!,
          _lastCompleteQueryEndUtcMeta,
        ),
      );
    }
    if (data.containsKey('hidden_locally')) {
      context.handle(
        _hiddenLocallyMeta,
        hiddenLocally.isAcceptableOrUnknown(
          data['hidden_locally']!,
          _hiddenLocallyMeta,
        ),
      );
    }
    if (data.containsKey('memy_marker')) {
      context.handle(
        _memyMarkerMeta,
        memyMarker.isAcceptableOrUnknown(data['memy_marker']!, _memyMarkerMeta),
      );
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
      presenceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_status'],
      )!,
      lastSeenExternallyAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_externally_at_utc'],
      ),
      firstMissingObservationAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_missing_observation_at_utc'],
      ),
      lastMissingObservationAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_missing_observation_at_utc'],
      ),
      missingObservationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}missing_observation_count'],
      )!,
      lastCompleteQueryStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_complete_query_start_utc'],
      ),
      lastCompleteQueryEndUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_complete_query_end_utc'],
      ),
      hiddenLocally: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden_locally'],
      )!,
      memyMarker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memy_marker'],
      ),
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
  final String presenceStatus;
  final DateTime? lastSeenExternallyAtUtc;
  final DateTime? firstMissingObservationAtUtc;
  final DateTime? lastMissingObservationAtUtc;
  final int missingObservationCount;
  final DateTime? lastCompleteQueryStartUtc;
  final DateTime? lastCompleteQueryEndUtc;
  final bool hiddenLocally;
  final String? memyMarker;
  const CalendarEventLink({
    required this.id,
    required this.memyEventId,
    required this.provider,
    required this.externalCalendarId,
    required this.externalEventId,
    required this.lastSyncedAtUtc,
    this.lastKnownExternalUpdatedAtUtc,
    required this.createdAtUtc,
    required this.presenceStatus,
    this.lastSeenExternallyAtUtc,
    this.firstMissingObservationAtUtc,
    this.lastMissingObservationAtUtc,
    required this.missingObservationCount,
    this.lastCompleteQueryStartUtc,
    this.lastCompleteQueryEndUtc,
    required this.hiddenLocally,
    this.memyMarker,
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
    map['presence_status'] = Variable<String>(presenceStatus);
    if (!nullToAbsent || lastSeenExternallyAtUtc != null) {
      map['last_seen_externally_at_utc'] = Variable<DateTime>(
        lastSeenExternallyAtUtc,
      );
    }
    if (!nullToAbsent || firstMissingObservationAtUtc != null) {
      map['first_missing_observation_at_utc'] = Variable<DateTime>(
        firstMissingObservationAtUtc,
      );
    }
    if (!nullToAbsent || lastMissingObservationAtUtc != null) {
      map['last_missing_observation_at_utc'] = Variable<DateTime>(
        lastMissingObservationAtUtc,
      );
    }
    map['missing_observation_count'] = Variable<int>(missingObservationCount);
    if (!nullToAbsent || lastCompleteQueryStartUtc != null) {
      map['last_complete_query_start_utc'] = Variable<DateTime>(
        lastCompleteQueryStartUtc,
      );
    }
    if (!nullToAbsent || lastCompleteQueryEndUtc != null) {
      map['last_complete_query_end_utc'] = Variable<DateTime>(
        lastCompleteQueryEndUtc,
      );
    }
    map['hidden_locally'] = Variable<bool>(hiddenLocally);
    if (!nullToAbsent || memyMarker != null) {
      map['memy_marker'] = Variable<String>(memyMarker);
    }
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
      presenceStatus: Value(presenceStatus),
      lastSeenExternallyAtUtc: lastSeenExternallyAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenExternallyAtUtc),
      firstMissingObservationAtUtc:
          firstMissingObservationAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(firstMissingObservationAtUtc),
      lastMissingObservationAtUtc:
          lastMissingObservationAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMissingObservationAtUtc),
      missingObservationCount: Value(missingObservationCount),
      lastCompleteQueryStartUtc:
          lastCompleteQueryStartUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompleteQueryStartUtc),
      lastCompleteQueryEndUtc: lastCompleteQueryEndUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompleteQueryEndUtc),
      hiddenLocally: Value(hiddenLocally),
      memyMarker: memyMarker == null && nullToAbsent
          ? const Value.absent()
          : Value(memyMarker),
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
      presenceStatus: serializer.fromJson<String>(json['presenceStatus']),
      lastSeenExternallyAtUtc: serializer.fromJson<DateTime?>(
        json['lastSeenExternallyAtUtc'],
      ),
      firstMissingObservationAtUtc: serializer.fromJson<DateTime?>(
        json['firstMissingObservationAtUtc'],
      ),
      lastMissingObservationAtUtc: serializer.fromJson<DateTime?>(
        json['lastMissingObservationAtUtc'],
      ),
      missingObservationCount: serializer.fromJson<int>(
        json['missingObservationCount'],
      ),
      lastCompleteQueryStartUtc: serializer.fromJson<DateTime?>(
        json['lastCompleteQueryStartUtc'],
      ),
      lastCompleteQueryEndUtc: serializer.fromJson<DateTime?>(
        json['lastCompleteQueryEndUtc'],
      ),
      hiddenLocally: serializer.fromJson<bool>(json['hiddenLocally']),
      memyMarker: serializer.fromJson<String?>(json['memyMarker']),
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
      'presenceStatus': serializer.toJson<String>(presenceStatus),
      'lastSeenExternallyAtUtc': serializer.toJson<DateTime?>(
        lastSeenExternallyAtUtc,
      ),
      'firstMissingObservationAtUtc': serializer.toJson<DateTime?>(
        firstMissingObservationAtUtc,
      ),
      'lastMissingObservationAtUtc': serializer.toJson<DateTime?>(
        lastMissingObservationAtUtc,
      ),
      'missingObservationCount': serializer.toJson<int>(
        missingObservationCount,
      ),
      'lastCompleteQueryStartUtc': serializer.toJson<DateTime?>(
        lastCompleteQueryStartUtc,
      ),
      'lastCompleteQueryEndUtc': serializer.toJson<DateTime?>(
        lastCompleteQueryEndUtc,
      ),
      'hiddenLocally': serializer.toJson<bool>(hiddenLocally),
      'memyMarker': serializer.toJson<String?>(memyMarker),
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
    String? presenceStatus,
    Value<DateTime?> lastSeenExternallyAtUtc = const Value.absent(),
    Value<DateTime?> firstMissingObservationAtUtc = const Value.absent(),
    Value<DateTime?> lastMissingObservationAtUtc = const Value.absent(),
    int? missingObservationCount,
    Value<DateTime?> lastCompleteQueryStartUtc = const Value.absent(),
    Value<DateTime?> lastCompleteQueryEndUtc = const Value.absent(),
    bool? hiddenLocally,
    Value<String?> memyMarker = const Value.absent(),
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
    presenceStatus: presenceStatus ?? this.presenceStatus,
    lastSeenExternallyAtUtc: lastSeenExternallyAtUtc.present
        ? lastSeenExternallyAtUtc.value
        : this.lastSeenExternallyAtUtc,
    firstMissingObservationAtUtc: firstMissingObservationAtUtc.present
        ? firstMissingObservationAtUtc.value
        : this.firstMissingObservationAtUtc,
    lastMissingObservationAtUtc: lastMissingObservationAtUtc.present
        ? lastMissingObservationAtUtc.value
        : this.lastMissingObservationAtUtc,
    missingObservationCount:
        missingObservationCount ?? this.missingObservationCount,
    lastCompleteQueryStartUtc: lastCompleteQueryStartUtc.present
        ? lastCompleteQueryStartUtc.value
        : this.lastCompleteQueryStartUtc,
    lastCompleteQueryEndUtc: lastCompleteQueryEndUtc.present
        ? lastCompleteQueryEndUtc.value
        : this.lastCompleteQueryEndUtc,
    hiddenLocally: hiddenLocally ?? this.hiddenLocally,
    memyMarker: memyMarker.present ? memyMarker.value : this.memyMarker,
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
      presenceStatus: data.presenceStatus.present
          ? data.presenceStatus.value
          : this.presenceStatus,
      lastSeenExternallyAtUtc: data.lastSeenExternallyAtUtc.present
          ? data.lastSeenExternallyAtUtc.value
          : this.lastSeenExternallyAtUtc,
      firstMissingObservationAtUtc: data.firstMissingObservationAtUtc.present
          ? data.firstMissingObservationAtUtc.value
          : this.firstMissingObservationAtUtc,
      lastMissingObservationAtUtc: data.lastMissingObservationAtUtc.present
          ? data.lastMissingObservationAtUtc.value
          : this.lastMissingObservationAtUtc,
      missingObservationCount: data.missingObservationCount.present
          ? data.missingObservationCount.value
          : this.missingObservationCount,
      lastCompleteQueryStartUtc: data.lastCompleteQueryStartUtc.present
          ? data.lastCompleteQueryStartUtc.value
          : this.lastCompleteQueryStartUtc,
      lastCompleteQueryEndUtc: data.lastCompleteQueryEndUtc.present
          ? data.lastCompleteQueryEndUtc.value
          : this.lastCompleteQueryEndUtc,
      hiddenLocally: data.hiddenLocally.present
          ? data.hiddenLocally.value
          : this.hiddenLocally,
      memyMarker: data.memyMarker.present
          ? data.memyMarker.value
          : this.memyMarker,
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
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('lastSeenExternallyAtUtc: $lastSeenExternallyAtUtc, ')
          ..write(
            'firstMissingObservationAtUtc: $firstMissingObservationAtUtc, ',
          )
          ..write('lastMissingObservationAtUtc: $lastMissingObservationAtUtc, ')
          ..write('missingObservationCount: $missingObservationCount, ')
          ..write('lastCompleteQueryStartUtc: $lastCompleteQueryStartUtc, ')
          ..write('lastCompleteQueryEndUtc: $lastCompleteQueryEndUtc, ')
          ..write('hiddenLocally: $hiddenLocally, ')
          ..write('memyMarker: $memyMarker')
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
    presenceStatus,
    lastSeenExternallyAtUtc,
    firstMissingObservationAtUtc,
    lastMissingObservationAtUtc,
    missingObservationCount,
    lastCompleteQueryStartUtc,
    lastCompleteQueryEndUtc,
    hiddenLocally,
    memyMarker,
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
          other.createdAtUtc == this.createdAtUtc &&
          other.presenceStatus == this.presenceStatus &&
          other.lastSeenExternallyAtUtc == this.lastSeenExternallyAtUtc &&
          other.firstMissingObservationAtUtc ==
              this.firstMissingObservationAtUtc &&
          other.lastMissingObservationAtUtc ==
              this.lastMissingObservationAtUtc &&
          other.missingObservationCount == this.missingObservationCount &&
          other.lastCompleteQueryStartUtc == this.lastCompleteQueryStartUtc &&
          other.lastCompleteQueryEndUtc == this.lastCompleteQueryEndUtc &&
          other.hiddenLocally == this.hiddenLocally &&
          other.memyMarker == this.memyMarker);
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
  final Value<String> presenceStatus;
  final Value<DateTime?> lastSeenExternallyAtUtc;
  final Value<DateTime?> firstMissingObservationAtUtc;
  final Value<DateTime?> lastMissingObservationAtUtc;
  final Value<int> missingObservationCount;
  final Value<DateTime?> lastCompleteQueryStartUtc;
  final Value<DateTime?> lastCompleteQueryEndUtc;
  final Value<bool> hiddenLocally;
  final Value<String?> memyMarker;
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
    this.presenceStatus = const Value.absent(),
    this.lastSeenExternallyAtUtc = const Value.absent(),
    this.firstMissingObservationAtUtc = const Value.absent(),
    this.lastMissingObservationAtUtc = const Value.absent(),
    this.missingObservationCount = const Value.absent(),
    this.lastCompleteQueryStartUtc = const Value.absent(),
    this.lastCompleteQueryEndUtc = const Value.absent(),
    this.hiddenLocally = const Value.absent(),
    this.memyMarker = const Value.absent(),
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
    this.presenceStatus = const Value.absent(),
    this.lastSeenExternallyAtUtc = const Value.absent(),
    this.firstMissingObservationAtUtc = const Value.absent(),
    this.lastMissingObservationAtUtc = const Value.absent(),
    this.missingObservationCount = const Value.absent(),
    this.lastCompleteQueryStartUtc = const Value.absent(),
    this.lastCompleteQueryEndUtc = const Value.absent(),
    this.hiddenLocally = const Value.absent(),
    this.memyMarker = const Value.absent(),
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
    Expression<String>? presenceStatus,
    Expression<DateTime>? lastSeenExternallyAtUtc,
    Expression<DateTime>? firstMissingObservationAtUtc,
    Expression<DateTime>? lastMissingObservationAtUtc,
    Expression<int>? missingObservationCount,
    Expression<DateTime>? lastCompleteQueryStartUtc,
    Expression<DateTime>? lastCompleteQueryEndUtc,
    Expression<bool>? hiddenLocally,
    Expression<String>? memyMarker,
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
      if (presenceStatus != null) 'presence_status': presenceStatus,
      if (lastSeenExternallyAtUtc != null)
        'last_seen_externally_at_utc': lastSeenExternallyAtUtc,
      if (firstMissingObservationAtUtc != null)
        'first_missing_observation_at_utc': firstMissingObservationAtUtc,
      if (lastMissingObservationAtUtc != null)
        'last_missing_observation_at_utc': lastMissingObservationAtUtc,
      if (missingObservationCount != null)
        'missing_observation_count': missingObservationCount,
      if (lastCompleteQueryStartUtc != null)
        'last_complete_query_start_utc': lastCompleteQueryStartUtc,
      if (lastCompleteQueryEndUtc != null)
        'last_complete_query_end_utc': lastCompleteQueryEndUtc,
      if (hiddenLocally != null) 'hidden_locally': hiddenLocally,
      if (memyMarker != null) 'memy_marker': memyMarker,
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
    Value<String>? presenceStatus,
    Value<DateTime?>? lastSeenExternallyAtUtc,
    Value<DateTime?>? firstMissingObservationAtUtc,
    Value<DateTime?>? lastMissingObservationAtUtc,
    Value<int>? missingObservationCount,
    Value<DateTime?>? lastCompleteQueryStartUtc,
    Value<DateTime?>? lastCompleteQueryEndUtc,
    Value<bool>? hiddenLocally,
    Value<String?>? memyMarker,
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
      presenceStatus: presenceStatus ?? this.presenceStatus,
      lastSeenExternallyAtUtc:
          lastSeenExternallyAtUtc ?? this.lastSeenExternallyAtUtc,
      firstMissingObservationAtUtc:
          firstMissingObservationAtUtc ?? this.firstMissingObservationAtUtc,
      lastMissingObservationAtUtc:
          lastMissingObservationAtUtc ?? this.lastMissingObservationAtUtc,
      missingObservationCount:
          missingObservationCount ?? this.missingObservationCount,
      lastCompleteQueryStartUtc:
          lastCompleteQueryStartUtc ?? this.lastCompleteQueryStartUtc,
      lastCompleteQueryEndUtc:
          lastCompleteQueryEndUtc ?? this.lastCompleteQueryEndUtc,
      hiddenLocally: hiddenLocally ?? this.hiddenLocally,
      memyMarker: memyMarker ?? this.memyMarker,
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
    if (presenceStatus.present) {
      map['presence_status'] = Variable<String>(presenceStatus.value);
    }
    if (lastSeenExternallyAtUtc.present) {
      map['last_seen_externally_at_utc'] = Variable<DateTime>(
        lastSeenExternallyAtUtc.value,
      );
    }
    if (firstMissingObservationAtUtc.present) {
      map['first_missing_observation_at_utc'] = Variable<DateTime>(
        firstMissingObservationAtUtc.value,
      );
    }
    if (lastMissingObservationAtUtc.present) {
      map['last_missing_observation_at_utc'] = Variable<DateTime>(
        lastMissingObservationAtUtc.value,
      );
    }
    if (missingObservationCount.present) {
      map['missing_observation_count'] = Variable<int>(
        missingObservationCount.value,
      );
    }
    if (lastCompleteQueryStartUtc.present) {
      map['last_complete_query_start_utc'] = Variable<DateTime>(
        lastCompleteQueryStartUtc.value,
      );
    }
    if (lastCompleteQueryEndUtc.present) {
      map['last_complete_query_end_utc'] = Variable<DateTime>(
        lastCompleteQueryEndUtc.value,
      );
    }
    if (hiddenLocally.present) {
      map['hidden_locally'] = Variable<bool>(hiddenLocally.value);
    }
    if (memyMarker.present) {
      map['memy_marker'] = Variable<String>(memyMarker.value);
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
          ..write('presenceStatus: $presenceStatus, ')
          ..write('lastSeenExternallyAtUtc: $lastSeenExternallyAtUtc, ')
          ..write(
            'firstMissingObservationAtUtc: $firstMissingObservationAtUtc, ',
          )
          ..write('lastMissingObservationAtUtc: $lastMissingObservationAtUtc, ')
          ..write('missingObservationCount: $missingObservationCount, ')
          ..write('lastCompleteQueryStartUtc: $lastCompleteQueryStartUtc, ')
          ..write('lastCompleteQueryEndUtc: $lastCompleteQueryEndUtc, ')
          ..write('hiddenLocally: $hiddenLocally, ')
          ..write('memyMarker: $memyMarker, ')
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

class $CalendarSyncOperationsTable extends CalendarSyncOperations
    with TableInfo<$CalendarSyncOperationsTable, CalendarSyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarSyncOperationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCalendarIdMeta = const VerificationMeta(
    'targetCalendarId',
  );
  @override
  late final GeneratedColumn<String> targetCalendarId = GeneratedColumn<String>(
    'target_calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadFingerprintMeta =
      const VerificationMeta('payloadFingerprint');
  @override
  late final GeneratedColumn<String> payloadFingerprint =
      GeneratedColumn<String>(
        'payload_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _providerExternalEventIdMeta =
      const VerificationMeta('providerExternalEventId');
  @override
  late final GeneratedColumn<String> providerExternalEventId =
      GeneratedColumn<String>(
        'provider_external_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _memyMarkerMeta = const VerificationMeta(
    'memyMarker',
  );
  @override
  late final GeneratedColumn<String> memyMarker = GeneratedColumn<String>(
    'memy_marker',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextRetryAtUtcMeta = const VerificationMeta(
    'nextRetryAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAtUtc =
      GeneratedColumn<DateTime>(
        'next_retry_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memyEventId,
    operationType,
    targetCalendarId,
    payloadFingerprint,
    state,
    attemptCount,
    providerExternalEventId,
    memyMarker,
    createdAtUtc,
    startedAtUtc,
    completedAtUtc,
    nextRetryAtUtc,
    lastErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarSyncOperation> instance, {
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
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('target_calendar_id')) {
      context.handle(
        _targetCalendarIdMeta,
        targetCalendarId.isAcceptableOrUnknown(
          data['target_calendar_id']!,
          _targetCalendarIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCalendarIdMeta);
    }
    if (data.containsKey('payload_fingerprint')) {
      context.handle(
        _payloadFingerprintMeta,
        payloadFingerprint.isAcceptableOrUnknown(
          data['payload_fingerprint']!,
          _payloadFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadFingerprintMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('provider_external_event_id')) {
      context.handle(
        _providerExternalEventIdMeta,
        providerExternalEventId.isAcceptableOrUnknown(
          data['provider_external_event_id']!,
          _providerExternalEventIdMeta,
        ),
      );
    }
    if (data.containsKey('memy_marker')) {
      context.handle(
        _memyMarkerMeta,
        memyMarker.isAcceptableOrUnknown(data['memy_marker']!, _memyMarkerMeta),
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
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at_utc')) {
      context.handle(
        _nextRetryAtUtcMeta,
        nextRetryAtUtc.isAcceptableOrUnknown(
          data['next_retry_at_utc']!,
          _nextRetryAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarSyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarSyncOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memyEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memy_event_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      targetCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_calendar_id'],
      )!,
      payloadFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_fingerprint'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      providerExternalEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_external_event_id'],
      ),
      memyMarker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memy_marker'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      ),
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      nextRetryAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at_utc'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
    );
  }

  @override
  $CalendarSyncOperationsTable createAlias(String alias) {
    return $CalendarSyncOperationsTable(attachedDatabase, alias);
  }
}

class CalendarSyncOperation extends DataClass
    implements Insertable<CalendarSyncOperation> {
  final String id;
  final String memyEventId;
  final String operationType;
  final String targetCalendarId;
  final String payloadFingerprint;
  final String state;
  final int attemptCount;
  final String? providerExternalEventId;
  final String? memyMarker;
  final DateTime createdAtUtc;
  final DateTime? startedAtUtc;
  final DateTime? completedAtUtc;
  final DateTime? nextRetryAtUtc;
  final String? lastErrorCode;
  const CalendarSyncOperation({
    required this.id,
    required this.memyEventId,
    required this.operationType,
    required this.targetCalendarId,
    required this.payloadFingerprint,
    required this.state,
    required this.attemptCount,
    this.providerExternalEventId,
    this.memyMarker,
    required this.createdAtUtc,
    this.startedAtUtc,
    this.completedAtUtc,
    this.nextRetryAtUtc,
    this.lastErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memy_event_id'] = Variable<String>(memyEventId);
    map['operation_type'] = Variable<String>(operationType);
    map['target_calendar_id'] = Variable<String>(targetCalendarId);
    map['payload_fingerprint'] = Variable<String>(payloadFingerprint);
    map['state'] = Variable<String>(state);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || providerExternalEventId != null) {
      map['provider_external_event_id'] = Variable<String>(
        providerExternalEventId,
      );
    }
    if (!nullToAbsent || memyMarker != null) {
      map['memy_marker'] = Variable<String>(memyMarker);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    if (!nullToAbsent || startedAtUtc != null) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    }
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    if (!nullToAbsent || nextRetryAtUtc != null) {
      map['next_retry_at_utc'] = Variable<DateTime>(nextRetryAtUtc);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    return map;
  }

  CalendarSyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return CalendarSyncOperationsCompanion(
      id: Value(id),
      memyEventId: Value(memyEventId),
      operationType: Value(operationType),
      targetCalendarId: Value(targetCalendarId),
      payloadFingerprint: Value(payloadFingerprint),
      state: Value(state),
      attemptCount: Value(attemptCount),
      providerExternalEventId: providerExternalEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExternalEventId),
      memyMarker: memyMarker == null && nullToAbsent
          ? const Value.absent()
          : Value(memyMarker),
      createdAtUtc: Value(createdAtUtc),
      startedAtUtc: startedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAtUtc),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      nextRetryAtUtc: nextRetryAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAtUtc),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
    );
  }

  factory CalendarSyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarSyncOperation(
      id: serializer.fromJson<String>(json['id']),
      memyEventId: serializer.fromJson<String>(json['memyEventId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      targetCalendarId: serializer.fromJson<String>(json['targetCalendarId']),
      payloadFingerprint: serializer.fromJson<String>(
        json['payloadFingerprint'],
      ),
      state: serializer.fromJson<String>(json['state']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      providerExternalEventId: serializer.fromJson<String?>(
        json['providerExternalEventId'],
      ),
      memyMarker: serializer.fromJson<String?>(json['memyMarker']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      startedAtUtc: serializer.fromJson<DateTime?>(json['startedAtUtc']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      nextRetryAtUtc: serializer.fromJson<DateTime?>(json['nextRetryAtUtc']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memyEventId': serializer.toJson<String>(memyEventId),
      'operationType': serializer.toJson<String>(operationType),
      'targetCalendarId': serializer.toJson<String>(targetCalendarId),
      'payloadFingerprint': serializer.toJson<String>(payloadFingerprint),
      'state': serializer.toJson<String>(state),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'providerExternalEventId': serializer.toJson<String?>(
        providerExternalEventId,
      ),
      'memyMarker': serializer.toJson<String?>(memyMarker),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'startedAtUtc': serializer.toJson<DateTime?>(startedAtUtc),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'nextRetryAtUtc': serializer.toJson<DateTime?>(nextRetryAtUtc),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
    };
  }

  CalendarSyncOperation copyWith({
    String? id,
    String? memyEventId,
    String? operationType,
    String? targetCalendarId,
    String? payloadFingerprint,
    String? state,
    int? attemptCount,
    Value<String?> providerExternalEventId = const Value.absent(),
    Value<String?> memyMarker = const Value.absent(),
    DateTime? createdAtUtc,
    Value<DateTime?> startedAtUtc = const Value.absent(),
    Value<DateTime?> completedAtUtc = const Value.absent(),
    Value<DateTime?> nextRetryAtUtc = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
  }) => CalendarSyncOperation(
    id: id ?? this.id,
    memyEventId: memyEventId ?? this.memyEventId,
    operationType: operationType ?? this.operationType,
    targetCalendarId: targetCalendarId ?? this.targetCalendarId,
    payloadFingerprint: payloadFingerprint ?? this.payloadFingerprint,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    providerExternalEventId: providerExternalEventId.present
        ? providerExternalEventId.value
        : this.providerExternalEventId,
    memyMarker: memyMarker.present ? memyMarker.value : this.memyMarker,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    startedAtUtc: startedAtUtc.present ? startedAtUtc.value : this.startedAtUtc,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    nextRetryAtUtc: nextRetryAtUtc.present
        ? nextRetryAtUtc.value
        : this.nextRetryAtUtc,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
  );
  CalendarSyncOperation copyWithCompanion(
    CalendarSyncOperationsCompanion data,
  ) {
    return CalendarSyncOperation(
      id: data.id.present ? data.id.value : this.id,
      memyEventId: data.memyEventId.present
          ? data.memyEventId.value
          : this.memyEventId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      targetCalendarId: data.targetCalendarId.present
          ? data.targetCalendarId.value
          : this.targetCalendarId,
      payloadFingerprint: data.payloadFingerprint.present
          ? data.payloadFingerprint.value
          : this.payloadFingerprint,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      providerExternalEventId: data.providerExternalEventId.present
          ? data.providerExternalEventId.value
          : this.providerExternalEventId,
      memyMarker: data.memyMarker.present
          ? data.memyMarker.value
          : this.memyMarker,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      nextRetryAtUtc: data.nextRetryAtUtc.present
          ? data.nextRetryAtUtc.value
          : this.nextRetryAtUtc,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarSyncOperation(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('operationType: $operationType, ')
          ..write('targetCalendarId: $targetCalendarId, ')
          ..write('payloadFingerprint: $payloadFingerprint, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('providerExternalEventId: $providerExternalEventId, ')
          ..write('memyMarker: $memyMarker, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('nextRetryAtUtc: $nextRetryAtUtc, ')
          ..write('lastErrorCode: $lastErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memyEventId,
    operationType,
    targetCalendarId,
    payloadFingerprint,
    state,
    attemptCount,
    providerExternalEventId,
    memyMarker,
    createdAtUtc,
    startedAtUtc,
    completedAtUtc,
    nextRetryAtUtc,
    lastErrorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarSyncOperation &&
          other.id == this.id &&
          other.memyEventId == this.memyEventId &&
          other.operationType == this.operationType &&
          other.targetCalendarId == this.targetCalendarId &&
          other.payloadFingerprint == this.payloadFingerprint &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.providerExternalEventId == this.providerExternalEventId &&
          other.memyMarker == this.memyMarker &&
          other.createdAtUtc == this.createdAtUtc &&
          other.startedAtUtc == this.startedAtUtc &&
          other.completedAtUtc == this.completedAtUtc &&
          other.nextRetryAtUtc == this.nextRetryAtUtc &&
          other.lastErrorCode == this.lastErrorCode);
}

class CalendarSyncOperationsCompanion
    extends UpdateCompanion<CalendarSyncOperation> {
  final Value<String> id;
  final Value<String> memyEventId;
  final Value<String> operationType;
  final Value<String> targetCalendarId;
  final Value<String> payloadFingerprint;
  final Value<String> state;
  final Value<int> attemptCount;
  final Value<String?> providerExternalEventId;
  final Value<String?> memyMarker;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime?> startedAtUtc;
  final Value<DateTime?> completedAtUtc;
  final Value<DateTime?> nextRetryAtUtc;
  final Value<String?> lastErrorCode;
  final Value<int> rowid;
  const CalendarSyncOperationsCompanion({
    this.id = const Value.absent(),
    this.memyEventId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.targetCalendarId = const Value.absent(),
    this.payloadFingerprint = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.providerExternalEventId = const Value.absent(),
    this.memyMarker = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.nextRetryAtUtc = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarSyncOperationsCompanion.insert({
    required String id,
    required String memyEventId,
    required String operationType,
    required String targetCalendarId,
    required String payloadFingerprint,
    required String state,
    this.attemptCount = const Value.absent(),
    this.providerExternalEventId = const Value.absent(),
    this.memyMarker = const Value.absent(),
    required DateTime createdAtUtc,
    this.startedAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.nextRetryAtUtc = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memyEventId = Value(memyEventId),
       operationType = Value(operationType),
       targetCalendarId = Value(targetCalendarId),
       payloadFingerprint = Value(payloadFingerprint),
       state = Value(state),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<CalendarSyncOperation> custom({
    Expression<String>? id,
    Expression<String>? memyEventId,
    Expression<String>? operationType,
    Expression<String>? targetCalendarId,
    Expression<String>? payloadFingerprint,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<String>? providerExternalEventId,
    Expression<String>? memyMarker,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? completedAtUtc,
    Expression<DateTime>? nextRetryAtUtc,
    Expression<String>? lastErrorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memyEventId != null) 'memy_event_id': memyEventId,
      if (operationType != null) 'operation_type': operationType,
      if (targetCalendarId != null) 'target_calendar_id': targetCalendarId,
      if (payloadFingerprint != null) 'payload_fingerprint': payloadFingerprint,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (providerExternalEventId != null)
        'provider_external_event_id': providerExternalEventId,
      if (memyMarker != null) 'memy_marker': memyMarker,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (nextRetryAtUtc != null) 'next_retry_at_utc': nextRetryAtUtc,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarSyncOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? memyEventId,
    Value<String>? operationType,
    Value<String>? targetCalendarId,
    Value<String>? payloadFingerprint,
    Value<String>? state,
    Value<int>? attemptCount,
    Value<String?>? providerExternalEventId,
    Value<String?>? memyMarker,
    Value<DateTime>? createdAtUtc,
    Value<DateTime?>? startedAtUtc,
    Value<DateTime?>? completedAtUtc,
    Value<DateTime?>? nextRetryAtUtc,
    Value<String?>? lastErrorCode,
    Value<int>? rowid,
  }) {
    return CalendarSyncOperationsCompanion(
      id: id ?? this.id,
      memyEventId: memyEventId ?? this.memyEventId,
      operationType: operationType ?? this.operationType,
      targetCalendarId: targetCalendarId ?? this.targetCalendarId,
      payloadFingerprint: payloadFingerprint ?? this.payloadFingerprint,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      providerExternalEventId:
          providerExternalEventId ?? this.providerExternalEventId,
      memyMarker: memyMarker ?? this.memyMarker,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      nextRetryAtUtc: nextRetryAtUtc ?? this.nextRetryAtUtc,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
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
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (targetCalendarId.present) {
      map['target_calendar_id'] = Variable<String>(targetCalendarId.value);
    }
    if (payloadFingerprint.present) {
      map['payload_fingerprint'] = Variable<String>(payloadFingerprint.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (providerExternalEventId.present) {
      map['provider_external_event_id'] = Variable<String>(
        providerExternalEventId.value,
      );
    }
    if (memyMarker.present) {
      map['memy_marker'] = Variable<String>(memyMarker.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (nextRetryAtUtc.present) {
      map['next_retry_at_utc'] = Variable<DateTime>(nextRetryAtUtc.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarSyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('memyEventId: $memyEventId, ')
          ..write('operationType: $operationType, ')
          ..write('targetCalendarId: $targetCalendarId, ')
          ..write('payloadFingerprint: $payloadFingerprint, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('providerExternalEventId: $providerExternalEventId, ')
          ..write('memyMarker: $memyMarker, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('nextRetryAtUtc: $nextRetryAtUtc, ')
          ..write('lastErrorCode: $lastErrorCode, ')
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
  static const VerificationMeta _readableCalendarIdsJsonMeta =
      const VerificationMeta('readableCalendarIdsJson');
  @override
  late final GeneratedColumn<String> readableCalendarIdsJson =
      GeneratedColumn<String>(
        'readable_calendar_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _defaultWritableCalendarIdMeta =
      const VerificationMeta('defaultWritableCalendarId');
  @override
  late final GeneratedColumn<String> defaultWritableCalendarId =
      GeneratedColumn<String>(
        'default_writable_calendar_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dedicatedMeMyCalendarIdMeta =
      const VerificationMeta('dedicatedMeMyCalendarId');
  @override
  late final GeneratedColumn<String> dedicatedMeMyCalendarId =
      GeneratedColumn<String>(
        'dedicated_me_my_calendar_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncPastWindowDaysMeta =
      const VerificationMeta('syncPastWindowDays');
  @override
  late final GeneratedColumn<int> syncPastWindowDays = GeneratedColumn<int>(
    'sync_past_window_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _syncFutureWindowDaysMeta =
      const VerificationMeta('syncFutureWindowDays');
  @override
  late final GeneratedColumn<int> syncFutureWindowDays = GeneratedColumn<int>(
    'sync_future_window_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(365),
  );
  static const VerificationMeta _calendarSchemaVersionMeta =
      const VerificationMeta('calendarSchemaVersion');
  @override
  late final GeneratedColumn<int> calendarSchemaVersion = GeneratedColumn<int>(
    'calendar_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
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
  static const VerificationMeta _lastSuccessfulPullAtUtcMeta =
      const VerificationMeta('lastSuccessfulPullAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulPullAtUtc =
      GeneratedColumn<DateTime>(
        'last_successful_pull_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuccessfulPushAtUtcMeta =
      const VerificationMeta('lastSuccessfulPushAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulPushAtUtc =
      GeneratedColumn<DateTime>(
        'last_successful_push_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastPermissionCheckAtUtcMeta =
      const VerificationMeta('lastPermissionCheckAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastPermissionCheckAtUtc =
      GeneratedColumn<DateTime>(
        'last_permission_check_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastCalendarDiscoveryAtUtcMeta =
      const VerificationMeta('lastCalendarDiscoveryAtUtc');
  @override
  late final GeneratedColumn<DateTime> lastCalendarDiscoveryAtUtc =
      GeneratedColumn<DateTime>(
        'last_calendar_discovery_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _connectionConfiguredAtUtcMeta =
      const VerificationMeta('connectionConfiguredAtUtc');
  @override
  late final GeneratedColumn<DateTime> connectionConfiguredAtUtc =
      GeneratedColumn<DateTime>(
        'connection_configured_at_utc',
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
    readableCalendarIdsJson,
    defaultWritableCalendarId,
    dedicatedMeMyCalendarId,
    syncPastWindowDays,
    syncFutureWindowDays,
    calendarSchemaVersion,
    lastFullSyncAtUtc,
    lastSuccessfulPullAtUtc,
    lastSuccessfulPushAtUtc,
    lastPermissionCheckAtUtc,
    lastCalendarDiscoveryAtUtc,
    connectionConfiguredAtUtc,
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
    if (data.containsKey('readable_calendar_ids_json')) {
      context.handle(
        _readableCalendarIdsJsonMeta,
        readableCalendarIdsJson.isAcceptableOrUnknown(
          data['readable_calendar_ids_json']!,
          _readableCalendarIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('default_writable_calendar_id')) {
      context.handle(
        _defaultWritableCalendarIdMeta,
        defaultWritableCalendarId.isAcceptableOrUnknown(
          data['default_writable_calendar_id']!,
          _defaultWritableCalendarIdMeta,
        ),
      );
    }
    if (data.containsKey('dedicated_me_my_calendar_id')) {
      context.handle(
        _dedicatedMeMyCalendarIdMeta,
        dedicatedMeMyCalendarId.isAcceptableOrUnknown(
          data['dedicated_me_my_calendar_id']!,
          _dedicatedMeMyCalendarIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_past_window_days')) {
      context.handle(
        _syncPastWindowDaysMeta,
        syncPastWindowDays.isAcceptableOrUnknown(
          data['sync_past_window_days']!,
          _syncPastWindowDaysMeta,
        ),
      );
    }
    if (data.containsKey('sync_future_window_days')) {
      context.handle(
        _syncFutureWindowDaysMeta,
        syncFutureWindowDays.isAcceptableOrUnknown(
          data['sync_future_window_days']!,
          _syncFutureWindowDaysMeta,
        ),
      );
    }
    if (data.containsKey('calendar_schema_version')) {
      context.handle(
        _calendarSchemaVersionMeta,
        calendarSchemaVersion.isAcceptableOrUnknown(
          data['calendar_schema_version']!,
          _calendarSchemaVersionMeta,
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
    if (data.containsKey('last_successful_pull_at_utc')) {
      context.handle(
        _lastSuccessfulPullAtUtcMeta,
        lastSuccessfulPullAtUtc.isAcceptableOrUnknown(
          data['last_successful_pull_at_utc']!,
          _lastSuccessfulPullAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_push_at_utc')) {
      context.handle(
        _lastSuccessfulPushAtUtcMeta,
        lastSuccessfulPushAtUtc.isAcceptableOrUnknown(
          data['last_successful_push_at_utc']!,
          _lastSuccessfulPushAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_permission_check_at_utc')) {
      context.handle(
        _lastPermissionCheckAtUtcMeta,
        lastPermissionCheckAtUtc.isAcceptableOrUnknown(
          data['last_permission_check_at_utc']!,
          _lastPermissionCheckAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_calendar_discovery_at_utc')) {
      context.handle(
        _lastCalendarDiscoveryAtUtcMeta,
        lastCalendarDiscoveryAtUtc.isAcceptableOrUnknown(
          data['last_calendar_discovery_at_utc']!,
          _lastCalendarDiscoveryAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('connection_configured_at_utc')) {
      context.handle(
        _connectionConfiguredAtUtcMeta,
        connectionConfiguredAtUtc.isAcceptableOrUnknown(
          data['connection_configured_at_utc']!,
          _connectionConfiguredAtUtcMeta,
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
      readableCalendarIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}readable_calendar_ids_json'],
      )!,
      defaultWritableCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_writable_calendar_id'],
      ),
      dedicatedMeMyCalendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedicated_me_my_calendar_id'],
      ),
      syncPastWindowDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_past_window_days'],
      )!,
      syncFutureWindowDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_future_window_days'],
      )!,
      calendarSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calendar_schema_version'],
      )!,
      lastFullSyncAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_full_sync_at_utc'],
      ),
      lastSuccessfulPullAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_pull_at_utc'],
      ),
      lastSuccessfulPushAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_push_at_utc'],
      ),
      lastPermissionCheckAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_permission_check_at_utc'],
      ),
      lastCalendarDiscoveryAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_calendar_discovery_at_utc'],
      ),
      connectionConfiguredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connection_configured_at_utc'],
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

  /// Legacy v1 column — migrated into [readableCalendarIdsJson].
  final String selectedCalendarIdsJson;
  final String readableCalendarIdsJson;
  final String? defaultWritableCalendarId;
  final String? dedicatedMeMyCalendarId;
  final int syncPastWindowDays;
  final int syncFutureWindowDays;
  final int calendarSchemaVersion;
  final DateTime? lastFullSyncAtUtc;
  final DateTime? lastSuccessfulPullAtUtc;
  final DateTime? lastSuccessfulPushAtUtc;
  final DateTime? lastPermissionCheckAtUtc;
  final DateTime? lastCalendarDiscoveryAtUtc;
  final DateTime? connectionConfiguredAtUtc;

  /// Legacy frozen anchors — retained for migration, unused by sync.
  final DateTime? initialSyncAnchorPastUtc;
  final DateTime? initialSyncAnchorFutureUtc;
  const CalendarConfigRow({
    required this.id,
    required this.selectedCalendarIdsJson,
    required this.readableCalendarIdsJson,
    this.defaultWritableCalendarId,
    this.dedicatedMeMyCalendarId,
    required this.syncPastWindowDays,
    required this.syncFutureWindowDays,
    required this.calendarSchemaVersion,
    this.lastFullSyncAtUtc,
    this.lastSuccessfulPullAtUtc,
    this.lastSuccessfulPushAtUtc,
    this.lastPermissionCheckAtUtc,
    this.lastCalendarDiscoveryAtUtc,
    this.connectionConfiguredAtUtc,
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
    map['readable_calendar_ids_json'] = Variable<String>(
      readableCalendarIdsJson,
    );
    if (!nullToAbsent || defaultWritableCalendarId != null) {
      map['default_writable_calendar_id'] = Variable<String>(
        defaultWritableCalendarId,
      );
    }
    if (!nullToAbsent || dedicatedMeMyCalendarId != null) {
      map['dedicated_me_my_calendar_id'] = Variable<String>(
        dedicatedMeMyCalendarId,
      );
    }
    map['sync_past_window_days'] = Variable<int>(syncPastWindowDays);
    map['sync_future_window_days'] = Variable<int>(syncFutureWindowDays);
    map['calendar_schema_version'] = Variable<int>(calendarSchemaVersion);
    if (!nullToAbsent || lastFullSyncAtUtc != null) {
      map['last_full_sync_at_utc'] = Variable<DateTime>(lastFullSyncAtUtc);
    }
    if (!nullToAbsent || lastSuccessfulPullAtUtc != null) {
      map['last_successful_pull_at_utc'] = Variable<DateTime>(
        lastSuccessfulPullAtUtc,
      );
    }
    if (!nullToAbsent || lastSuccessfulPushAtUtc != null) {
      map['last_successful_push_at_utc'] = Variable<DateTime>(
        lastSuccessfulPushAtUtc,
      );
    }
    if (!nullToAbsent || lastPermissionCheckAtUtc != null) {
      map['last_permission_check_at_utc'] = Variable<DateTime>(
        lastPermissionCheckAtUtc,
      );
    }
    if (!nullToAbsent || lastCalendarDiscoveryAtUtc != null) {
      map['last_calendar_discovery_at_utc'] = Variable<DateTime>(
        lastCalendarDiscoveryAtUtc,
      );
    }
    if (!nullToAbsent || connectionConfiguredAtUtc != null) {
      map['connection_configured_at_utc'] = Variable<DateTime>(
        connectionConfiguredAtUtc,
      );
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
      readableCalendarIdsJson: Value(readableCalendarIdsJson),
      defaultWritableCalendarId:
          defaultWritableCalendarId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWritableCalendarId),
      dedicatedMeMyCalendarId: dedicatedMeMyCalendarId == null && nullToAbsent
          ? const Value.absent()
          : Value(dedicatedMeMyCalendarId),
      syncPastWindowDays: Value(syncPastWindowDays),
      syncFutureWindowDays: Value(syncFutureWindowDays),
      calendarSchemaVersion: Value(calendarSchemaVersion),
      lastFullSyncAtUtc: lastFullSyncAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFullSyncAtUtc),
      lastSuccessfulPullAtUtc: lastSuccessfulPullAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulPullAtUtc),
      lastSuccessfulPushAtUtc: lastSuccessfulPushAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulPushAtUtc),
      lastPermissionCheckAtUtc: lastPermissionCheckAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPermissionCheckAtUtc),
      lastCalendarDiscoveryAtUtc:
          lastCalendarDiscoveryAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCalendarDiscoveryAtUtc),
      connectionConfiguredAtUtc:
          connectionConfiguredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(connectionConfiguredAtUtc),
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
      readableCalendarIdsJson: serializer.fromJson<String>(
        json['readableCalendarIdsJson'],
      ),
      defaultWritableCalendarId: serializer.fromJson<String?>(
        json['defaultWritableCalendarId'],
      ),
      dedicatedMeMyCalendarId: serializer.fromJson<String?>(
        json['dedicatedMeMyCalendarId'],
      ),
      syncPastWindowDays: serializer.fromJson<int>(json['syncPastWindowDays']),
      syncFutureWindowDays: serializer.fromJson<int>(
        json['syncFutureWindowDays'],
      ),
      calendarSchemaVersion: serializer.fromJson<int>(
        json['calendarSchemaVersion'],
      ),
      lastFullSyncAtUtc: serializer.fromJson<DateTime?>(
        json['lastFullSyncAtUtc'],
      ),
      lastSuccessfulPullAtUtc: serializer.fromJson<DateTime?>(
        json['lastSuccessfulPullAtUtc'],
      ),
      lastSuccessfulPushAtUtc: serializer.fromJson<DateTime?>(
        json['lastSuccessfulPushAtUtc'],
      ),
      lastPermissionCheckAtUtc: serializer.fromJson<DateTime?>(
        json['lastPermissionCheckAtUtc'],
      ),
      lastCalendarDiscoveryAtUtc: serializer.fromJson<DateTime?>(
        json['lastCalendarDiscoveryAtUtc'],
      ),
      connectionConfiguredAtUtc: serializer.fromJson<DateTime?>(
        json['connectionConfiguredAtUtc'],
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
      'readableCalendarIdsJson': serializer.toJson<String>(
        readableCalendarIdsJson,
      ),
      'defaultWritableCalendarId': serializer.toJson<String?>(
        defaultWritableCalendarId,
      ),
      'dedicatedMeMyCalendarId': serializer.toJson<String?>(
        dedicatedMeMyCalendarId,
      ),
      'syncPastWindowDays': serializer.toJson<int>(syncPastWindowDays),
      'syncFutureWindowDays': serializer.toJson<int>(syncFutureWindowDays),
      'calendarSchemaVersion': serializer.toJson<int>(calendarSchemaVersion),
      'lastFullSyncAtUtc': serializer.toJson<DateTime?>(lastFullSyncAtUtc),
      'lastSuccessfulPullAtUtc': serializer.toJson<DateTime?>(
        lastSuccessfulPullAtUtc,
      ),
      'lastSuccessfulPushAtUtc': serializer.toJson<DateTime?>(
        lastSuccessfulPushAtUtc,
      ),
      'lastPermissionCheckAtUtc': serializer.toJson<DateTime?>(
        lastPermissionCheckAtUtc,
      ),
      'lastCalendarDiscoveryAtUtc': serializer.toJson<DateTime?>(
        lastCalendarDiscoveryAtUtc,
      ),
      'connectionConfiguredAtUtc': serializer.toJson<DateTime?>(
        connectionConfiguredAtUtc,
      ),
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
    String? readableCalendarIdsJson,
    Value<String?> defaultWritableCalendarId = const Value.absent(),
    Value<String?> dedicatedMeMyCalendarId = const Value.absent(),
    int? syncPastWindowDays,
    int? syncFutureWindowDays,
    int? calendarSchemaVersion,
    Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
    Value<DateTime?> lastSuccessfulPullAtUtc = const Value.absent(),
    Value<DateTime?> lastSuccessfulPushAtUtc = const Value.absent(),
    Value<DateTime?> lastPermissionCheckAtUtc = const Value.absent(),
    Value<DateTime?> lastCalendarDiscoveryAtUtc = const Value.absent(),
    Value<DateTime?> connectionConfiguredAtUtc = const Value.absent(),
    Value<DateTime?> initialSyncAnchorPastUtc = const Value.absent(),
    Value<DateTime?> initialSyncAnchorFutureUtc = const Value.absent(),
  }) => CalendarConfigRow(
    id: id ?? this.id,
    selectedCalendarIdsJson:
        selectedCalendarIdsJson ?? this.selectedCalendarIdsJson,
    readableCalendarIdsJson:
        readableCalendarIdsJson ?? this.readableCalendarIdsJson,
    defaultWritableCalendarId: defaultWritableCalendarId.present
        ? defaultWritableCalendarId.value
        : this.defaultWritableCalendarId,
    dedicatedMeMyCalendarId: dedicatedMeMyCalendarId.present
        ? dedicatedMeMyCalendarId.value
        : this.dedicatedMeMyCalendarId,
    syncPastWindowDays: syncPastWindowDays ?? this.syncPastWindowDays,
    syncFutureWindowDays: syncFutureWindowDays ?? this.syncFutureWindowDays,
    calendarSchemaVersion: calendarSchemaVersion ?? this.calendarSchemaVersion,
    lastFullSyncAtUtc: lastFullSyncAtUtc.present
        ? lastFullSyncAtUtc.value
        : this.lastFullSyncAtUtc,
    lastSuccessfulPullAtUtc: lastSuccessfulPullAtUtc.present
        ? lastSuccessfulPullAtUtc.value
        : this.lastSuccessfulPullAtUtc,
    lastSuccessfulPushAtUtc: lastSuccessfulPushAtUtc.present
        ? lastSuccessfulPushAtUtc.value
        : this.lastSuccessfulPushAtUtc,
    lastPermissionCheckAtUtc: lastPermissionCheckAtUtc.present
        ? lastPermissionCheckAtUtc.value
        : this.lastPermissionCheckAtUtc,
    lastCalendarDiscoveryAtUtc: lastCalendarDiscoveryAtUtc.present
        ? lastCalendarDiscoveryAtUtc.value
        : this.lastCalendarDiscoveryAtUtc,
    connectionConfiguredAtUtc: connectionConfiguredAtUtc.present
        ? connectionConfiguredAtUtc.value
        : this.connectionConfiguredAtUtc,
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
      readableCalendarIdsJson: data.readableCalendarIdsJson.present
          ? data.readableCalendarIdsJson.value
          : this.readableCalendarIdsJson,
      defaultWritableCalendarId: data.defaultWritableCalendarId.present
          ? data.defaultWritableCalendarId.value
          : this.defaultWritableCalendarId,
      dedicatedMeMyCalendarId: data.dedicatedMeMyCalendarId.present
          ? data.dedicatedMeMyCalendarId.value
          : this.dedicatedMeMyCalendarId,
      syncPastWindowDays: data.syncPastWindowDays.present
          ? data.syncPastWindowDays.value
          : this.syncPastWindowDays,
      syncFutureWindowDays: data.syncFutureWindowDays.present
          ? data.syncFutureWindowDays.value
          : this.syncFutureWindowDays,
      calendarSchemaVersion: data.calendarSchemaVersion.present
          ? data.calendarSchemaVersion.value
          : this.calendarSchemaVersion,
      lastFullSyncAtUtc: data.lastFullSyncAtUtc.present
          ? data.lastFullSyncAtUtc.value
          : this.lastFullSyncAtUtc,
      lastSuccessfulPullAtUtc: data.lastSuccessfulPullAtUtc.present
          ? data.lastSuccessfulPullAtUtc.value
          : this.lastSuccessfulPullAtUtc,
      lastSuccessfulPushAtUtc: data.lastSuccessfulPushAtUtc.present
          ? data.lastSuccessfulPushAtUtc.value
          : this.lastSuccessfulPushAtUtc,
      lastPermissionCheckAtUtc: data.lastPermissionCheckAtUtc.present
          ? data.lastPermissionCheckAtUtc.value
          : this.lastPermissionCheckAtUtc,
      lastCalendarDiscoveryAtUtc: data.lastCalendarDiscoveryAtUtc.present
          ? data.lastCalendarDiscoveryAtUtc.value
          : this.lastCalendarDiscoveryAtUtc,
      connectionConfiguredAtUtc: data.connectionConfiguredAtUtc.present
          ? data.connectionConfiguredAtUtc.value
          : this.connectionConfiguredAtUtc,
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
          ..write('readableCalendarIdsJson: $readableCalendarIdsJson, ')
          ..write('defaultWritableCalendarId: $defaultWritableCalendarId, ')
          ..write('dedicatedMeMyCalendarId: $dedicatedMeMyCalendarId, ')
          ..write('syncPastWindowDays: $syncPastWindowDays, ')
          ..write('syncFutureWindowDays: $syncFutureWindowDays, ')
          ..write('calendarSchemaVersion: $calendarSchemaVersion, ')
          ..write('lastFullSyncAtUtc: $lastFullSyncAtUtc, ')
          ..write('lastSuccessfulPullAtUtc: $lastSuccessfulPullAtUtc, ')
          ..write('lastSuccessfulPushAtUtc: $lastSuccessfulPushAtUtc, ')
          ..write('lastPermissionCheckAtUtc: $lastPermissionCheckAtUtc, ')
          ..write('lastCalendarDiscoveryAtUtc: $lastCalendarDiscoveryAtUtc, ')
          ..write('connectionConfiguredAtUtc: $connectionConfiguredAtUtc, ')
          ..write('initialSyncAnchorPastUtc: $initialSyncAnchorPastUtc, ')
          ..write('initialSyncAnchorFutureUtc: $initialSyncAnchorFutureUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    selectedCalendarIdsJson,
    readableCalendarIdsJson,
    defaultWritableCalendarId,
    dedicatedMeMyCalendarId,
    syncPastWindowDays,
    syncFutureWindowDays,
    calendarSchemaVersion,
    lastFullSyncAtUtc,
    lastSuccessfulPullAtUtc,
    lastSuccessfulPushAtUtc,
    lastPermissionCheckAtUtc,
    lastCalendarDiscoveryAtUtc,
    connectionConfiguredAtUtc,
    initialSyncAnchorPastUtc,
    initialSyncAnchorFutureUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarConfigRow &&
          other.id == this.id &&
          other.selectedCalendarIdsJson == this.selectedCalendarIdsJson &&
          other.readableCalendarIdsJson == this.readableCalendarIdsJson &&
          other.defaultWritableCalendarId == this.defaultWritableCalendarId &&
          other.dedicatedMeMyCalendarId == this.dedicatedMeMyCalendarId &&
          other.syncPastWindowDays == this.syncPastWindowDays &&
          other.syncFutureWindowDays == this.syncFutureWindowDays &&
          other.calendarSchemaVersion == this.calendarSchemaVersion &&
          other.lastFullSyncAtUtc == this.lastFullSyncAtUtc &&
          other.lastSuccessfulPullAtUtc == this.lastSuccessfulPullAtUtc &&
          other.lastSuccessfulPushAtUtc == this.lastSuccessfulPushAtUtc &&
          other.lastPermissionCheckAtUtc == this.lastPermissionCheckAtUtc &&
          other.lastCalendarDiscoveryAtUtc == this.lastCalendarDiscoveryAtUtc &&
          other.connectionConfiguredAtUtc == this.connectionConfiguredAtUtc &&
          other.initialSyncAnchorPastUtc == this.initialSyncAnchorPastUtc &&
          other.initialSyncAnchorFutureUtc == this.initialSyncAnchorFutureUtc);
}

class CalendarConfigRowsCompanion extends UpdateCompanion<CalendarConfigRow> {
  final Value<int> id;
  final Value<String> selectedCalendarIdsJson;
  final Value<String> readableCalendarIdsJson;
  final Value<String?> defaultWritableCalendarId;
  final Value<String?> dedicatedMeMyCalendarId;
  final Value<int> syncPastWindowDays;
  final Value<int> syncFutureWindowDays;
  final Value<int> calendarSchemaVersion;
  final Value<DateTime?> lastFullSyncAtUtc;
  final Value<DateTime?> lastSuccessfulPullAtUtc;
  final Value<DateTime?> lastSuccessfulPushAtUtc;
  final Value<DateTime?> lastPermissionCheckAtUtc;
  final Value<DateTime?> lastCalendarDiscoveryAtUtc;
  final Value<DateTime?> connectionConfiguredAtUtc;
  final Value<DateTime?> initialSyncAnchorPastUtc;
  final Value<DateTime?> initialSyncAnchorFutureUtc;
  const CalendarConfigRowsCompanion({
    this.id = const Value.absent(),
    this.selectedCalendarIdsJson = const Value.absent(),
    this.readableCalendarIdsJson = const Value.absent(),
    this.defaultWritableCalendarId = const Value.absent(),
    this.dedicatedMeMyCalendarId = const Value.absent(),
    this.syncPastWindowDays = const Value.absent(),
    this.syncFutureWindowDays = const Value.absent(),
    this.calendarSchemaVersion = const Value.absent(),
    this.lastFullSyncAtUtc = const Value.absent(),
    this.lastSuccessfulPullAtUtc = const Value.absent(),
    this.lastSuccessfulPushAtUtc = const Value.absent(),
    this.lastPermissionCheckAtUtc = const Value.absent(),
    this.lastCalendarDiscoveryAtUtc = const Value.absent(),
    this.connectionConfiguredAtUtc = const Value.absent(),
    this.initialSyncAnchorPastUtc = const Value.absent(),
    this.initialSyncAnchorFutureUtc = const Value.absent(),
  });
  CalendarConfigRowsCompanion.insert({
    this.id = const Value.absent(),
    this.selectedCalendarIdsJson = const Value.absent(),
    this.readableCalendarIdsJson = const Value.absent(),
    this.defaultWritableCalendarId = const Value.absent(),
    this.dedicatedMeMyCalendarId = const Value.absent(),
    this.syncPastWindowDays = const Value.absent(),
    this.syncFutureWindowDays = const Value.absent(),
    this.calendarSchemaVersion = const Value.absent(),
    this.lastFullSyncAtUtc = const Value.absent(),
    this.lastSuccessfulPullAtUtc = const Value.absent(),
    this.lastSuccessfulPushAtUtc = const Value.absent(),
    this.lastPermissionCheckAtUtc = const Value.absent(),
    this.lastCalendarDiscoveryAtUtc = const Value.absent(),
    this.connectionConfiguredAtUtc = const Value.absent(),
    this.initialSyncAnchorPastUtc = const Value.absent(),
    this.initialSyncAnchorFutureUtc = const Value.absent(),
  });
  static Insertable<CalendarConfigRow> custom({
    Expression<int>? id,
    Expression<String>? selectedCalendarIdsJson,
    Expression<String>? readableCalendarIdsJson,
    Expression<String>? defaultWritableCalendarId,
    Expression<String>? dedicatedMeMyCalendarId,
    Expression<int>? syncPastWindowDays,
    Expression<int>? syncFutureWindowDays,
    Expression<int>? calendarSchemaVersion,
    Expression<DateTime>? lastFullSyncAtUtc,
    Expression<DateTime>? lastSuccessfulPullAtUtc,
    Expression<DateTime>? lastSuccessfulPushAtUtc,
    Expression<DateTime>? lastPermissionCheckAtUtc,
    Expression<DateTime>? lastCalendarDiscoveryAtUtc,
    Expression<DateTime>? connectionConfiguredAtUtc,
    Expression<DateTime>? initialSyncAnchorPastUtc,
    Expression<DateTime>? initialSyncAnchorFutureUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selectedCalendarIdsJson != null)
        'selected_calendar_ids_json': selectedCalendarIdsJson,
      if (readableCalendarIdsJson != null)
        'readable_calendar_ids_json': readableCalendarIdsJson,
      if (defaultWritableCalendarId != null)
        'default_writable_calendar_id': defaultWritableCalendarId,
      if (dedicatedMeMyCalendarId != null)
        'dedicated_me_my_calendar_id': dedicatedMeMyCalendarId,
      if (syncPastWindowDays != null)
        'sync_past_window_days': syncPastWindowDays,
      if (syncFutureWindowDays != null)
        'sync_future_window_days': syncFutureWindowDays,
      if (calendarSchemaVersion != null)
        'calendar_schema_version': calendarSchemaVersion,
      if (lastFullSyncAtUtc != null) 'last_full_sync_at_utc': lastFullSyncAtUtc,
      if (lastSuccessfulPullAtUtc != null)
        'last_successful_pull_at_utc': lastSuccessfulPullAtUtc,
      if (lastSuccessfulPushAtUtc != null)
        'last_successful_push_at_utc': lastSuccessfulPushAtUtc,
      if (lastPermissionCheckAtUtc != null)
        'last_permission_check_at_utc': lastPermissionCheckAtUtc,
      if (lastCalendarDiscoveryAtUtc != null)
        'last_calendar_discovery_at_utc': lastCalendarDiscoveryAtUtc,
      if (connectionConfiguredAtUtc != null)
        'connection_configured_at_utc': connectionConfiguredAtUtc,
      if (initialSyncAnchorPastUtc != null)
        'initial_sync_anchor_past_utc': initialSyncAnchorPastUtc,
      if (initialSyncAnchorFutureUtc != null)
        'initial_sync_anchor_future_utc': initialSyncAnchorFutureUtc,
    });
  }

  CalendarConfigRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? selectedCalendarIdsJson,
    Value<String>? readableCalendarIdsJson,
    Value<String?>? defaultWritableCalendarId,
    Value<String?>? dedicatedMeMyCalendarId,
    Value<int>? syncPastWindowDays,
    Value<int>? syncFutureWindowDays,
    Value<int>? calendarSchemaVersion,
    Value<DateTime?>? lastFullSyncAtUtc,
    Value<DateTime?>? lastSuccessfulPullAtUtc,
    Value<DateTime?>? lastSuccessfulPushAtUtc,
    Value<DateTime?>? lastPermissionCheckAtUtc,
    Value<DateTime?>? lastCalendarDiscoveryAtUtc,
    Value<DateTime?>? connectionConfiguredAtUtc,
    Value<DateTime?>? initialSyncAnchorPastUtc,
    Value<DateTime?>? initialSyncAnchorFutureUtc,
  }) {
    return CalendarConfigRowsCompanion(
      id: id ?? this.id,
      selectedCalendarIdsJson:
          selectedCalendarIdsJson ?? this.selectedCalendarIdsJson,
      readableCalendarIdsJson:
          readableCalendarIdsJson ?? this.readableCalendarIdsJson,
      defaultWritableCalendarId:
          defaultWritableCalendarId ?? this.defaultWritableCalendarId,
      dedicatedMeMyCalendarId:
          dedicatedMeMyCalendarId ?? this.dedicatedMeMyCalendarId,
      syncPastWindowDays: syncPastWindowDays ?? this.syncPastWindowDays,
      syncFutureWindowDays: syncFutureWindowDays ?? this.syncFutureWindowDays,
      calendarSchemaVersion:
          calendarSchemaVersion ?? this.calendarSchemaVersion,
      lastFullSyncAtUtc: lastFullSyncAtUtc ?? this.lastFullSyncAtUtc,
      lastSuccessfulPullAtUtc:
          lastSuccessfulPullAtUtc ?? this.lastSuccessfulPullAtUtc,
      lastSuccessfulPushAtUtc:
          lastSuccessfulPushAtUtc ?? this.lastSuccessfulPushAtUtc,
      lastPermissionCheckAtUtc:
          lastPermissionCheckAtUtc ?? this.lastPermissionCheckAtUtc,
      lastCalendarDiscoveryAtUtc:
          lastCalendarDiscoveryAtUtc ?? this.lastCalendarDiscoveryAtUtc,
      connectionConfiguredAtUtc:
          connectionConfiguredAtUtc ?? this.connectionConfiguredAtUtc,
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
    if (readableCalendarIdsJson.present) {
      map['readable_calendar_ids_json'] = Variable<String>(
        readableCalendarIdsJson.value,
      );
    }
    if (defaultWritableCalendarId.present) {
      map['default_writable_calendar_id'] = Variable<String>(
        defaultWritableCalendarId.value,
      );
    }
    if (dedicatedMeMyCalendarId.present) {
      map['dedicated_me_my_calendar_id'] = Variable<String>(
        dedicatedMeMyCalendarId.value,
      );
    }
    if (syncPastWindowDays.present) {
      map['sync_past_window_days'] = Variable<int>(syncPastWindowDays.value);
    }
    if (syncFutureWindowDays.present) {
      map['sync_future_window_days'] = Variable<int>(
        syncFutureWindowDays.value,
      );
    }
    if (calendarSchemaVersion.present) {
      map['calendar_schema_version'] = Variable<int>(
        calendarSchemaVersion.value,
      );
    }
    if (lastFullSyncAtUtc.present) {
      map['last_full_sync_at_utc'] = Variable<DateTime>(
        lastFullSyncAtUtc.value,
      );
    }
    if (lastSuccessfulPullAtUtc.present) {
      map['last_successful_pull_at_utc'] = Variable<DateTime>(
        lastSuccessfulPullAtUtc.value,
      );
    }
    if (lastSuccessfulPushAtUtc.present) {
      map['last_successful_push_at_utc'] = Variable<DateTime>(
        lastSuccessfulPushAtUtc.value,
      );
    }
    if (lastPermissionCheckAtUtc.present) {
      map['last_permission_check_at_utc'] = Variable<DateTime>(
        lastPermissionCheckAtUtc.value,
      );
    }
    if (lastCalendarDiscoveryAtUtc.present) {
      map['last_calendar_discovery_at_utc'] = Variable<DateTime>(
        lastCalendarDiscoveryAtUtc.value,
      );
    }
    if (connectionConfiguredAtUtc.present) {
      map['connection_configured_at_utc'] = Variable<DateTime>(
        connectionConfiguredAtUtc.value,
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
          ..write('readableCalendarIdsJson: $readableCalendarIdsJson, ')
          ..write('defaultWritableCalendarId: $defaultWritableCalendarId, ')
          ..write('dedicatedMeMyCalendarId: $dedicatedMeMyCalendarId, ')
          ..write('syncPastWindowDays: $syncPastWindowDays, ')
          ..write('syncFutureWindowDays: $syncFutureWindowDays, ')
          ..write('calendarSchemaVersion: $calendarSchemaVersion, ')
          ..write('lastFullSyncAtUtc: $lastFullSyncAtUtc, ')
          ..write('lastSuccessfulPullAtUtc: $lastSuccessfulPullAtUtc, ')
          ..write('lastSuccessfulPushAtUtc: $lastSuccessfulPushAtUtc, ')
          ..write('lastPermissionCheckAtUtc: $lastPermissionCheckAtUtc, ')
          ..write('lastCalendarDiscoveryAtUtc: $lastCalendarDiscoveryAtUtc, ')
          ..write('connectionConfiguredAtUtc: $connectionConfiguredAtUtc, ')
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
  late final $CalendarSyncOperationsTable calendarSyncOperations =
      $CalendarSyncOperationsTable(this);
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
    calendarSyncOperations,
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
      Value<String?> recurrenceRule,
      Value<bool> isRecurringInstance,
      Value<String?> seriesExternalEventId,
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
      Value<String?> recurrenceRule,
      Value<bool> isRecurringInstance,
      Value<String?> seriesExternalEventId,
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

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesExternalEventId => $composableBuilder(
    column: $table.seriesExternalEventId,
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

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesExternalEventId => $composableBuilder(
    column: $table.seriesExternalEventId,
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

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesExternalEventId => $composableBuilder(
    column: $table.seriesExternalEventId,
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
                Value<String?> recurrenceRule = const Value.absent(),
                Value<bool> isRecurringInstance = const Value.absent(),
                Value<String?> seriesExternalEventId = const Value.absent(),
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
                recurrenceRule: recurrenceRule,
                isRecurringInstance: isRecurringInstance,
                seriesExternalEventId: seriesExternalEventId,
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
                Value<String?> recurrenceRule = const Value.absent(),
                Value<bool> isRecurringInstance = const Value.absent(),
                Value<String?> seriesExternalEventId = const Value.absent(),
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
                recurrenceRule: recurrenceRule,
                isRecurringInstance: isRecurringInstance,
                seriesExternalEventId: seriesExternalEventId,
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
      Value<String> presenceStatus,
      Value<DateTime?> lastSeenExternallyAtUtc,
      Value<DateTime?> firstMissingObservationAtUtc,
      Value<DateTime?> lastMissingObservationAtUtc,
      Value<int> missingObservationCount,
      Value<DateTime?> lastCompleteQueryStartUtc,
      Value<DateTime?> lastCompleteQueryEndUtc,
      Value<bool> hiddenLocally,
      Value<String?> memyMarker,
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
      Value<String> presenceStatus,
      Value<DateTime?> lastSeenExternallyAtUtc,
      Value<DateTime?> firstMissingObservationAtUtc,
      Value<DateTime?> lastMissingObservationAtUtc,
      Value<int> missingObservationCount,
      Value<DateTime?> lastCompleteQueryStartUtc,
      Value<DateTime?> lastCompleteQueryEndUtc,
      Value<bool> hiddenLocally,
      Value<String?> memyMarker,
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

  ColumnFilters<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenExternallyAtUtc => $composableBuilder(
    column: $table.lastSeenExternallyAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstMissingObservationAtUtc =>
      $composableBuilder(
        column: $table.firstMissingObservationAtUtc,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastMissingObservationAtUtc => $composableBuilder(
    column: $table.lastMissingObservationAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get missingObservationCount => $composableBuilder(
    column: $table.missingObservationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompleteQueryStartUtc => $composableBuilder(
    column: $table.lastCompleteQueryStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompleteQueryEndUtc => $composableBuilder(
    column: $table.lastCompleteQueryEndUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hiddenLocally => $composableBuilder(
    column: $table.hiddenLocally,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
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

  ColumnOrderings<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenExternallyAtUtc => $composableBuilder(
    column: $table.lastSeenExternallyAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstMissingObservationAtUtc =>
      $composableBuilder(
        column: $table.firstMissingObservationAtUtc,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastMissingObservationAtUtc =>
      $composableBuilder(
        column: $table.lastMissingObservationAtUtc,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get missingObservationCount => $composableBuilder(
    column: $table.missingObservationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompleteQueryStartUtc => $composableBuilder(
    column: $table.lastCompleteQueryStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompleteQueryEndUtc => $composableBuilder(
    column: $table.lastCompleteQueryEndUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hiddenLocally => $composableBuilder(
    column: $table.hiddenLocally,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
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

  GeneratedColumn<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenExternallyAtUtc => $composableBuilder(
    column: $table.lastSeenExternallyAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstMissingObservationAtUtc =>
      $composableBuilder(
        column: $table.firstMissingObservationAtUtc,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastMissingObservationAtUtc =>
      $composableBuilder(
        column: $table.lastMissingObservationAtUtc,
        builder: (column) => column,
      );

  GeneratedColumn<int> get missingObservationCount => $composableBuilder(
    column: $table.missingObservationCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompleteQueryStartUtc => $composableBuilder(
    column: $table.lastCompleteQueryStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompleteQueryEndUtc => $composableBuilder(
    column: $table.lastCompleteQueryEndUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hiddenLocally => $composableBuilder(
    column: $table.hiddenLocally,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
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
                Value<String> presenceStatus = const Value.absent(),
                Value<DateTime?> lastSeenExternallyAtUtc = const Value.absent(),
                Value<DateTime?> firstMissingObservationAtUtc =
                    const Value.absent(),
                Value<DateTime?> lastMissingObservationAtUtc =
                    const Value.absent(),
                Value<int> missingObservationCount = const Value.absent(),
                Value<DateTime?> lastCompleteQueryStartUtc =
                    const Value.absent(),
                Value<DateTime?> lastCompleteQueryEndUtc = const Value.absent(),
                Value<bool> hiddenLocally = const Value.absent(),
                Value<String?> memyMarker = const Value.absent(),
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
                presenceStatus: presenceStatus,
                lastSeenExternallyAtUtc: lastSeenExternallyAtUtc,
                firstMissingObservationAtUtc: firstMissingObservationAtUtc,
                lastMissingObservationAtUtc: lastMissingObservationAtUtc,
                missingObservationCount: missingObservationCount,
                lastCompleteQueryStartUtc: lastCompleteQueryStartUtc,
                lastCompleteQueryEndUtc: lastCompleteQueryEndUtc,
                hiddenLocally: hiddenLocally,
                memyMarker: memyMarker,
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
                Value<String> presenceStatus = const Value.absent(),
                Value<DateTime?> lastSeenExternallyAtUtc = const Value.absent(),
                Value<DateTime?> firstMissingObservationAtUtc =
                    const Value.absent(),
                Value<DateTime?> lastMissingObservationAtUtc =
                    const Value.absent(),
                Value<int> missingObservationCount = const Value.absent(),
                Value<DateTime?> lastCompleteQueryStartUtc =
                    const Value.absent(),
                Value<DateTime?> lastCompleteQueryEndUtc = const Value.absent(),
                Value<bool> hiddenLocally = const Value.absent(),
                Value<String?> memyMarker = const Value.absent(),
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
                presenceStatus: presenceStatus,
                lastSeenExternallyAtUtc: lastSeenExternallyAtUtc,
                firstMissingObservationAtUtc: firstMissingObservationAtUtc,
                lastMissingObservationAtUtc: lastMissingObservationAtUtc,
                missingObservationCount: missingObservationCount,
                lastCompleteQueryStartUtc: lastCompleteQueryStartUtc,
                lastCompleteQueryEndUtc: lastCompleteQueryEndUtc,
                hiddenLocally: hiddenLocally,
                memyMarker: memyMarker,
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
typedef $$CalendarSyncOperationsTableCreateCompanionBuilder =
    CalendarSyncOperationsCompanion Function({
      required String id,
      required String memyEventId,
      required String operationType,
      required String targetCalendarId,
      required String payloadFingerprint,
      required String state,
      Value<int> attemptCount,
      Value<String?> providerExternalEventId,
      Value<String?> memyMarker,
      required DateTime createdAtUtc,
      Value<DateTime?> startedAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<DateTime?> nextRetryAtUtc,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });
typedef $$CalendarSyncOperationsTableUpdateCompanionBuilder =
    CalendarSyncOperationsCompanion Function({
      Value<String> id,
      Value<String> memyEventId,
      Value<String> operationType,
      Value<String> targetCalendarId,
      Value<String> payloadFingerprint,
      Value<String> state,
      Value<int> attemptCount,
      Value<String?> providerExternalEventId,
      Value<String?> memyMarker,
      Value<DateTime> createdAtUtc,
      Value<DateTime?> startedAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<DateTime?> nextRetryAtUtc,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });

class $$CalendarSyncOperationsTableFilterComposer
    extends Composer<_$CalendarDatabase, $CalendarSyncOperationsTable> {
  $$CalendarSyncOperationsTableFilterComposer({
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

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCalendarId => $composableBuilder(
    column: $table.targetCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExternalEventId => $composableBuilder(
    column: $table.providerExternalEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAtUtc => $composableBuilder(
    column: $table.nextRetryAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarSyncOperationsTableOrderingComposer
    extends Composer<_$CalendarDatabase, $CalendarSyncOperationsTable> {
  $$CalendarSyncOperationsTableOrderingComposer({
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

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCalendarId => $composableBuilder(
    column: $table.targetCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExternalEventId => $composableBuilder(
    column: $table.providerExternalEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAtUtc => $composableBuilder(
    column: $table.nextRetryAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarSyncOperationsTableAnnotationComposer
    extends Composer<_$CalendarDatabase, $CalendarSyncOperationsTable> {
  $$CalendarSyncOperationsTableAnnotationComposer({
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

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCalendarId => $composableBuilder(
    column: $table.targetCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExternalEventId => $composableBuilder(
    column: $table.providerExternalEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memyMarker => $composableBuilder(
    column: $table.memyMarker,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAtUtc => $composableBuilder(
    column: $table.nextRetryAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );
}

class $$CalendarSyncOperationsTableTableManager
    extends
        RootTableManager<
          _$CalendarDatabase,
          $CalendarSyncOperationsTable,
          CalendarSyncOperation,
          $$CalendarSyncOperationsTableFilterComposer,
          $$CalendarSyncOperationsTableOrderingComposer,
          $$CalendarSyncOperationsTableAnnotationComposer,
          $$CalendarSyncOperationsTableCreateCompanionBuilder,
          $$CalendarSyncOperationsTableUpdateCompanionBuilder,
          (
            CalendarSyncOperation,
            BaseReferences<
              _$CalendarDatabase,
              $CalendarSyncOperationsTable,
              CalendarSyncOperation
            >,
          ),
          CalendarSyncOperation,
          PrefetchHooks Function()
        > {
  $$CalendarSyncOperationsTableTableManager(
    _$CalendarDatabase db,
    $CalendarSyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarSyncOperationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CalendarSyncOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CalendarSyncOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memyEventId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> targetCalendarId = const Value.absent(),
                Value<String> payloadFingerprint = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> providerExternalEventId = const Value.absent(),
                Value<String?> memyMarker = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime?> startedAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> nextRetryAtUtc = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarSyncOperationsCompanion(
                id: id,
                memyEventId: memyEventId,
                operationType: operationType,
                targetCalendarId: targetCalendarId,
                payloadFingerprint: payloadFingerprint,
                state: state,
                attemptCount: attemptCount,
                providerExternalEventId: providerExternalEventId,
                memyMarker: memyMarker,
                createdAtUtc: createdAtUtc,
                startedAtUtc: startedAtUtc,
                completedAtUtc: completedAtUtc,
                nextRetryAtUtc: nextRetryAtUtc,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memyEventId,
                required String operationType,
                required String targetCalendarId,
                required String payloadFingerprint,
                required String state,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> providerExternalEventId = const Value.absent(),
                Value<String?> memyMarker = const Value.absent(),
                required DateTime createdAtUtc,
                Value<DateTime?> startedAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> nextRetryAtUtc = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarSyncOperationsCompanion.insert(
                id: id,
                memyEventId: memyEventId,
                operationType: operationType,
                targetCalendarId: targetCalendarId,
                payloadFingerprint: payloadFingerprint,
                state: state,
                attemptCount: attemptCount,
                providerExternalEventId: providerExternalEventId,
                memyMarker: memyMarker,
                createdAtUtc: createdAtUtc,
                startedAtUtc: startedAtUtc,
                completedAtUtc: completedAtUtc,
                nextRetryAtUtc: nextRetryAtUtc,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarSyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalendarDatabase,
      $CalendarSyncOperationsTable,
      CalendarSyncOperation,
      $$CalendarSyncOperationsTableFilterComposer,
      $$CalendarSyncOperationsTableOrderingComposer,
      $$CalendarSyncOperationsTableAnnotationComposer,
      $$CalendarSyncOperationsTableCreateCompanionBuilder,
      $$CalendarSyncOperationsTableUpdateCompanionBuilder,
      (
        CalendarSyncOperation,
        BaseReferences<
          _$CalendarDatabase,
          $CalendarSyncOperationsTable,
          CalendarSyncOperation
        >,
      ),
      CalendarSyncOperation,
      PrefetchHooks Function()
    >;
typedef $$CalendarConfigRowsTableCreateCompanionBuilder =
    CalendarConfigRowsCompanion Function({
      Value<int> id,
      Value<String> selectedCalendarIdsJson,
      Value<String> readableCalendarIdsJson,
      Value<String?> defaultWritableCalendarId,
      Value<String?> dedicatedMeMyCalendarId,
      Value<int> syncPastWindowDays,
      Value<int> syncFutureWindowDays,
      Value<int> calendarSchemaVersion,
      Value<DateTime?> lastFullSyncAtUtc,
      Value<DateTime?> lastSuccessfulPullAtUtc,
      Value<DateTime?> lastSuccessfulPushAtUtc,
      Value<DateTime?> lastPermissionCheckAtUtc,
      Value<DateTime?> lastCalendarDiscoveryAtUtc,
      Value<DateTime?> connectionConfiguredAtUtc,
      Value<DateTime?> initialSyncAnchorPastUtc,
      Value<DateTime?> initialSyncAnchorFutureUtc,
    });
typedef $$CalendarConfigRowsTableUpdateCompanionBuilder =
    CalendarConfigRowsCompanion Function({
      Value<int> id,
      Value<String> selectedCalendarIdsJson,
      Value<String> readableCalendarIdsJson,
      Value<String?> defaultWritableCalendarId,
      Value<String?> dedicatedMeMyCalendarId,
      Value<int> syncPastWindowDays,
      Value<int> syncFutureWindowDays,
      Value<int> calendarSchemaVersion,
      Value<DateTime?> lastFullSyncAtUtc,
      Value<DateTime?> lastSuccessfulPullAtUtc,
      Value<DateTime?> lastSuccessfulPushAtUtc,
      Value<DateTime?> lastPermissionCheckAtUtc,
      Value<DateTime?> lastCalendarDiscoveryAtUtc,
      Value<DateTime?> connectionConfiguredAtUtc,
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

  ColumnFilters<String> get readableCalendarIdsJson => $composableBuilder(
    column: $table.readableCalendarIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultWritableCalendarId => $composableBuilder(
    column: $table.defaultWritableCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedicatedMeMyCalendarId => $composableBuilder(
    column: $table.dedicatedMeMyCalendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncPastWindowDays => $composableBuilder(
    column: $table.syncPastWindowDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncFutureWindowDays => $composableBuilder(
    column: $table.syncFutureWindowDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calendarSchemaVersion => $composableBuilder(
    column: $table.calendarSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulPullAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPullAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulPushAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPushAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPermissionCheckAtUtc => $composableBuilder(
    column: $table.lastPermissionCheckAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCalendarDiscoveryAtUtc => $composableBuilder(
    column: $table.lastCalendarDiscoveryAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectionConfiguredAtUtc => $composableBuilder(
    column: $table.connectionConfiguredAtUtc,
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

  ColumnOrderings<String> get readableCalendarIdsJson => $composableBuilder(
    column: $table.readableCalendarIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultWritableCalendarId => $composableBuilder(
    column: $table.defaultWritableCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedicatedMeMyCalendarId => $composableBuilder(
    column: $table.dedicatedMeMyCalendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncPastWindowDays => $composableBuilder(
    column: $table.syncPastWindowDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncFutureWindowDays => $composableBuilder(
    column: $table.syncFutureWindowDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calendarSchemaVersion => $composableBuilder(
    column: $table.calendarSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulPullAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPullAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulPushAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPushAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPermissionCheckAtUtc => $composableBuilder(
    column: $table.lastPermissionCheckAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCalendarDiscoveryAtUtc =>
      $composableBuilder(
        column: $table.lastCalendarDiscoveryAtUtc,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get connectionConfiguredAtUtc => $composableBuilder(
    column: $table.connectionConfiguredAtUtc,
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

  GeneratedColumn<String> get readableCalendarIdsJson => $composableBuilder(
    column: $table.readableCalendarIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultWritableCalendarId => $composableBuilder(
    column: $table.defaultWritableCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dedicatedMeMyCalendarId => $composableBuilder(
    column: $table.dedicatedMeMyCalendarId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncPastWindowDays => $composableBuilder(
    column: $table.syncPastWindowDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncFutureWindowDays => $composableBuilder(
    column: $table.syncFutureWindowDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calendarSchemaVersion => $composableBuilder(
    column: $table.calendarSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFullSyncAtUtc => $composableBuilder(
    column: $table.lastFullSyncAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulPullAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPullAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulPushAtUtc => $composableBuilder(
    column: $table.lastSuccessfulPushAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPermissionCheckAtUtc => $composableBuilder(
    column: $table.lastPermissionCheckAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCalendarDiscoveryAtUtc =>
      $composableBuilder(
        column: $table.lastCalendarDiscoveryAtUtc,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get connectionConfiguredAtUtc => $composableBuilder(
    column: $table.connectionConfiguredAtUtc,
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
                Value<String> readableCalendarIdsJson = const Value.absent(),
                Value<String?> defaultWritableCalendarId = const Value.absent(),
                Value<String?> dedicatedMeMyCalendarId = const Value.absent(),
                Value<int> syncPastWindowDays = const Value.absent(),
                Value<int> syncFutureWindowDays = const Value.absent(),
                Value<int> calendarSchemaVersion = const Value.absent(),
                Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
                Value<DateTime?> lastSuccessfulPullAtUtc = const Value.absent(),
                Value<DateTime?> lastSuccessfulPushAtUtc = const Value.absent(),
                Value<DateTime?> lastPermissionCheckAtUtc =
                    const Value.absent(),
                Value<DateTime?> lastCalendarDiscoveryAtUtc =
                    const Value.absent(),
                Value<DateTime?> connectionConfiguredAtUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorPastUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorFutureUtc =
                    const Value.absent(),
              }) => CalendarConfigRowsCompanion(
                id: id,
                selectedCalendarIdsJson: selectedCalendarIdsJson,
                readableCalendarIdsJson: readableCalendarIdsJson,
                defaultWritableCalendarId: defaultWritableCalendarId,
                dedicatedMeMyCalendarId: dedicatedMeMyCalendarId,
                syncPastWindowDays: syncPastWindowDays,
                syncFutureWindowDays: syncFutureWindowDays,
                calendarSchemaVersion: calendarSchemaVersion,
                lastFullSyncAtUtc: lastFullSyncAtUtc,
                lastSuccessfulPullAtUtc: lastSuccessfulPullAtUtc,
                lastSuccessfulPushAtUtc: lastSuccessfulPushAtUtc,
                lastPermissionCheckAtUtc: lastPermissionCheckAtUtc,
                lastCalendarDiscoveryAtUtc: lastCalendarDiscoveryAtUtc,
                connectionConfiguredAtUtc: connectionConfiguredAtUtc,
                initialSyncAnchorPastUtc: initialSyncAnchorPastUtc,
                initialSyncAnchorFutureUtc: initialSyncAnchorFutureUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> selectedCalendarIdsJson = const Value.absent(),
                Value<String> readableCalendarIdsJson = const Value.absent(),
                Value<String?> defaultWritableCalendarId = const Value.absent(),
                Value<String?> dedicatedMeMyCalendarId = const Value.absent(),
                Value<int> syncPastWindowDays = const Value.absent(),
                Value<int> syncFutureWindowDays = const Value.absent(),
                Value<int> calendarSchemaVersion = const Value.absent(),
                Value<DateTime?> lastFullSyncAtUtc = const Value.absent(),
                Value<DateTime?> lastSuccessfulPullAtUtc = const Value.absent(),
                Value<DateTime?> lastSuccessfulPushAtUtc = const Value.absent(),
                Value<DateTime?> lastPermissionCheckAtUtc =
                    const Value.absent(),
                Value<DateTime?> lastCalendarDiscoveryAtUtc =
                    const Value.absent(),
                Value<DateTime?> connectionConfiguredAtUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorPastUtc =
                    const Value.absent(),
                Value<DateTime?> initialSyncAnchorFutureUtc =
                    const Value.absent(),
              }) => CalendarConfigRowsCompanion.insert(
                id: id,
                selectedCalendarIdsJson: selectedCalendarIdsJson,
                readableCalendarIdsJson: readableCalendarIdsJson,
                defaultWritableCalendarId: defaultWritableCalendarId,
                dedicatedMeMyCalendarId: dedicatedMeMyCalendarId,
                syncPastWindowDays: syncPastWindowDays,
                syncFutureWindowDays: syncFutureWindowDays,
                calendarSchemaVersion: calendarSchemaVersion,
                lastFullSyncAtUtc: lastFullSyncAtUtc,
                lastSuccessfulPullAtUtc: lastSuccessfulPullAtUtc,
                lastSuccessfulPushAtUtc: lastSuccessfulPushAtUtc,
                lastPermissionCheckAtUtc: lastPermissionCheckAtUtc,
                lastCalendarDiscoveryAtUtc: lastCalendarDiscoveryAtUtc,
                connectionConfiguredAtUtc: connectionConfiguredAtUtc,
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
  $$CalendarSyncOperationsTableTableManager get calendarSyncOperations =>
      $$CalendarSyncOperationsTableTableManager(
        _db,
        _db.calendarSyncOperations,
      );
  $$CalendarConfigRowsTableTableManager get calendarConfigRows =>
      $$CalendarConfigRowsTableTableManager(_db, _db.calendarConfigRows);
}
