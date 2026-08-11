/// Prefixes every persistent key with the authenticated account id.
class AccountLocalStore {
  const AccountLocalStore(this.accountId);

  final String? accountId;

  String key(String base) {
    final id = accountId;
    if (id == null || id.isEmpty) return base;
    return 'memy.acct.$id.$base';
  }

  static const String legacyUnownedMarker = 'memy.legacy.unowned.v1';
}

class DeviceIdStore {
  static const String key = 'memy.device.id.v1';
}
