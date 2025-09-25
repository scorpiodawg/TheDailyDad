import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/models/quote.dart';
import 'package:the_daily_dad/models/trivia_item.dart';
// Wikipedia content is not cached

class DailyData {
  final String date;
  final List<NewsItem> newsItems;
  final List<Joke> jokes;
  final List<Factoid> factoids;
  final List<Quote> quotes;
  final List<TriviaItem> triviaItems;

  DailyData({
    required this.date,
    required this.newsItems,
    required this.jokes,
    required this.factoids,
    required this.quotes,
    required this.triviaItems,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      date: json['date'],
      newsItems:
          (json['newsItems'] as List).map((i) => NewsItem.fromJson(i)).toList(),
      jokes: (json['jokes'] as List).map((i) => Joke.fromJson(i)).toList(),
      factoids:
          (json['factoids'] as List).map((i) => Factoid.fromJson(i)).toList(),
      quotes: (json['quotes'] as List).map((i) => Quote.fromJson(i)).toList(),
      triviaItems: (json['triviaItems'] as List)
          .map((i) => TriviaItem.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'newsItems': newsItems.map((i) => i.toJson()).toList(),
      'jokes': jokes.map((i) => i.toJson()).toList(),
      'factoids': factoids.map((i) => i.toJson()).toList(),
      'quotes': quotes.map((i) => i.toJson()).toList(),
      'triviaItems': triviaItems.map((i) => i.toJson()).toList(),
    };
  }
}
