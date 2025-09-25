import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_daily_dad/models/daily_data.dart';

class CacheService {
  final _log = Logger('CacheService');
  static const String _cacheKey = 'daily_data_cache';

  Future<void> cacheDailyData(DailyData data) async {
    _log.info('Caching data for date: ${data.date}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data.toJson());
      await prefs.setString(_cacheKey, jsonString);
      _log.fine('Successfully cached data.');
    } catch (e) {
      _log.severe('Error caching data: $e');
      rethrow;
    }
  }

  Future<DailyData?> getCachedData() async {
    _log.info('Attempting to retrieve cached data.');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString != null) {
        _log.fine('Found cached data.');
        return DailyData.fromJson(json.decode(jsonString));
      }
      _log.info('No cached data found.');
      return null;
    } catch (e) {
      _log.severe('Error retrieving cached data: $e');
      rethrow;
    }
  }
}
