import 'sync_models.dart';

abstract interface class SyncOutbox {
  List<SyncMutation> pendingFor(String accountId);

  void enqueue(SyncMutation mutation);

  void markAccepted(String mutationId);

  void markState(String mutationId, SyncMutationState state);

  List<SyncMutation> allFor(String accountId);

  void deleteAccount(String accountId);
}
