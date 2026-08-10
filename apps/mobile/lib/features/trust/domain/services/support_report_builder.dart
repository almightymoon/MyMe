import '../entities/support_diagnostics_report.dart';

/// Allowlist-only support report for email / share.
///
/// Never includes event titles, health sample values, passwords, tokens,
/// or free-form exception text. Nested diagnostics are typed
/// ([SupportDiagnosticsReport]) — no blacklist walk in production.
class SupportReportBuilder {
  const SupportReportBuilder({this.diagnosticsProvider});

  /// Optional callback that returns a typed diagnostics snapshot.
  final Future<SupportDiagnosticsReport?> Function()? diagnosticsProvider;

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
      report['diagnostics'] = diagnostics.toJson();
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
        _writeMap(buffer, value, indent: 2);
      } else {
        buffer.writeln('$key: $value');
      }
    }
    return buffer.toString();
  }

  static void _writeMap(
    StringBuffer buffer,
    Map<Object?, Object?> map, {
    required int indent,
  }) {
    final pad = ' ' * indent;
    map.forEach((k, v) {
      if (v is Map) {
        buffer.writeln('$pad$k:');
        _writeMap(buffer, Map<Object?, Object?>.from(v), indent: indent + 2);
      } else {
        buffer.writeln('$pad$k: $v');
      }
    });
  }

  static String _sanitizeUserText(String input, {required int maxLength}) {
    var text = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }
    return text;
  }
}
