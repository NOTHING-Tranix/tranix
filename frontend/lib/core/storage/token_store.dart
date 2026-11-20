import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredTokens {
  const StoredTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Tokens live only in secure storage (CLAUDE.md rule 4). Never log them.
abstract class TokenStore {
  Future<StoredTokens?> read();

  Future<void> write(StoredTokens tokens);

  Future<void> clear();

  /// Stable per-install id sent at sign-in (architecture: "deviceId generated once").
  Future<String?> readDeviceId();

  Future<void> writeDeviceId(String id);
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _access = 'tranix.accessToken';
  static const _refresh = 'tranix.refreshToken';
  static const _device = 'tranix.deviceId';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredTokens?> read() async {
    final access = await _storage.read(key: _access);
    final refresh = await _storage.read(key: _refresh);
    if (access == null || refresh == null) return null;
    return StoredTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> write(StoredTokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _refresh, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }

  @override
  Future<String?> readDeviceId() => _storage.read(key: _device);

  @override
  Future<void> writeDeviceId(String id) => _storage.write(key: _device, value: id);
}

/// For tests and the mock build.
class InMemoryTokenStore implements TokenStore {
  StoredTokens? _tokens;
  String? _deviceId;

  @override
  Future<StoredTokens?> read() async => _tokens;

  @override
  Future<void> write(StoredTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;

  @override
  Future<String?> readDeviceId() async => _deviceId;

  @override
  Future<void> writeDeviceId(String id) async => _deviceId = id;
}
