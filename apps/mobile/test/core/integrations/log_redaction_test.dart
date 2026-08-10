import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/integrations/domain/privacy/log_redaction.dart';

void main() {
  group('LogRedaction.redactText', () {
    test('redacts non-empty text', () {
      expect(
        LogRedaction.redactText('Doctor appointment'),
        LogRedaction.redacted,
      );
      expect(
        LogRedaction.redactText('secret notes about my life'),
        isNot(contains('secret')),
      );
    });

    test('returns empty string for null/empty input without leaking', () {
      expect(LogRedaction.redactText(null), '');
      expect(LogRedaction.redactText(''), '');
    });
  });

  group('LogRedaction.shortId', () {
    test('truncates long ids and keeps short ids intact', () {
      expect(LogRedaction.shortId('12345678901234'), '12345678…');
      expect(LogRedaction.shortId('abc123'), 'abc123');
    });
  });

  group('LogRedaction.redactList', () {
    test('only exposes a count, never the values', () {
      final result = LogRedaction.redactList([
        'alice@example.com',
        'bob@example.com',
      ]);
      expect(result, '2 item(s)');
      expect(result, isNot(contains('alice')));
      expect(result, isNot(contains('bob')));
    });

    test('handles null list as zero items', () {
      expect(LogRedaction.redactList(null), '0 item(s)');
    });
  });

  group('LogRedaction.describeCalendarEvent', () {
    test('never includes title/notes/location content, only shape', () {
      final description = LogRedaction.describeCalendarEvent(
        id: 'cal_evt_1234567890',
        hasTitle: true,
        hasNotes: true,
        hasLocation: true,
        isAllDay: false,
        attendeeCount: 3,
      );
      expect(description, contains('hasTitle: true'));
      expect(description, contains('attendees: 3'));
      expect(description, isNot(contains('cal_evt_1234567890')));
      expect(description, contains(LogRedaction.shortId('cal_evt_1234567890')));
    });
  });

  group('LogRedaction.describeHealthSample', () {
    test('never includes the sample value', () {
      final description = LogRedaction.describeHealthSample(
        type: 'heartRate',
        unit: 'bpm',
        recordedAt: DateTime(2026, 1, 1),
      );
      expect(description, contains('type: heartRate'));
      expect(description, contains('hasTimestamp: true'));
    });
  });

  group('LogRedaction.sanitizeMap', () {
    test('strips sensitive keys at any nesting depth', () {
      final sanitized = LogRedaction.sanitizeMap({
        'id': 'evt_1',
        'title': 'Secret meeting',
        'metadata': {'notes': 'Do not log this', 'count': 2},
      });

      expect(sanitized['id'], 'evt_1');
      expect(sanitized['title'], LogRedaction.redacted);
      final nested = sanitized['metadata'] as Map<String, Object?>;
      expect(nested['notes'], LogRedaction.redacted);
      expect(nested['count'], 2);
    });

    test('is case-insensitive for sensitive keys', () {
      final sanitized = LogRedaction.sanitizeMap({'Location': 'Home'});
      expect(sanitized['Location'], LogRedaction.redacted);
    });
  });
}
