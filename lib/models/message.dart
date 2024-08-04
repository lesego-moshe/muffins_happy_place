import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageKind { text, image, video, audio, document }

class Message {
  final String senderId;
  final String receiverId;
  final MessageKind type;
  final String content;
  final Timestamp timestamp;
  List<Message>? subMessages;
  bool? isSubMessage;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.content,
      required this.type,
      required this.timestamp,
      this.subMessages,
      this.isSubMessage});

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
      'subMessages': subMessages,
      'isSubMessage': isSubMessage
    };
  }
}
