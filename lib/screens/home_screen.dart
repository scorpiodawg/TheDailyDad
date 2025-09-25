import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Daily Dad'),
      ),
      body: Consumer<DailyDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.newsItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchDailyData(forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expandedIndex = isExpanded ? index : -1;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text(
                          'News',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.newsItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.newsItems[index];
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          onTap: () async {
                            final uri = Uri.parse(item.link);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        );
                      },
                    ),
                    isExpanded: _expandedIndex == 0,
                  ),
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text(
                          'Jokes',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.jokes.length,
                      itemBuilder: (context, index) {
                        final item = provider.jokes[index];
                        return ListTile(
                          title: Text(item.joke),
                        );
                      },
                    ),
                    isExpanded: _expandedIndex == 1,
                  ),
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text(
                          'Factoids',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.factoids.length,
                      itemBuilder: (context, index) {
                        final item = provider.factoids[index];
                        return ListTile(
                          title: Text(item.fact),
                        );
                      },
                    ),
                    isExpanded: _expandedIndex == 2,
                  ),
                  if (provider.wikipediaContent != null)
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          title: Text(
                            'Wikipedia',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (provider.wikipediaContent!.tfa != null)
                            _buildWikipediaSection(
                              context,
                              'Featured Article',
                              [provider.wikipediaContent!.tfa!],
                            ),
                          if (provider.wikipediaContent!.onThisDay.isNotEmpty)
                            _buildWikipediaSection(
                              context,
                              'On This Day',
                              provider.wikipediaContent!.onThisDay
                                  .expand((e) => [
                                        Text(e.text,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        ...e.articles
                                      ])
                                  .take(5)
                                  .toList(),
                            ),
                        ],
                      ),
                      isExpanded: _expandedIndex == 3,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWikipediaSection(
      BuildContext context, String title, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          ...items.map((item) {
            if (item is Text) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: item,
              );
            }
            if (item is NewsItem) {
              return ListTile(
                title: Text(item.title),
                subtitle: Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final uri = Uri.parse(item.link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }
}
