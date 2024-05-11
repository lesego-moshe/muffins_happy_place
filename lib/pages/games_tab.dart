import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GamesTab extends StatefulWidget {
  const GamesTab({Key? key}) : super(key: key);

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Lottie.asset('lib/images/working.json'),
          ),
          const Center(
            child: Text(
              'I still have to learn how to make games but they will be coming soon. I could not find an animation of a person coding, hence I used the guy painting',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
