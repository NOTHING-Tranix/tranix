import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranix_app/core/config/app_config.dart';
import 'package:tranix_app/core/network/mock_interceptor.dart';
import 'package:tranix_app/core/providers.dart';

/// Reads a fixture from `assets/mock/` on disk.
Future<String> diskFixture(String name) => File('assets/mock/$name').readAsString();

Future<dynamic> fixtureJson(String name) async => jsonDecode(await diskFixture(name));

/// Overrides for a mock-mode app in widget tests: no latency, fixtures preloaded (real file I/O does not
/// complete inside testWidgets' fake async zone), always online.
Future<List<Override>> mockAppOverrides({Map<String, String> patch = const {}}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final fixtures = {
    for (final f in Directory('assets/mock').listSync().whereType<File>())
      f.uri.pathSegments.last: f.readAsStringSync(),
    ...patch,
  };
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    appConfigProvider.overrideWithValue(
      const AppConfig(apiBaseUrl: 'http://mock/api/v1', useMock: true, env: AppEnv.dev),
    ),
    mockInterceptorProvider.overrideWithValue(
      MockInterceptor(loader: (name) async => fixtures[name]!, latency: Duration.zero),
    ),
    offlineProvider.overrideWith((ref) => Stream.value(false)),
  ];
}
