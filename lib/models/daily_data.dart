import 'package:the_daily_dad/models/factoid.dart';
import 'package:the_daily_dad/models/joke.dart';
import 'package:the_daily_dad/models/news_item.dart';

class DailyData {
  final String date;
  final List<NewsItem> newsItems;
  final List<Joke> jokes;
  final List<Factoid> factoids;

  DailyData({
    required this.date,
    required this.newsItems,
    required this.jokes,
    required this.factoids,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      date: json['date'],
      newsItems: (json['newsItems'] as List).map((i) => NewsItem.fromJson(i)).toList(),
      jokes: (json['jokes'] as List).map((i) => Joke.fromJson(i)).toList(),
      factoids: (json['factoids'] as List).map((i) => Factoid.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'newsItems': newsItems.map((i) => i.toJson()).toList(),
      'jokes': jokes.map((i) => i.toJson()).toList(),
      'factoids': factoids.map((i) => i.toJson()).toList(),
    };
  }
}
