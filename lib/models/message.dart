import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MessageType { text, image, video, audio, document }

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
