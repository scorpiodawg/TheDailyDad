import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_daily_dad/models/daily_data.dart';
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';

class CacheService {
  static const String _cacheKey = 'daily_data_cache';

  Future<void> cacheDailyData(DailyData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data.toJson());
    await prefs.setString(_cacheKey, jsonString);
  }

  Future<DailyData?> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString != null) {
      return DailyData.fromJson(json.decode(jsonString));
    }
    return null;
  }
}
