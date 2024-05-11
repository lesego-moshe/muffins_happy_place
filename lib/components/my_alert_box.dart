import 'package:flutter/material.dart';

class MyAlertBox extends StatelessWidget {
  final controller;
  final String hintText;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const MyAlertBox(
      {Key? key,
      required this.controller,
      required this.onSave,
      required this.onCancel,
      required this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: controller,
        cursorColor: Colors.grey,
        style: TextStyle(color: Colors.pink.shade100),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pinkAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pink.shade100),
            )),
      ),
      actions: [
        MaterialButton(
          onPressed: onCancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        MaterialButton(
          onPressed: onSave,
          child: Text(
            'Save',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        )
      ],
    );
  }
}
