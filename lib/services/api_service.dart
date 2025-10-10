import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/models/quote.dart';
import 'package:the_daily_dad/models/trivia_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:the_daily_dad/models/wikipedia_content.dart';

class ApiService {
  final String _jokesBaseUrl = 'https://icanhazdadjoke.com/';
  final String _newsBaseUrl = 'https://newsapi.org/v2';
  final String _factoidsBaseUrl =
      'https://uselessfacts.jsph.pl/api/v2/facts/random';
  final String _wikipediaBaseUrl =
      'https://api.wikimedia.org/feed/v1/wikipedia/en/featured';
  final String _quotesBaseUrl = 'https://zenquotes.io/api/quotes';
  final String _triviaBaseUrl =
      'https://opentdb.com/api.php?amount=10&type=boolean';
  final String _newsApiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  final String _serpApiKey = dotenv.env['SERP_API_KEY'] ?? '';
  final String _source = dotenv.env['SOURCE'] ?? 'serpapi';

  // Old jokes API -- these don't refresh, same jokes every day
  Future<List<Joke>> fetchJokesOld({int count = 10}) async {
    final response = await http.get(
      Uri.parse('$_jokesBaseUrl/search?limit=$count'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results
          .map((json) => Joke(id: json['id'], joke: json['joke']))
          .toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  // New jokes API -- these refresh every day but are called
  // one at a time
  Future<List<Joke>> fetchJokes({int count = 3}) async {
    List<Joke> jokes = [];
    for (int i = 0; i < count; i++) {
      final response = await http.get(
        Uri.parse(_jokesBaseUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        jokes.add(Joke(id: data['id'], joke: data['joke']));
      }
    }
    return jokes;
  }

  Future<List<NewsItem>> fetchNews() async {
    if (_source == 'serpapi') {
      return _fetchNewsFromSerpApi();
    } else {
      return _fetchNewsFromNewsApi();
    }
  }

  Future<List<NewsItem>> _fetchNewsFromSerpApi() async {
    final response = await http.get(
      Uri.parse(
          'https://serpapi.com/search?engine=google_news&gl=us&topic_token=CAAqJggKIiBDQkFTRWdvSUwyMHZNRFZxYUdjU0FtVnVHZ0pWVXlnQVAB&api_key=$_serpApiKey'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> newsResults = data['news_results'];
      final List<NewsItem> allStories = [];

      for (var result in newsResults) {
        if (result['highlight'] != null) {
          final story = result['highlight'];
          if (story == null) {
            print('Warning: Encountered null story in news results');
            continue;
          }
          final title = story['title'] ?? '(unavailable)';
          final source = story['source']?['name'] ?? '';
          final snippet = story['snippet'] ?? '';
          final description =
              source.isNotEmpty ? '$snippet ($source)' : snippet;
          allStories.add(NewsItem(
              title: title, description: description, link: story['link']));
        }
      }

      return allStories.take(5).toList();
    } else {
      throw Exception('Failed to load news from SerpApi');
    }
  }

  Future<List<NewsItem>> _fetchNewsFromNewsApi() async {
    final response = await http.get(
      Uri.parse(
          '$_newsBaseUrl/top-headlines?country=us&pageSize=3&apiKey=$_newsApiKey'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      return articles
          .where((json) => json['title'] != null && json['url'] != null)
          .map((json) => NewsItem(
              title: json['title'],
              description: json['description'] ?? '',
              link: json['url']))
          .toList();
    } else {
      throw Exception('Failed to load news from NewsAPI');
    }
  }

  Future<List<Factoid>> fetchFactoids({int count = 3}) async {
    List<Factoid> factoids = [];
    for (int i = 0; i < count; i++) {
      final response = await http.get(
        Uri.parse(_factoidsBaseUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        factoids.add(Factoid(fact: data['text']));
      } else {
        throw Exception('Failed to load factoids');
      }
    }
    return factoids;
  }

  Future<WikipediaContent> fetchWikipediaFeaturedContent() async {
    final today = DateFormat('yyyy/MM/dd').format(DateTime.now());
    final response = await http.get(Uri.parse('$_wikipediaBaseUrl/$today'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tfa =
          data['tfa'] != null ? FeaturedArticle.fromJson(data['tfa']) : null;
      final onThisDay = data['onthisday'] is List
          ? (data['onthisday'] as List)
              .map((item) => OnThisDayEvent.fromJson(item))
              .toList()
          : <OnThisDayEvent>[];

      return WikipediaContent(tfa: tfa, onThisDay: onThisDay);
    } else {
      throw Exception('Failed to load Wikipedia featured content');
    }
  }

  Future<List<Quote>> fetchQuotes() async {
    final response = await http.get(Uri.parse(_quotesBaseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  Future<List<TriviaItem>> fetchTrivia() async {
    final response = await http.get(Uri.parse(_triviaBaseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        final List<dynamic> results = data['results'];
        return results.map((json) => TriviaItem.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load trivia');
  }
}
