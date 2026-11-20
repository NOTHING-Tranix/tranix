import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/settings.dart';
import 'network/interceptors.dart';
import 'providers.dart';

/// `GET /settings/public` — charges, timers and dropdown lists (CLAUDE.md rule 10). Cached for the app's life.
final publicSettingsProvider = FutureProvider<PublicSettings>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await guardApi(() => dio.get<Map<String, dynamic>>('/settings/public'));
  return PublicSettings.fromJson(res.data!);
});
