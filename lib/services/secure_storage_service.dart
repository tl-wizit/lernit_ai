import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _trainerModeKey = 'trainer_mode';

  static Future<void> setTrainerMode(bool enabled) async {
    await _storage.write(key: _trainerModeKey, value: enabled ? '1' : '0');
  }

  static Future<bool> getTrainerMode() async {
    final value = await _storage.read(key: _trainerModeKey);
    return value == '1';
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
