import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_daily_dad/models/trivia_item.dart';
import 'package:the_daily_dad/providers/daily_data_provider.dart';

class TriviaItemWidget extends StatelessWidget {
  final TriviaItem item;
  final int index;

  const TriviaItemWidget({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyDataProvider>(context, listen: false);

    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(item.question)),
          if (item.revealed)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: item.correctAnswer ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        if (!item.revealed) {
          provider.revealTriviaAnswer(index);
        }
      },
    );
  }
}
