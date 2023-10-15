import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/my_textfield.dart';

class UploadSongPage extends StatefulWidget {
  @override
  _UploadSongPageState createState() => _UploadSongPageState();
}

class _UploadSongPageState extends State<UploadSongPage> {
  final CollectionReference songCollection =
      FirebaseFirestore.instance.collection('songs');
  final TextEditingController _songTitleController = TextEditingController();
  final TextEditingController _songUrlController = TextEditingController();
  final TextEditingController _songMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.pink.shade100),
        backgroundColor: Colors.transparent,
        title: Text(
          'Upload Song',
          style: TextStyle(color: Colors.pink.shade100),
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          MyTextField(
              controller: _songTitleController,
              hintText: "Song Title",
              obscureText: false),
          const SizedBox(
            height: 15,
          ),
          MyTextField(
              controller: _songUrlController,
              hintText: "Song URL",
              obscureText: false),
          const SizedBox(
            height: 15,
          ),
          MyTextField(
              controller: _songMessageController,
              hintText: "Why did you dedicate this song?",
              obscureText: false),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.pink.shade100),
            ),
            onPressed: () async {
              await songCollection.add({
                'title': _songTitleController.text,
                'url': _songUrlController.text,
                'message': _songMessageController.text
              });
              Navigator.pop(context);
            },
            child: const Text('Upload Song'),
          ),
        ],
      ),
    );
  }
}
