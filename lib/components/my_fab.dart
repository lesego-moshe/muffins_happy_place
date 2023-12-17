import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final Function() onPressed;
  const MyFloatingActionButton({Key key, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.pink.shade100,
      onPressed: onPressed,
      child: Icon(CupertinoIcons.add),
    );
  }
}
