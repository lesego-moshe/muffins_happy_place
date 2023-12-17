import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/services/weather_service.dart';

import '../models/weather_model.dart';
import 'habit_tracker_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _weatherService = WeatherService('72d5ccce062fdde85cb5049924aab18d');
  Weather _weather;
  bool isDayTime() {
    int hour = DateTime.now().hour;
    return hour > 6 && hour < 20;
  }

  final _controller = ConfettiController();
  bool isPlaying = false;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  String getWeatherAnimation(String mainCondition, bool isDayTime) {
    if (mainCondition == null) return 'lib/images/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'lib/images/cloudy.json';
      case 'rain':
      case 'drizzle':
        return isDayTime
            ? 'lib/images/rainwithsun.json'
            : 'lib/images/rainynight.json';
      case 'thunderstorm':
        return 'lib/images/thunderstorm.json';
      case 'clear':
        return isDayTime
            ? 'lib/images/sunny.json'
            : 'lib/images/clearnight.json';
      default:
        return 'lib/images/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

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
        child: SafeArea(
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weather?.cityName ?? "Loading Area...",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.pink.shade200),
                  ),
                  Lottie.asset(
                      getWeatherAnimation(_weather?.mainCondition, isDayTime()),
                      height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_weather?.temperature?.round()}°C' ??
                            "Loading Temperature...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.pink.shade200,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        _weather?.mainCondition ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.pink.shade200),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
                child: Divider(
                  height: 3,
                  thickness: 2,
                  color: Colors.pink.shade100,
                ),
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink.shade100),
                    ),
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink.shade100),
                    ),
                    width: 150,
                    height: 160,
                    child: Column(
                      children: [
                        const Text(
                          "Muffin's",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                        const Text('Status'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0),
                              child: LottieBuilder.asset(
                                'lib/images/sleeping.json',
                                height: 110,
                              ),
                            ),
                            Image.asset(
                              'lib/images/left.png',
                              height: 50,
                            )
                          ],
                        ),
                        const Text(
                          'Sleeping',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink.shade100),
                    ),
                    width: 150,
                    height: 160,
                    child: Column(
                      children: [
                        const Text(
                          "Baby's",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                        const Text('Status'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'lib/images/right.png',
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 13),
                              child: LottieBuilder.asset(
                                'lib/images/eating.json',
                                height: 110,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Eating',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HabitTrackerPage()));
                }),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  width: 90,
                  height: 90,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Habit Tracker",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent),
                      ),
                      Image.asset(
                        'lib/images/h.png',
                        height: 60,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
