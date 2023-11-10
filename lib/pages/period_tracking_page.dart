import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({Key key}) : super(key: key);

  @override
  _PeriodTrackerScreenState createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  DateTime _selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DateTime> periodDates = [];

  @override
  void initState() {
    super.initState();
    _fetchPeriodDates();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _logPeriodDate() async {
    if (_selectedDate != null) {
      await _firestore.collection('periodDates').add({
        'date': _selectedDate,
      });
      _fetchPeriodDates();
    }
  }

  Future<void> _fetchPeriodDates() async {
    final snapshot = await _firestore.collection('periodDates').get();
    final dates = snapshot.docs
        .map((doc) => (doc.data() as Map)['date'].toDate())
        .toList();
    setState(() {
      periodDates = dates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.pink.shade100),
      ),
      body: const Center(
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Text(
        //       'Selected Date: ${_selectedDate?.toString() ?? 'None'}',
        //     ),
        //     ElevatedButton(
        //       onPressed: () => _selectDate(context),
        //       child: const Text('Select date'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () => _logPeriodDate(),
        //       child: const Text('Log Period Date'),
        //     ),
        //     if (periodDates.isNotEmpty)
        //       Text(
        //         'Next Period Date: ${_calculateNextPeriodDate()?.toString() ?? 'N/A'}',
        //       ),
        //     if (periodDates.isNotEmpty)
        //       Text(
        //         'Fertility Window: ${_calculateFertilityWindow()?.toString() ?? 'N/A'}',
        //       ),
        //   ],

        // ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "I need this page to work as expected. Maybe that will mend my shattered heart 🫤. When did I write this? I am consumed by agony and the endless void of emptiness and despair",
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  DateTime _calculateNextPeriodDate() {
    if (periodDates.isEmpty) {
      return null;
    }
    final lastPeriodDate = periodDates.last;
    final cycleLength = 28; // Replace with your actual cycle length
    return lastPeriodDate.add(Duration(days: cycleLength));
  }

  DateTime _calculateFertilityWindow() {
    final nextPeriodDate = _calculateNextPeriodDate();
    return nextPeriodDate != null
        ? nextPeriodDate.subtract(const Duration(days: 14))
        : null;
  }
}
