import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../data/profile_api.dart';

/// Fresh `GET /me`; also updates the session's cached Me.
final meProvider = FutureProvider.autoDispose<Me>((ref) async {
  final me = await ref.watch(profileApiProvider).me();
  ref.read(sessionProvider.notifier).updateMe(me);
  return me;
});

final verificationProvider = FutureProvider.autoDispose<VerificationInfo>(
  (ref) => ref.watch(profileApiProvider).verification(),
);

final addressProvider = FutureProvider.autoDispose<Address?>((ref) => ref.watch(profileApiProvider).address());

final roleProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(profileApiProvider).roleProfile(),
);

/// Refreshes everything the profile screens show after a change.
void refreshProfile(WidgetRef ref) {
  ref.invalidate(meProvider);
  ref.invalidate(verificationProvider);
}
