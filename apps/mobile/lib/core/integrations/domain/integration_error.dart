import 'integration_provider.dart';

/// Stable, provider-agnostic failure reasons for integrations.
enum IntegrationErrorCode {
  /// Platform integration is not available on this device.
  unavailable,

  /// User (or OS) denied the permission required to sync.
  permissionDenied,

  /// The platform does not support this integration at all.
  notSupported,

  /// Transient I/O / plugin-channel failure — safe to retry.
  transient,

  /// The requested external resource (calendar/event) no longer exists.
  notFound,

  /// The write conflicted with a concurrent external change.
  conflict,

  /// The user cancelled an interactive step (e.g. permission dialog).
  cancelled,

  /// Anything else.
  unknown,
}

/// Typed error for integration (calendar/health/…) failures.
///
/// [message] must already be safe to log/display: never pass raw event
/// titles, notes, attendee names, or health sample values into it. Use
/// [IntegrationLogSanitizer] to build any string derived from user content.
class IntegrationError implements Exception {
  const IntegrationError({
    required this.provider,
    required this.code,
    required this.message,
    this.cause,
  });

  final IntegrationProvider provider;
  final IntegrationErrorCode code;
  final String message;
  final Object? cause;

  bool get isRetryable =>
      code == IntegrationErrorCode.transient ||
      code == IntegrationErrorCode.unavailable;

  factory IntegrationError.permissionDenied(
    IntegrationProvider provider, [
    String? message,
  ]) {
    return IntegrationError(
      provider: provider,
      code: IntegrationErrorCode.permissionDenied,
      message: message ?? 'Permission was not granted.',
    );
  }

  factory IntegrationError.unavailable(
    IntegrationProvider provider, [
    String? message,
  ]) {
    return IntegrationError(
      provider: provider,
      code: IntegrationErrorCode.unavailable,
      message: message ?? 'This integration is unavailable right now.',
    );
  }

  factory IntegrationError.notFound(
    IntegrationProvider provider, [
    String? message,
  ]) {
    return IntegrationError(
      provider: provider,
      code: IntegrationErrorCode.notFound,
      message: message ?? 'The requested item could not be found.',
    );
  }

  factory IntegrationError.unknown(
    IntegrationProvider provider, [
    String? message,
    Object? cause,
  ]) {
    return IntegrationError(
      provider: provider,
      code: IntegrationErrorCode.unknown,
      message: message ?? 'Something went wrong. Please try again.',
      cause: cause,
    );
  }

  @override
  String toString() =>
      'IntegrationError(${provider.name}, ${code.name}): $message';
}
