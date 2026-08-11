import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/identity_auth_gateway.dart';

final identityAuthGatewayProvider = Provider<IdentityAuthGateway>((ref) {
  return FakeIdentityAuthGateway();
});
