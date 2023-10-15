import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MessageType { text, image, video, document }

class Message {
  final String senderId;
  final String content;
  final MessageType type;
  final Timestamp timestamp;

  Message({
    @required this.senderId,
    @required this.content,
    @required this.type,
    @required this.timestamp,
  });
}

class ChatService extends ChangeNotifier {
  List<Message> messages = [];

  void sendMessage(String senderId, String content, MessageType type) async {
    final message = Message(
      senderId: senderId,
      content: content,
      type: type,
      timestamp: Timestamp.now(),
    );

    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': message.senderId,
      'content': message.content,
      'type': message.type.toString(),
      'timestamp': message.timestamp,
    });

    messages.add(message);
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
