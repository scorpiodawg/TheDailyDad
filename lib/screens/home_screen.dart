import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';

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
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                      title: Text('News'),
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
                      );
                    },
                  ),
                  isExpanded: _expandedIndex == 0,
                ),
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return const ListTile(
                      title: Text('Jokes'),
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
                      title: Text('Factoids'),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
