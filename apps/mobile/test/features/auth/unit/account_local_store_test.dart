import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/auth/data/account_local_store.dart';

void main() {
  test('does not mix keys across accounts', () {
    const userA = AccountLocalStore('user-a');
    const userB = AccountLocalStore('user-b');
    expect(userA.key('memy_goals_v1'), 'memy.acct.user-a.memy_goals_v1');
    expect(userB.key('memy_goals_v1'), 'memy.acct.user-b.memy_goals_v1');
    expect(userA.key('memy_goals_v1'), isNot(userB.key('memy_goals_v1')));
  });

  test('unsigned local data keeps legacy unprefixed keys', () {
    const unsigned = AccountLocalStore(null);
    expect(unsigned.key('memy_goals_v1'), 'memy_goals_v1');
  });
}
