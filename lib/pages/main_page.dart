import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/services/weather_service.dart';

import '../models/weather_model.dart';

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
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weather?.cityName ?? "Loading Area...",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.pink.shade200),
                  ),
                  Lottie.asset(
                      getWeatherAnimation(_weather?.mainCondition, isDayTime()),
                      height: 100),
                  Text(
                    '${_weather?.temperature?.round()}°C' ??
                        "Loading Temperature...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.pink.shade200,
                    ),
                  ),
                  Text(
                    _weather?.mainCondition ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.pink.shade200),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
