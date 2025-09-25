import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:the_daily_dad/contants.dart';
import 'package:the_daily_dad/models/daily_data.dart';
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/models/quote.dart';
import 'package:the_daily_dad/models/trivia_item.dart';
import 'package:the_daily_dad/models/wikipedia_content.dart';
import 'package:the_daily_dad/services/api_service.dart';
import 'package:the_daily_dad/services/cache_service.dart';

class DailyDataProvider extends ChangeNotifier {
  final _log = Logger('DailyDataProvider');
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<NewsItem> _newsItems = [];
  List<Joke> _jokes = [];
  List<Factoid> _factoids = [];
  WikipediaContent? _wikipediaContent;
  List<Quote> _quotes = [];
  List<TriviaItem> _triviaItems = [];
  bool _isLoading = false;

  List<NewsItem> get newsItems => _newsItems;
  List<Joke> get jokes => _jokes;
  List<Factoid> get factoids => _factoids;
  WikipediaContent? get wikipediaContent => _wikipediaContent;
  List<Quote> get quotes => _quotes;
  List<TriviaItem> get triviaItems => _triviaItems;
  bool get isLoading => _isLoading;

  DailyDataProvider() {
    fetchDailyData();
  }

  Future<void> fetchDailyData({bool forceRefresh = AppConfig.debugMode}) async {
    _log.info(
        'Fetching daily data. Force refresh: $forceRefresh, isLoading: $_isLoading');
    _isLoading = true;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DailyData? cachedData;

    if (!forceRefresh) {
      cachedData = await _cacheService.getCachedData();
    }

    try {
      if (!forceRefresh && cachedData != null && cachedData.date == today) {
        _log.info('Using cached data for $today.');
        _newsItems = cachedData.newsItems;
        _jokes = cachedData.jokes;
        _factoids = cachedData.factoids;
        // Re-fetch Wikipedia content as we don't cache it
        _log.info('Re-fetching Wikipedia content for cached data.');
        _wikipediaContent = await _apiService.fetchWikipediaFeaturedContent();
        final allQuotes = await _apiService.fetchQuotes();
        allQuotes.shuffle();
        _quotes = allQuotes.take(5).toList();
        final allTrivia = await _apiService.fetchTrivia();
        allTrivia.shuffle();
        _triviaItems = allTrivia.take(5).toList();
      } else {
        if (forceRefresh) {
          _log.info('Forcing refresh, ignoring cache.');
        } else if (cachedData == null) {
          _log.info('No cached data found.');
        } else {
          _log.info(
              'Cached data is stale (date: ${cachedData.date}). Fetching new data.');
        }

        List<NewsItem> fetchedNews = [];
        try {
          fetchedNews = await _apiService.fetchNews();
        } catch (e) {
          _log.warning('Error fetching news: $e');
        }

        List<Joke> fetchedJokes = [];
        try {
          fetchedJokes = await _apiService.fetchJokes(count: 5);
        } catch (e) {
          _log.warning('Error fetching jokes: $e');
        }

        List<Factoid> fetchedFactoids = [];
        try {
          fetchedFactoids = await _apiService.fetchFactoids();
        } catch (e) {
          _log.warning('Error fetching factoids: $e');
        }

        WikipediaContent? fetchedWikipediaContent;
        try {
          fetchedWikipediaContent =
              await _apiService.fetchWikipediaFeaturedContent();
        } catch (e) {
          _log.warning('Error fetching Wikipedia content: $e');
        }

        List<Quote> fetchedQuotes = [];
        try {
          final allQuotes = await _apiService.fetchQuotes();
          allQuotes.shuffle();
          fetchedQuotes = allQuotes.take(5).toList();
        } catch (e) {
          _log.warning('Error fetching quotes: $e');
        }

        List<TriviaItem> fetchedTrivia = [];
        try {
          final allTrivia = await _apiService.fetchTrivia();
          allTrivia.shuffle();
          fetchedTrivia = allTrivia.take(5).toList();
        } catch (e) {
          _log.warning('Error fetching trivia: $e');
        }

        _newsItems = fetchedNews;
        _jokes = fetchedJokes;
        _factoids = fetchedFactoids;
        _wikipediaContent = fetchedWikipediaContent;
        _quotes = fetchedQuotes;
        _triviaItems = fetchedTrivia;

        _log.info('New data fetched. Caching for date: $today.');
        final newData = DailyData(
          date: today,
          newsItems: _newsItems,
          jokes: _jokes,
          factoids: _factoids,
        );
        await _cacheService.cacheDailyData(newData);
      }
    } catch (e) {
      _log.severe('An unrecoverable error occurred during fetchDailyData: $e');
    } finally {
      _isLoading = false;
      _log.info('Finished fetching daily data. Notifying listeners.');
      notifyListeners();
    }
  }

  void revealTriviaAnswer(int index) {
    if (index < _triviaItems.length) {
      _triviaItems[index].revealed = true;
      notifyListeners();
    }
  }
}
