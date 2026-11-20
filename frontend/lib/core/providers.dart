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

BaseOptions _options(AppConfig config) => BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    );

/// The API client. Interceptor order (architecture.md): Mock (when USE_MOCK, answers first) → Language → Auth →
/// Refresh → Error.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokens = ref.watch(tokenStoreProvider);
  final dio = Dio(_options(config));
  final refreshDio = Dio(_options(config));
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
