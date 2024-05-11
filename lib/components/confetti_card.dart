import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConfettiCard extends StatefulWidget {
  const ConfettiCard({Key? key}) : super(key: key);

  @override
  State<ConfettiCard> createState() => _ConfettiCardState();
}

class _ConfettiCardState extends State<ConfettiCard> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Lottie.network(
                "https://lottie.host/9a30ad33-1147-4a92-9073-2484e5a5b7dd/aDOvA4qptg.json"),
            SizedBox(
              width: 5,
            ),
            Text(
              "We Have Been Together for 5 Years & 9 Months",
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
