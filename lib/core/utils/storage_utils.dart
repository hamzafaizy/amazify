// lib/utils/storage_utils.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Box names (Hive)
class _Boxes {
  static const String app = 'app_box'; // small flags/settings
  static const String cart = 'cart_box'; // key: productId, value: json string
  static const String wishlist = 'wishlist_box'; // key: productId, value: true
  static const String cache =
      'cache_box'; // key: cacheKey, value: json string (+meta)
}

/// Secure keys (flutter_secure_storage)
class _SecureKeys {
  static const String accessToken = 'auth_access_token';
  static const String refreshToken = 'auth_refresh_token';
  static const String userPII = 'user_pii'; // if you persist any PII blob
}

/// A tiny, typed cache envelope with optional TTL.
class _CacheEnvelope {
  final dynamic data;
  final int? expiresAtMillis; // epoch ms

  _CacheEnvelope({required this.data, this.expiresAtMillis});

  Map<String, dynamic> toMap() => {'data': data, 'exp': expiresAtMillis};

  static _CacheEnvelope fromMap(Map<String, dynamic> map) => _CacheEnvelope(
    data: map['data'],
    expiresAtMillis: map['exp'] is int ? map['exp'] as int : null,
  );

  bool get isExpired {
    if (expiresAtMillis == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= expiresAtMillis!;
  }
}

/// Storage facade used across the app.
/// - Hive for fast local storage
/// - flutter_secure_storage for sensitive values
class StorageUtils {
  StorageUtils._();

  static final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static bool _initialized = false;

  /// Call this once during app startup (e.g., before runApp).
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(_Boxes.app),
      Hive.openBox<String>(_Boxes.cart),
      Hive.openBox<bool>(_Boxes.wishlist),
      Hive.openBox<String>(_Boxes.cache),
    ]);
    _initialized = true;
  }

  // ─────────────── SECURE STORAGE (TOKENS/PII) ───────────────

  static Future<void> saveAccessToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secure.delete(key: _SecureKeys.accessToken);
    } else {
      await _secure.write(key: _SecureKeys.accessToken, value: token);
    }
  }

  static Future<String?> readAccessToken() =>
      _secure.read(key: _SecureKeys.accessToken);

  static Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secure.delete(key: _SecureKeys.refreshToken);
    } else {
      await _secure.write(key: _SecureKeys.refreshToken, value: token);
    }
  }

  static Future<String?> readRefreshToken() =>
      _secure.read(key: _SecureKeys.refreshToken);

  /// Save any sensitive JSON blob securely
  static Future<void> saveSensitiveJson(
    String key,
    Map<String, dynamic>? json,
  ) => json == null
      ? _secure.delete(key: key)
      : _secure.write(key: key, value: jsonEncode(json));

  static Future<Map<String, dynamic>?> readSensitiveJson(String key) async {
    final v = await _secure.read(key: key);
    if (v == null) return null;
    return jsonDecode(v) as Map<String, dynamic>;
  }

  // ─────────────── GENERIC (APP BOX) ───────────────

  static Box<String> get _appBox => Hive.box<String>(_Boxes.app);

  /// Save a small string value (flags/settings). For objects, use setJson.
  static Future<void> setString(String key, String value) =>
      _appBox.put(key, value);

  static String? getString(String key, {String? orElse}) =>
      _appBox.get(key, defaultValue: orElse);

  /// Persist a small json-serializable object as string.
  static Future<void> setJson(String key, Map<String, dynamic> map) =>
      _appBox.put(key, jsonEncode(map));

  static Map<String, dynamic>? getJson(String key) {
    final raw = _appBox.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> remove(String key) => _appBox.delete(key);

  // ─────────────── CART ───────────────
  // Stores line items by productId. Value is JSON string for flexibility.

  static Box<String> get _cartBox => Hive.box<String>(_Boxes.cart);

  /// Upsert a line item.
  /// [itemJson] should be a JSON-serializable map (id, qty, price, variants...)
  static Future<void> upsertCartItem({
    required String productId,
    required Map<String, dynamic> itemJson,
  }) async {
    await _cartBox.put(productId, jsonEncode(itemJson));
  }

  /// Read a line item, null if not present.
  static Map<String, dynamic>? getCartItem(String productId) {
    final raw = _cartBox.get(productId);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Return all cart items as a list of maps.
  static List<Map<String, dynamic>> getAllCartItems() {
    return _cartBox.values
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList(growable: false);
  }

  static Future<void> removeCartItem(String productId) =>
      _cartBox.delete(productId);

  static Future<void> clearCart() => _cartBox.clear();

  // ─────────────── WISHLIST ───────────────
  // Key-only storage: productId -> true

  static Box<bool> get _wishlistBox => Hive.box<bool>(_Boxes.wishlist);

  static Future<void> addToWishlist(String productId) =>
      _wishlistBox.put(productId, true);

  static Future<void> removeFromWishlist(String productId) =>
      _wishlistBox.delete(productId);

  static bool isInWishlist(String productId) =>
      _wishlistBox.get(productId, defaultValue: false) ?? false;

  static List<String> getWishlistIds() =>
      _wishlistBox.keys.cast<String>().toList(growable: false);

  // ─────────────── CACHE WITH TTL ───────────────
  // For product lists, detail responses, etc. Use a namespaced key like "products:page=1"

  static Box<String> get _cacheBox => Hive.box<String>(_Boxes.cache);

  /// Save cache with optional TTL (in seconds). Store any JSON-serializable content.
  static Future<void> setCache(
    String key,
    dynamic jsonSerializable, {
    int? ttlSeconds,
  }) async {
    final exp = ttlSeconds == null
        ? null
        : DateTime.now()
              .add(Duration(seconds: ttlSeconds))
              .millisecondsSinceEpoch;
    final env = _CacheEnvelope(data: jsonSerializable, expiresAtMillis: exp);
    await _cacheBox.put(key, jsonEncode(env.toMap()));
  }

  /// Read cache; returns `null` if missing or expired.
  static dynamic getCache(String key) {
    final raw = _cacheBox.get(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final env = _CacheEnvelope.fromMap(map);
      if (env.isExpired) {
        // Lazy eviction
        _cacheBox.delete(key);
        return null;
      }
      return env.data;
    } catch (_) {
      // In case previous versions had plain JSON
      try {
        return jsonDecode(raw);
      } catch (e) {
        if (kDebugMode) debugPrint('Cache parse error for $key: $e');
        return null;
      }
    }
  }

  static Future<void> removeCache(String key) => _cacheBox.delete(key);

  static Future<void> clearCache() => _cacheBox.clear();

  // ─────────────── TEARDOWN (optional) ───────────────

  /// Close all boxes (e.g., when logging out completely).
  static Future<void> close() async {
    await Future.wait([
      _cartBox.compact(),
      _wishlistBox.compact(),
      _appBox.compact(),
      _cacheBox.compact(),
    ]);
    await Hive.close();
    _initialized = false;
  }
}
