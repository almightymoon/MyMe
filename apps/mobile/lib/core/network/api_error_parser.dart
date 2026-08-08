import '../errors/app_exception.dart';

/// Parses NestJS error JSON:
/// `{ statusCode, code, message, details, timestamp, path }`
class ApiErrorParser {
  const ApiErrorParser._();

  static AppException fromStatusAndBody({
    required int? statusCode,
    Object? data,
  }) {
    final map = _asMap(data);
    final code = map?['code'] as String?;
    final message = _messageFrom(map) ?? _fallbackMessage(statusCode);
    final details = _detailsFrom(map);

    switch (statusCode) {
      case 400:
        return AppException.validation(message, code: code, details: details);
      case 401:
        return AppException.unauthorized(message);
      case 403:
        return AppException.forbidden(message);
      case 404:
        return AppException.notFound(message);
      case 409:
        return AppException.conflict(message);
      default:
        if (statusCode != null && statusCode >= 500) {
          return AppException.serverFailure(message);
        }
        return AppException.unknown(message);
    }
  }

  static Map<String, dynamic>? _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static String? _messageFrom(Map<String, dynamic>? map) {
    if (map == null) return null;
    final message = map['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join(', ');
    }
    return null;
  }

  static Map<String, dynamic> _detailsFrom(Map<String, dynamic>? map) {
    final details = map?['details'];
    if (details is Map<String, dynamic>) return details;
    if (details is Map) return Map<String, dynamic>.from(details);
    return const {};
  }

  static String _fallbackMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Please check your input and try again.';
      case 401:
        return 'Sign in is required to continue.';
      case 403:
        return 'You do not have access to this goal.';
      case 404:
        return 'That goal could not be found.';
      case 409:
        return 'This change conflicts with the current state.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Something went wrong on the server. Try again later.';
        }
        return 'Something went wrong. Please try again.';
    }
  }
}
