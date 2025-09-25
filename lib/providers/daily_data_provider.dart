import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_daily_dad/contants.dart';
import 'package:the_daily_dad/models/daily_data.dart';
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/models/wikipedia_content.dart';
import 'package:the_daily_dad/services/api_service.dart';
import 'package:the_daily_dad/services/cache_service.dart';

class DailyDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<NewsItem> _newsItems = [];
  List<Joke> _jokes = [];
  List<Factoid> _factoids = [];
  WikipediaContent? _wikipediaContent;
  bool _isLoading = false;

  List<NewsItem> get newsItems => _newsItems;
  List<Joke> get jokes => _jokes;
  List<Factoid> get factoids => _factoids;
  WikipediaContent? get wikipediaContent => _wikipediaContent;
  bool get isLoading => _isLoading;

  DailyDataProvider() {
    fetchDailyData();
  }

  Future<void> fetchDailyData({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (AppConfig.debugMode) {
      // Always force a refresh in debug mode
      forceRefresh = true;
    }

    if (!forceRefresh) {
      final cachedData = await _cacheService.getCachedData();
      if (cachedData != null && cachedData.date == today) {
        _newsItems = cachedData.newsItems;
        _jokes = cachedData.jokes;
        _factoids = cachedData.factoids;
        // Re-fetch Wikipedia content as we don't cache it
        _wikipediaContent = await _apiService.fetchWikipediaFeaturedContent();
      }
    } else {
      final fetchedNews = await _apiService.fetchNews();
      final fetchedJokes = await _getUniqueJokes();
      final fetchedFactoids = await _apiService.fetchFactoids();
      final fetchedWikipediaContent =
          await _apiService.fetchWikipediaFeaturedContent();

      _newsItems = fetchedNews;
      _jokes = fetchedJokes;
      _factoids = fetchedFactoids;
      _wikipediaContent = fetchedWikipediaContent;

      final newData = DailyData(
        date: today,
        newsItems: _newsItems,
        jokes: _jokes,
        factoids: _factoids,
      );
      await _cacheService.cacheDailyData(newData);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Joke>> _getUniqueJokes() async {
    // This is a simplified approach. For a real app, we would persist
    // the list of seen joke IDs.
    final allJokes = await _apiService.fetchJokes(count: 20);
    allJokes.shuffle();
    return allJokes.take(3).toList();
  }
}
