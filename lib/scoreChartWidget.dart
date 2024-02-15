import 'package:charts_flutter_new/flutter.dart';
import 'package:flutter/material.dart';

class ScoreChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scores;

  const ScoreChartWidget(this.scores, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Series<Map<String, dynamic>, String>> seriesList = [
      Series<Map<String, dynamic>, String>(
        id: 'Scores',
        data: scores
            .where(
                (score) => score['clients'][0]['email'] == 'dima123@gmail.com')
            .toList(),
        domainFn: (score, _) => score['text'],
        measureFn: (score, _) => score['score'],
        labelAccessorFn: (score, _) => '${score['score']}',
      ),
    ];

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 200,
            child: BarChart(
              seriesList,
            ),
          ))
    ]);
  }
}
