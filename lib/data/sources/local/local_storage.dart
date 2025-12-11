import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/config/constants/app_constants.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Onboarding
  Future<bool> setOnboardingCompleted(bool value) async {
    return await _prefs.setBool(AppConstants.isOnboardingCompleted, value);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(AppConstants.isOnboardingCompleted) ?? false;
  }

  // Watchlist
  Future<bool> addToWatchlist(String symbol) async {
    final watchlist = getWatchlist();
    if (!watchlist.contains(symbol)) {
      watchlist.add(symbol);
      return await _prefs.setStringList(AppConstants.watchlistKey, watchlist);
    }
    return true;
  }

  Future<bool> removeFromWatchlist(String symbol) async {
    final watchlist = getWatchlist();
    watchlist.remove(symbol);
    return await _prefs.setStringList(AppConstants.watchlistKey, watchlist);
  }

  List<String> getWatchlist() {
    return _prefs.getStringList(AppConstants.watchlistKey) ?? [];
  }

  bool isInWatchlist(String symbol) {
    return getWatchlist().contains(symbol);
  }

  // Cache management
  Future<bool> saveCache(String key, Map<String, dynamic> data) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await _prefs.setString(key, jsonEncode(cacheData));
  }

  Map<String, dynamic>? getCache(String key) {
    final cacheString = _prefs.getString(key);
    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      
      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) < AppConstants.cacheValidDuration) {
        return cacheData['data'] as Map<String, dynamic>;
      }
      
      // Cache expired
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> clearCache(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clearAllCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    return true;
  }

  // Last sync time
  Future<bool> setLastSyncTime(DateTime time) async {
    return await _prefs.setString(
      AppConstants.lastSyncKey,
      time.toIso8601String(),
    );
  }

  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(AppConstants.lastSyncKey);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }
}

// Provider for local storage
class LocalStorageProvider {
  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }
}
