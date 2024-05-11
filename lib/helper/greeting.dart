import 'package:flutter/material.dart';
import 'dart:async';

String getGreeting(DateTime currentTime) {
  int hour = currentTime.hour;

  if (hour >= 0 && hour < 12) {
    return "Good Morning";
  } else if (hour >= 12 && hour < 17) {
    return "Good Afternoon";
  } else {
    return "Good Evening";
  }
}

class GreetingWidget extends StatefulWidget {
  @override
  _GreetingWidgetState createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget>
    with WidgetsBindingObserver {
  String greeting = '';
  late Timer timer;

  @override
  void initState() {
    super.initState();
    greeting = getGreeting(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startTimer();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      timer.cancel();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      setState(() {
        greeting = getGreeting(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      greeting,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
