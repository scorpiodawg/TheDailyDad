import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';
import 'package:the_daily_dad/utils/color_utils.dart';
import 'package:the_daily_dad/widgets/trivia_item_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _expandedIndex = -1;
  late List<LinearGradient> _gradients;

  @override
  void initState() {
    super.initState();
    _gradients = List.generate(6, (_) => generatePastelGradient());
  }

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

          final panels = _buildPanels(provider);

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
                expandIconColor: Colors.black54,
                children: panels,
              ),
            ),
          );
        },
      ),
    );
  }

  List<ExpansionPanel> _buildPanels(DailyDataProvider provider) {
    final List<ExpansionPanel> panels = [];
    int panelIndex = 0;

    // News Panel
    panels.add(_buildTitledPanel(
      title: 'News',
      body: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.newsItems.length,
        itemBuilder: (context, index) {
          final item = provider.newsItems[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            onTap: () => _launchUrl(item.link),
          );
        },
      ),
      gradient: _gradients[0],
      index: panelIndex++,
    ));

    // Jokes Panel
    panels.add(_buildTitledPanel(
      title: 'Jokes',
      body: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.jokes.length,
        itemBuilder: (context, index) {
          final item = provider.jokes[index];
          return ListTile(
            title: Text('"${item.joke}"'),
          );
        },
      ),
      gradient: _gradients[1],
      index: panelIndex++,
    ));

    // Factoids Panel
    panels.add(_buildTitledPanel(
      title: 'Factoids',
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
      gradient: _gradients[2],
      index: panelIndex++,
    ));

    // Wikipedia Panel
    if (provider.wikipediaContent != null) {
      panels.add(_buildTitledPanel(
        title: 'Wikipedia',
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          ...e.articles
                        ])
                    .take(5)
                    .toList(),
              ),
          ],
        ),
        gradient: _gradients[3],
        index: panelIndex++,
      ));
    }

    // Quotes Panel
    if (provider.quotes.isNotEmpty) {
      panels.add(_buildTitledPanel(
        title: 'Quotes',
        body: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.quotes.length,
          itemBuilder: (context, index) {
            final item = provider.quotes[index];
            return ListTile(
              title: Text('"${item.quote}"'),
              subtitle: Text('- ${item.author}'),
            );
          },
        ),
        gradient: _gradients[4],
        index: panelIndex++,
      ));
    }

    // Trivia Panel
    if (provider.triviaItems.isNotEmpty) {
      panels.add(_buildTitledPanel(
        title: 'Trivia',
        body: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.triviaItems.length,
          itemBuilder: (context, index) {
            return TriviaItemWidget(
              item: provider.triviaItems[index],
              index: index,
            );
          },
        ),
        gradient: _gradients[5],
        index: panelIndex++,
      ));
    }

    return panels;
  }

  ExpansionPanel _buildTitledPanel({
    required String title,
    required Widget body,
    required LinearGradient gradient,
    required int index,
  }) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Container(
          decoration: BoxDecoration(gradient: gradient),
          child: ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      body: body,
      isExpanded: _expandedIndex == index,
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
                onTap: () => _launchUrl(item.link),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
