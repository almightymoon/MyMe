import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared controls for all fake/demo repository implementations.
///
/// Mutable so widget tests can toggle empty/failure modes and Retry flows.
class FakeRepositoryConfig {
  FakeRepositoryConfig({
    this.delay = const Duration(milliseconds: 350),
    this.forceEmpty = false,
    this.forceFailure = false,
    this.failureMessage = 'Unable to load demo data.',
  });

  Duration delay;
  bool forceEmpty;
  bool forceFailure;
  String failureMessage;
}

class FakeRepositoryException implements Exception {
  FakeRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

final fakeRepositoryConfigProvider = Provider<FakeRepositoryConfig>((ref) {
  return FakeRepositoryConfig();
});

/// Applies artificial delay and empty/failure modes used by fake repositories.
Future<T> runFakeFetch<T>({
  required FakeRepositoryConfig config,
  required T Function() onData,
  required T Function() onEmpty,
}) async {
  await Future<void>.delayed(config.delay);
  if (config.forceFailure) {
    throw FakeRepositoryException(config.failureMessage);
  }
  if (config.forceEmpty) {
    return onEmpty();
  }
  return onData();
}
