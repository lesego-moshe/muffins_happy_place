import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChip extends StatelessWidget {
  final DateTime date;
  final Color color;

  DateChip({
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String chipText = getChipText(date);
    String formattedTime = DateFormat.jm().format(date); // Format time

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chipText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 5),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String getChipText(DateTime date) {
    DateTime now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    } else if (isSameDay(date, now.subtract(Duration(days: 1)))) {
      return 'Yesterday';
    } else if (now.difference(date).inDays <= 6) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
