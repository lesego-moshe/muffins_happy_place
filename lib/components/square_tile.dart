import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function() onTap;
  const SquareTile({@required this.imagePath, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
          //borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Container(
          child: Image.asset(
            imagePath,
            height: 6.w,
          ),
        ),
      ),
    );
  }
}
