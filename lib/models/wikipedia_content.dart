import 'package:the_daily_dad/models/news_item.dart';

class WikipediaContent {
  final FeaturedArticle? tfa;
  final List<OnThisDayEvent> onThisDay;

  WikipediaContent({this.tfa, required this.onThisDay});
}

class FeaturedArticle extends NewsItem {
  FeaturedArticle({
    required super.title,
    required super.description,
    required super.link,
  });

  factory FeaturedArticle.fromJson(Map<String, dynamic> json) {
    return FeaturedArticle(
      title: json['titles']?['normalized'] ?? '',
      description: json['extract'] ?? '',
      link: json['content_urls']?['desktop']?['page'] ?? '',
    );
  }
}

class OnThisDayEvent {
  final String text;
  final List<NewsItem> articles;

  OnThisDayEvent({required this.text, required this.articles});

  factory OnThisDayEvent.fromJson(Map<String, dynamic> json) {
    final List<NewsItem> articles = [];
    if (json['pages'] is List) {
      for (var page in json['pages']) {
        if (page['titles']?['normalized'] != null &&
            page['content_urls']?['desktop']?['page'] != null) {
          articles.add(
            NewsItem(
              title: page['titles']['normalized'],
              description: page['extract'] ?? '',
              link: page['content_urls']['desktop']['page'],
            ),
          );
        }
      }
    }
    return OnThisDayEvent(
      text: json['text'] ?? '',
      articles: articles,
    );
  }
}
