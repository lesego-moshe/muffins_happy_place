import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _controller = ConfettiController();
  bool isPlaying = false;

  String calculateDuration() {
    final startDate = DateTime(2017, 12, 7);
    final now = DateTime.now();

    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += 12;
    }

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }

    return "We Have Been Together for $years Years & $months Months";
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Stack(alignment: Alignment.topCenter, children: [
              GestureDetector(
                onTap: (() {
                  if (isPlaying) {
                    _controller.stop();
                  } else {
                    _controller.play();
                  }

                  isPlaying = !isPlaying;
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20)),
                  width: 500,
                  child: Column(
                    children: [
                      Lottie.asset('lib/images/kissing.json', height: 200),
                      Text(
                        calculateDuration(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.pink.shade200),
                        overflow: TextOverflow.fade,
                        maxLines: null,
                      )
                    ],
                  ),
                ),
              ),
              ConfettiWidget(
                confettiController: _controller,
                blastDirection: -pi / 2,
                colors: [
                  Colors.pink.shade100,
                  Colors.white,
                  Colors.grey.shade300
                ],
              )
            ]),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
