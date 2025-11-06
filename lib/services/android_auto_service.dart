import 'package:flutter/services.dart';
import 'package:the_daily_dad/models/daily_data.dart';
import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/models/quote.dart';
import 'package:the_daily_dad/models/trivia_item.dart';

class AndroidAutoService {
    static const MethodChannel _channel = MethodChannel('cx.iio.the_daily_dad/auto_media');

    /// Updates Android Auto with the current daily data
    static Future<void> updateDailyData(DailyData data) async {
        try {
            print('AndroidAutoService: Updating daily data - News: ${data.newsItems.length}, Jokes: ${data.jokes.length}, Factoids: ${data.factoids.length}, Quotes: ${data.quotes.length}, Trivia: ${data.triviaItems.length}');

            // Send news items
            await _channel.invokeMethod('setNewsItems',
                data.newsItems.map((item) => item.toJson()).toList());
            print('AndroidAutoService: News items sent');

            // Send jokes
            await _channel.invokeMethod('setJokes',
                data.jokes.map((item) => item.toJson()).toList());
            print('AndroidAutoService: Jokes sent');

            // Send factoids
            await _channel.invokeMethod('setFactoids',
                data.factoids.map((item) => item.toJson()).toList());
            print('AndroidAutoService: Factoids sent');

            // Send quotes
            await _channel.invokeMethod('setQuotes',
                data.quotes.map((item) => item.toJson()).toList());
            print('AndroidAutoService: Quotes sent');

            // Send trivia
            await _channel.invokeMethod('setTrivia',
                data.triviaItems.map((item) => item.toJson()).toList());
            print('AndroidAutoService: Trivia sent');
        } catch (e) {
            print('AndroidAutoService: Error updating data - $e');
            // Silently fail if Android Auto is not available (e.g., on iOS or when not connected)
            // This is expected behavior
        }
    }

    /// Updates Android Auto with individual category data
    static Future<void> updateNewsItems(List<NewsItem> items) async {
        try {
            await _channel.invokeMethod('setNewsItems',
                items.map((item) => item.toJson()).toList());
        } catch (e) {
            // Silently fail if not available
        }
    }

    static Future<void> updateJokes(List<Joke> items) async {
        try {
            await _channel.invokeMethod('setJokes',
                items.map((item) => item.toJson()).toList());
        } catch (e) {
            // Silently fail if not available
        }
    }

    static Future<void> updateFactoids(List<Factoid> items) async {
        try {
            await _channel.invokeMethod('setFactoids',
                items.map((item) => item.toJson()).toList());
        } catch (e) {
            // Silently fail if not available
        }
    }

    static Future<void> updateQuotes(List<Quote> items) async {
        try {
            await _channel.invokeMethod('setQuotes',
                items.map((item) => item.toJson()).toList());
        } catch (e) {
            // Silently fail if not available
        }
    }

    static Future<void> updateTrivia(List<TriviaItem> items) async {
        try {
            await _channel.invokeMethod('setTrivia',
                items.map((item) => item.toJson()).toList());
        } catch (e) {
            // Silently fail if not available
        }
    }
}

