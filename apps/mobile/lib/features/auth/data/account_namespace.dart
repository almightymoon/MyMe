import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Stable, non-reversible directory fragment for an account.
String accountStorageNamespace(String accountId) {
  return sha256
      .convert(utf8.encode('memy.acct.$accountId'))
      .toString()
      .substring(0, 16);
}
