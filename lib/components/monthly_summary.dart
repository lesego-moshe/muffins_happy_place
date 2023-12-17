import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../datetime/date_time.dart';

class MonthlySummary extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final String startDate;

  const MonthlySummary(
      {Key key, @required this.datasets, @required this.startDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: HeatMap(
        startDate: createDateTimeObject(startDate),
        endDate: DateTime.now().add(const Duration(days: 0)),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200],
        textColor: Colors.black45,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        colorsets: const {
          1: Color.fromARGB(20, 233, 30, 99),
          2: Color.fromARGB(40, 233, 30, 99),
          3: Color.fromARGB(60, 233, 30, 99),
          4: Color.fromARGB(80, 233, 30, 99),
          5: Color.fromARGB(100, 233, 30, 99),
          6: Color.fromARGB(120, 233, 30, 99),
          7: Color.fromARGB(150, 233, 30, 99),
          8: Color.fromARGB(180, 233, 30, 99),
          9: Color.fromARGB(220, 233, 30, 99),
          10: Color.fromARGB(255, 233, 30, 99),
        },
        onClick: (value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
              'Yay! You did something',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.pink.shade300,
          ));
        },
      ),
    );
  }
}
