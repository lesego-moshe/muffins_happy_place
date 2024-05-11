import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final bool isSender;

  final Function? onLongPress;
  final Function onTap;

  MessageBubble({
    required this.text,
    required this.isSender,
    required this.onTap,
    this.onLongPress,
  });

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isPressed = false;

  void _onLongPress() {
    setState(() {
      isPressed = true;
    });
  }

  void _onTap() {
    if (isPressed) {
      setState(() {
        isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isPressed) {
          setState(() {
            isPressed = false;
          });
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onLongPress: _onLongPress,
        onTap: _onTap,
        child: Align(
          alignment:
              widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: BubbleSpecialThree(
            isSender: widget.isSender,
            text: widget.text,
            color: widget.isSender ? Colors.pink.shade100 : Colors.white,
            textStyle: TextStyle(
              color: widget.isSender ? Colors.white : Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
