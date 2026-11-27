/// Build-time configuration from `--dart-define` (A-004).
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1   # emulator → local backend
/// flutter run --dart-define=USE_MOCK=true                               # no backend
/// flutter build apk --flavor prod --dart-define=ENV=prod --dart-define=API_BASE_URL=https://…
/// ```
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useMock,
    required this.env,
  });

  /// Values compiled into this build.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://13.204.64.25:8080/api/v1',
      ),
      useMock: const bool.fromEnvironment('USE_MOCK'),
      env: AppEnv.parse(
        const String.fromEnvironment('ENV', defaultValue: 'dev'),
      ),
    );
  }

  final String apiBaseUrl;
  final bool useMock;
  final AppEnv env;

  bool get isProd => env == AppEnv.prod;
}

enum AppEnv {
  dev,
  staging,
  prod;

  static AppEnv parse(String value) => AppEnv.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AppEnv.dev,
  );
}
