import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IdentifySongPage extends StatefulWidget {
  const IdentifySongPage({Key? key}) : super(key: key);

  @override
  State<IdentifySongPage> createState() => _IdentifySongPageState();
}

class _IdentifySongPageState extends State<IdentifySongPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AvatarGlow(
          duration: const Duration(milliseconds: 2000),
          glowColor: Colors.pink.shade100,
          child: Lottie.asset(
            'lib/images/listening.json',
            height: 400,
          ),
        ),
      ),
    );
  }
}
