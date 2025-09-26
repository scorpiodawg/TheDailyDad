import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/models/news_item.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';
import 'package:the_daily_dad/utils/color_utils.dart';
import 'package:the_daily_dad/widgets/custom_expansion_panel.dart';
import 'package:the_daily_dad/widgets/trivia_item_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

          return RefreshIndicator(
            onRefresh: () => provider.fetchDailyData(forceRefresh: true),
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: _buildPanels(provider),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPanels(DailyDataProvider provider) {
    final List<Widget> panels = [];
    int panelIndex = 0;

    // News Panel
    if (provider.newsItems.isNotEmpty) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('News'),
        body: _buildListBody(
          items: provider.newsItems,
          itemBuilder: (context, item) => ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            onTap: () => _launchUrl(item.link),
          ),
        ),
      ));
    }

    // Jokes Panel
    if (provider.jokes.isNotEmpty) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('Jokes'),
        body: _buildListBody(
          items: provider.jokes,
          itemBuilder: (context, item) => ListTile(
            title: Text('"${item.joke}"'),
          ),
        ),
      ));
    }

    // Factoids Panel
    if (provider.factoids.isNotEmpty) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('Factoids'),
        body: _buildListBody(
          items: provider.factoids,
          itemBuilder: (context, item) => ListTile(
            title: Text(item.fact),
          ),
        ),
      ));
    }

    // Wikipedia Panel
    if (provider.wikipediaContent != null) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('Wikipedia'),
        body: Column(
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
      ));
    }

    // Quotes Panel
    if (provider.quotes.isNotEmpty) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('Quotes'),
        body: _buildListBody(
          items: provider.quotes,
          itemBuilder: (context, item) => ListTile(
            title: Text('"${item.quote}"'),
            subtitle: Text('- ${item.author}'),
          ),
        ),
      ));
    }

    // Trivia Panel
    if (provider.triviaItems.isNotEmpty) {
      panels.add(CustomExpansionPanel(
        gradient: _gradients[panelIndex++],
        header: _buildHeader('Trivia'),
        body: _buildListBody(
          items: provider.triviaItems,
          itemBuilder: (context, item) {
            final index = provider.triviaItems.indexOf(item);
            return TriviaItemWidget(
              item: item,
              index: index,
            );
          },
        ),
      ));
    }

    return panels;
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildListBody<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item) itemBuilder,
  }) {
    return Column(
      children: items.map((item) => itemBuilder(context, item)).toList(),
    );
  }

  Widget _buildWikipediaSection(
      BuildContext context, String title, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
