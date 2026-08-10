/// Allowlist-only support report for email / share.
///
/// Never includes event titles, health sample values, passwords, tokens,
/// or free-form exception text.
class SupportReportBuilder {
  const SupportReportBuilder({this.diagnosticsProvider});

  /// Optional callback that returns an already-redacted diagnostics map
  /// (e.g. [IntegrationDiagnosticsReport.toJson]).
  final Future<Map<String, Object?>?> Function()? diagnosticsProvider;

  static const Set<String> allowedTopLevelKeys = {
    'generatedAtUtc',
    'appVersion',
    'buildNumber',
    'packageName',
    'platform',
    'locale',
    'goalsDataSource',
    'financeDataSource',
    'habitsDataSource',
    'calendarDataSource',
    'healthDataSource',
    'feature',
    'userMessage',
    'diagnostics',
  };

  Future<Map<String, Object?>> build({
    required String appVersion,
    required String buildNumber,
    required String packageName,
    required String platform,
    required String locale,
    required String goalsDataSource,
    required String financeDataSource,
    required String habitsDataSource,
    required String calendarDataSource,
    required String healthDataSource,
    String? feature,
    String? userMessage,
    DateTime? generatedAt,
  }) async {
    final report = <String, Object?>{
      'generatedAtUtc': (generatedAt ?? DateTime.now().toUtc())
          .toIso8601String(),
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'packageName': packageName,
      'platform': platform,
      'locale': locale,
      'goalsDataSource': goalsDataSource,
      'financeDataSource': financeDataSource,
      'habitsDataSource': habitsDataSource,
      'calendarDataSource': calendarDataSource,
      'healthDataSource': healthDataSource,
    };

    final featureTrimmed = feature?.trim();
    if (featureTrimmed != null && featureTrimmed.isNotEmpty) {
      report['feature'] = _sanitizeUserText(featureTrimmed, maxLength: 80);
    }

    final messageTrimmed = userMessage?.trim();
    if (messageTrimmed != null && messageTrimmed.isNotEmpty) {
      report['userMessage'] = _sanitizeUserText(messageTrimmed, maxLength: 500);
    }

    final diagnostics = await diagnosticsProvider?.call();
    if (diagnostics != null) {
      report['diagnostics'] = _redactDiagnostics(diagnostics);
    }

    return Map<String, Object?>.unmodifiable(
      Map.fromEntries(
        report.entries.where((e) => allowedTopLevelKeys.contains(e.key)),
      ),
    );
  }

  String toPlainText(Map<String, Object?> report) {
    final buffer = StringBuffer('MeMy support report\n');
    buffer.writeln('-------------------');
    for (final key in allowedTopLevelKeys) {
      if (!report.containsKey(key)) continue;
      final value = report[key];
      if (value is Map) {
        buffer.writeln('$key:');
        value.forEach((k, v) {
          buffer.writeln('  $k: $v');
        });
      } else {
        buffer.writeln('$key: $value');
      }
    }
    return buffer.toString();
  }

  static String _sanitizeUserText(String input, {required int maxLength}) {
    var text = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }
    return text;
  }

  static Map<String, Object?> _redactDiagnostics(Map<String, Object?> raw) {
    // Nested maps from IntegrationDiagnosticsReport are already redacted;
    // still strip any unexpected keys that look like content fields.
    const forbidden = {
      'title',
      'titles',
      'notes',
      'note',
      'location',
      'locations',
      'value',
      'values',
      'steps',
      'heartRate',
      'weight',
      'email',
      'token',
      'password',
      'secret',
      'sample',
      'samples',
    };

    Map<String, Object?> walk(Map<Object?, Object?> map) {
      final out = <String, Object?>{};
      map.forEach((key, value) {
        final k = key?.toString() ?? '';
        if (forbidden.contains(k)) return;
        if (value is Map) {
          out[k] = walk(Map<Object?, Object?>.from(value));
        } else if (value is List) {
          out[k] = value
              .map((item) {
                if (item is Map) {
                  return walk(Map<Object?, Object?>.from(item));
                }
                return item;
              })
              .toList(growable: false);
        } else {
          out[k] = value;
        }
      });
      return out;
    }

    return walk(raw);
  }
}
