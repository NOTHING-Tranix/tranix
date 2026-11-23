import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/models/enums.dart';
import 'config/app_config.dart';
import 'network/interceptors.dart';
import 'network/mock_interceptor.dart';
import 'session/session_controller.dart';
import 'storage/token_store.dart';

/// Build-time config; tests override it.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// Initialised in `main()` and overridden there (and in tests).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return ref.watch(appConfigProvider).useMock ? InMemoryTokenStore() : SecureTokenStore();
});

final mockInterceptorProvider = Provider<MockInterceptor>((ref) => MockInterceptor());

/// App language (D-12). Stored locally; sent as `Accept-Language` and later to `PUT /me`.
class LanguageController extends Notifier<Language> {
  static const _key = 'tranix.language';

  @override
  Language build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return Language.values.where((l) => l.name == saved).firstOrNull ?? Language.en;
  }

  /// Whether the user picked a language on the welcome screen (first open).
  bool get chosen => ref.read(sharedPreferencesProvider).containsKey(_key);

  Future<void> set(Language language) async {
    await ref.read(sharedPreferencesProvider).setString(_key, language.name);
    state = language;
  }
}

final languageProvider = NotifierProvider<LanguageController, Language>(LanguageController.new);

/// Testing builds can point at another server (e.g. an ngrok tunnel) without reinstalling; saved on the phone.
/// Production builds always use the compiled address.
class ServerUrlController extends Notifier<String> {
  static const _key = 'tranix.server_url';

  @override
  String build() {
    final config = ref.watch(appConfigProvider);
    if (config.isProd || config.useMock) return config.apiBaseUrl;
    return ref.watch(sharedPreferencesProvider).getString(_key) ?? config.apiBaseUrl;
  }

  /// Accepts a host (`abc.ngrok-free.dev`), a base URL or a full API URL; empty = back to the built-in address.
  Future<void> set(String input) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final url = normalizeServerUrl(input);
    if (url == null) {
      await prefs.remove(_key);
      state = ref.read(appConfigProvider).apiBaseUrl;
    } else {
      await prefs.setString(_key, url);
      state = url;
    }
  }
}

final serverUrlProvider = NotifierProvider<ServerUrlController, String>(ServerUrlController.new);

String? normalizeServerUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  if (!s.startsWith('http://') && !s.startsWith('https://')) s = 'https://$s';
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  if (!s.endsWith('/api/v1')) s = '$s/api/v1';
  return s;
}

BaseOptions _options(String baseUrl) => BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      // ngrok free tunnels show a browser warning page unless this header is sent
      headers: const {'ngrok-skip-browser-warning': 'true'},
    );

/// The API client. Interceptor order (architecture.md): Mock (when USE_MOCK, answers first) → Language → Auth →
/// Refresh → Error.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokens = ref.watch(tokenStoreProvider);
  final baseUrl = ref.watch(serverUrlProvider);
  final dio = Dio(_options(baseUrl));
  final refreshDio = Dio(_options(baseUrl));
  if (config.useMock) {
    final mock = ref.watch(mockInterceptorProvider);
    dio.interceptors.add(mock);
    refreshDio.interceptors.add(mock);
  }
  dio.interceptors.addAll([
    LanguageInterceptor(() => ref.read(languageProvider).name),
    AuthInterceptor(tokens),
    RefreshInterceptor(
      dio: dio,
      refreshDio: refreshDio,
      tokens: tokens,
      onSessionExpired: () => ref.read(sessionProvider.notifier).onSessionExpired(),
    ),
    ErrorInterceptor(),
  ]);
  return dio;
});

/// True while the device has no network (drives `OfflineBanner`).
final offlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool isOffline(List<ConnectivityResult> r) => r.isEmpty || r.every((c) => c == ConnectivityResult.none);
  yield isOffline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isOffline);
});
