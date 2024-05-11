import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/services/chat_service.dart';
import 'package:muffins_happy_place/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:swipe_to/swipe_to.dart';

import '../components/date_chip.dart';
import '../components/message_bubble.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Message> onSwipedMessage;

  const ConversationPage(
      {Key? key, required this.user, required this.onSwipedMessage})
      : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isRecordingAudio = false;
  late String audioFilePath;
  late Message replyMessage;
  FocusNode focusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  NotificationService _notificationService = NotificationService();

  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  void sendMessage(String senderId, String receiverId, String content,
      MessageType type) async {
    final message = Message(
      senderId: senderId,
      receiverId: widget.user['uid'],
      content: content,
      type: type,
      timestamp: Timestamp.now(),
    );

    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'content': message.content,
      'type': message.type.toString(),
      'timestamp': message.timestamp,
    });
  }

  @override
  void initState() {
    super.initState();
    _notificationService.initInfo();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
        title: Text(
          widget.user['userName'].toString(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.videocam,
              color: Colors.white,
            ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: const Text('Video Call'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your logic for 'Option 1' here
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: const Text('Voice Call'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your logic for 'Option 2' here
                      },
                    ),
                    // Add more options here
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Container(
              padding: const EdgeInsets.all(10), child: _buildUserInput()),
        ],
      ),
    );
  }

  bool isNewDay(int index, List<DocumentSnapshot> messages) {
    if (index == 0) {
      return true;
    }

    final currentMessageDate = messages[index]['timestamp'].toDate();
    final previousMessageDate = messages[index - 1]['timestamp'].toDate();

    return currentMessageDate.day != previousMessageDate.day;
  }

  void onSwipedMessage(Message message) {
    replyToMessage(message);
    focusNode.requestFocus();
  }

  void replyToMessage(Message message) {
    setState(() {
      replyMessage = message;
    });
  }

  // void selectMessage(int index) {
  //   setState(() {
  //     selectedMessageIndex = index;
  //   });
  // }

  // void clearSelectedMessage() {
  //   setState(() {
  //     selectedMessageIndex = -1;
  //   });
  // }

  Widget _buildMessageList() {
    String senderId = currentUser!.uid;
    List<DateTime> hourMarkers = [];
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(senderId, widget.user['uid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset('lib/images/loading.json', height: 250),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final currentDate = data['timestamp'].toDate();
            final showDateChip = shouldShowDateChip(currentDate, hourMarkers);

            if (showDateChip) {
              hourMarkers.add(currentDate);
            }

            return Column(
              children: [
                if (showDateChip)
                  DateChip(
                    date: currentDate,
                    color: Colors.transparent,
                  ),
                _buildMessageItem(data),
              ],
            );
          },
        );
      },
    );
  }

  bool shouldShowDateChip(DateTime currentDate, List<DateTime> hourMarkers) {
    for (DateTime hourMarker in hourMarkers) {
      if (currentDate.hour == hourMarker.hour) {
        if (currentDate.minute >= hourMarker.minute) {
          return false;
        }
      }
    }
    return true;
  }

  Widget _buildMessageItem(Map<String, dynamic> data) {
    bool isCurrentUser = data['senderId'] == currentUser!.uid;
    return MessageBubble(
      text: data['content'],
      isSender: isCurrentUser,
      onTap: () {},
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.add_circled_solid),
          color: Colors.pink.shade100,
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text(
                      'Camera Image',
                      style: TextStyle(color: Colors.pink.shade300),
                    ),
                    onPressed: () async {
                      final pickedImage = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      // Do something with the picked image here
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Text(
                      'Camera Video',
                      style: TextStyle(color: Colors.pink.shade300),
                    ),
                    onPressed: () async {
                      final pickedVideo = await ImagePicker()
                          .pickVideo(source: ImageSource.camera);
                      // Do something with the picked video here
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.pink.shade300),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Add your logic for 'Option 2' here
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Text(
                      'Music',
                      style: TextStyle(color: Colors.pink.shade300),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Add your logic for 'Option 2' here
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: Text(
                      'Documents',
                      style: TextStyle(color: Colors.pink.shade300),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Add your logic for 'Option 2' here
                    },
                  ),
                  // Add more options here
                ],
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            focusNode: focusNode,
            cursorColor: Colors.pink.shade100,
            textCapitalization: TextCapitalization.sentences,
            controller: messageController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    CupertinoIcons.waveform,
                    color: Colors.pink.shade100,
                  )),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(500),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(500),
                borderSide: BorderSide(color: Colors.pink.shade100),
              ),
              contentPadding: EdgeInsets.only(left: 3.w),
              fillColor: Colors.white10,
              filled: true,
              hintText: "Start typing...",
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            String newMessage = messageController.text.trim();
            if (newMessage.isNotEmpty) {
              sendMessage(
                currentUser!.uid,
                widget.user['uid'],
                newMessage,
                MessageType.text,
              );
              DocumentSnapshot currentUserTokenDoc = await FirebaseFirestore
                  .instance
                  .collection("UserTokens")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();

              String? currentUserToken =
                  (currentUserTokenDoc.data() as Map<String, dynamic>)['token'];

              QuerySnapshot tokensSnapshot = await FirebaseFirestore.instance
                  .collection("UserTokens")
                  .get();

              List<String> tokens = tokensSnapshot.docs
                  .map((doc) =>
                      (doc.data() as Map<String, dynamic>)['token'] as String)
                  .where((token) => token != currentUserToken)
                  .toList();

              DocumentSnapshot currentUserDataDoc = await FirebaseFirestore
                  .instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();
              String currentUserName = (currentUserDataDoc.data()
                  as Map<String, dynamic>)['userName'];
              DocumentSnapshot tokenDoc = await FirebaseFirestore.instance
                  .collection("UserTokens")
                  .doc(widget.user['uid'])
                  .get();

              String receiverToken =
                  (tokenDoc.data() as Map<String, dynamic>)['token'];

              _notificationService.sendPushMessage(
                  receiverToken, messageController.text, currentUserName);
            }
            messageController.clear();
            scrollDown();
          },
          icon: Icon(
            CupertinoIcons.arrow_up_circle_fill,
          ),
          color: Colors.pink.shade100,
        ),
      ],
    );
  }
}
