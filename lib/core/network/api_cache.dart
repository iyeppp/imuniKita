import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../constants/app_constants.dart';

/// Service cache lokal berbasis Hive CE untuk menyimpan respons REST API (B8-8).
class ApiCache {
  ApiCache([Box<String>? box]) : _boxOverride = box;

  final Box<String>? _boxOverride;

  Future<Box<String>> get _box async {
    if (_boxOverride != null && _boxOverride.isOpen) {
      return _boxOverride;
    }
    if (Hive.isBoxOpen(AppConstants.apiCacheBox)) {
      return Hive.box<String>(AppConstants.apiCacheBox);
    }
    return Hive.openBox<String>(AppConstants.apiCacheBox);
  }

  /// Membaca data cache jika belum kedaluwarsa (default TTL 24 jam).
  Future<Map<String, dynamic>? /*Map<String, dynamic>?*/ > get(
    String key, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    try {
      final box = await _box;
      final raw = box.get(key);
      if (raw == null) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final fetchedAtStr = decoded['_cachedAt'] as String?;
      if (fetchedAtStr == null) return null;

      final fetchedAt = DateTime.parse(fetchedAtStr);
      if (DateTime.now().difference(fetchedAt) > ttl) {
        await box.delete(key);
        return null;
      }

      return decoded['payload'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan payload JSON ke cache.
  Future<void> put(String key, Map<String, dynamic> payload) async {
    try {
      final box = await _box;
      final wrapper = {
        '_cachedAt': DateTime.now().toIso8601String(),
        'payload': payload,
      };
      await box.put(key, jsonEncode(wrapper));
    } catch (_) {}
  }
}
