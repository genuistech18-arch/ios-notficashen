import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _activeCodeKey = 'registered_code';
  static const _allCodesKey = 'all_registered_codes';

  final FlutterSecureStorage _storage;

  LocalStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Save active code and add to list without erasing previous codes
  Future<void> saveCode(String code) async {
    final codes = await getRegisteredCodes();
    if (!codes.contains(code)) {
      codes.add(code);
    }
    await _storage.write(key: _allCodesKey, value: jsonEncode(codes));
    await _storage.write(key: _activeCodeKey, value: code);
  }

  Future<String?> getCode() => _storage.read(key: _activeCodeKey);

  Future<List<String>> getRegisteredCodes() async {
    final raw = await _storage.read(key: _allCodesKey);
    final active = await getCode();
    
    List<String> result = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        result = list.cast<String>();
      } catch (_) {}
    }

    if (active != null && !result.contains(active)) {
      result.add(active);
    }

    return result;
  }

  Future<void> setActiveCode(String code) async {
    await _storage.write(key: _activeCodeKey, value: code);
  }

  Future<void> removeCode(String code) async {
    final codes = await getRegisteredCodes();
    codes.remove(code);
    await _storage.write(key: _allCodesKey, value: jsonEncode(codes));

    final active = await getCode();
    if (active == code) {
      if (codes.isNotEmpty) {
        await setActiveCode(codes.first);
      } else {
        await _storage.delete(key: _activeCodeKey);
      }
    }
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _activeCodeKey);
    await _storage.delete(key: _allCodesKey);
  }

  Future<void> clearCode() => clearAll();
}
