import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/components/my_button.dart';
import 'package:muffins_happy_place/services/authentication.dart';

import 'unlocked_media_page.dart';

class MemoriesTab extends StatefulWidget {
  const MemoriesTab({Key? key}) : super(key: key);

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 250,
            ),
            Lottie.asset('lib/images/animation_dog.json', height: 100),
            const Text(
              "There is some really private stuff here😉",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            MyButton(
                onTap: () async {
                  bool auth = await Authentication.authentication();
                  if (auth) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnlockedMediaPage(),
                      ),
                    );
                  }
                },
                text: "Entice me!")
          ],
        ),
      ),
    );
  }
}
