import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _jokesBaseUrl = 'https://icanhazdadjoke.com/';
  final String _newsBaseUrl = 'https://newsapi.org/v2';
  final String _factoidsBaseUrl = 'https://uselessfacts.jsph.pl/api/v2/facts/random';
  final String _newsApiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  Future<List<Joke>> fetchJokes({int count = 10}) async {
    final response = await http.get(
      Uri.parse('$_jokesBaseUrl/search?limit=$count'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Joke(id: json['id'], joke: json['joke'])).toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(
      Uri.parse('$_newsBaseUrl/top-headlines?country=us&pageSize=3&apiKey=$_newsApiKey'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      return articles.map((json) => NewsItem(title: json['title'], description: json['description'] ?? '')).toList();
    } else {
      throw Exception('Failed to load news');
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
}
