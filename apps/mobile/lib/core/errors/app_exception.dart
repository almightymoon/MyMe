/// Application-facing API / repository errors (never show raw Dio stacks).
enum AppErrorKind {
  validation,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  networkUnavailable,
  timeout,
  serverFailure,
  connectionRequired,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.kind,
    required this.message,
    this.code,
    this.statusCode,
    this.details = const {},
  });

  final AppErrorKind kind;
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic> details;

  /// Short copy suitable for SnackBars / InlineErrorCard.
  String get userMessage => message;

  bool get isNetworkish =>
      kind == AppErrorKind.networkUnavailable ||
      kind == AppErrorKind.timeout ||
      kind == AppErrorKind.connectionRequired;

  factory AppException.validation(
    String message, {
    String? code,
    Map<String, dynamic> details = const {},
  }) {
    return AppException(
      kind: AppErrorKind.validation,
      message: message,
      code: code ?? 'GOAL_VALIDATION_ERROR',
      statusCode: 400,
      details: details,
    );
  }

  factory AppException.unauthorized([String? message]) {
    return AppException(
      kind: AppErrorKind.unauthorized,
      message: message ?? 'Sign in is required to continue.',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  factory AppException.forbidden([String? message]) {
    return AppException(
      kind: AppErrorKind.forbidden,
      message: message ?? 'You do not have access to this goal.',
      code: 'OWNERSHIP_FORBIDDEN',
      statusCode: 403,
    );
  }

  factory AppException.notFound([String? message]) {
    return AppException(
      kind: AppErrorKind.notFound,
      message: message ?? 'That goal could not be found.',
      code: 'RESOURCE_NOT_FOUND',
      statusCode: 404,
    );
  }

  factory AppException.conflict([String? message]) {
    return AppException(
      kind: AppErrorKind.conflict,
      message: message ?? 'This change conflicts with the current state.',
      code: 'CONFLICT',
      statusCode: 409,
    );
  }

  factory AppException.networkUnavailable([String? message]) {
    return AppException(
      kind: AppErrorKind.networkUnavailable,
      message:
          message ??
          'Network unavailable. Check your connection and try again.',
      code: 'NETWORK_UNAVAILABLE',
    );
  }

  factory AppException.timeout([String? message]) {
    return AppException(
      kind: AppErrorKind.timeout,
      message: message ?? 'The request timed out. Please try again.',
      code: 'TIMEOUT',
    );
  }

  factory AppException.serverFailure([String? message]) {
    return AppException(
      kind: AppErrorKind.serverFailure,
      message:
          message ?? 'Something went wrong on the server. Try again later.',
      code: 'INTERNAL_ERROR',
      statusCode: 500,
    );
  }

  factory AppException.connectionRequired([String? message]) {
    return AppException(
      kind: AppErrorKind.connectionRequired,
      message:
          message ??
          'Connection required. This change cannot be saved while offline.',
      code: 'CONNECTION_REQUIRED',
    );
  }

  factory AppException.unknown([String? message]) {
    return AppException(
      kind: AppErrorKind.unknown,
      message: message ?? 'Something went wrong. Please try again.',
      code: 'UNKNOWN',
    );
  }

  @override
  String toString() => 'AppException($kind): $message';
}

/// Maps any thrown object to a user-facing string (never Dio/stack dumps).
String userFacingErrorMessage(Object error) {
  if (error is AppException) return error.userMessage;
  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }
  if (text.startsWith('Bad state: ')) {
    return text.substring('Bad state: '.length);
  }
  return 'Something went wrong. Please try again.';
}
