class NewsItem {
  final String title;
  final String description;
  final String link;

  NewsItem({required this.title, required this.description, required this.link});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      description: json['description'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
    };
  }
}
