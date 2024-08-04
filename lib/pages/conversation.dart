import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/pages/call_page.dart';
import 'package:muffins_happy_place/services/chat_service.dart';
import 'package:muffins_happy_place/services/notification_service.dart';
import 'package:muffins_happy_place/services/signaling_service.dart';
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
  Signaling signaling = Signaling();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  bool isCalling = false;

  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  void sendMessage(String senderId, String receiverId, String content,
      MessageKind type) async {
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

  Future<void> initiateVideoCall(String roomId) async {
    setState(() {
      isCalling = true;
    });

    String callerName = currentUser!.displayName ?? 'Unknown Caller';

    // Fetch receiver's FCM token
    DocumentSnapshot userDoc =
        await _firestore.collection("UserTokens").doc(widget.user['uid']).get();
    String receiverToken = userDoc['token'];

    // Send video call notification
    _notificationService.sendVideoCallNotification(
        receiverToken, roomId, callerName);

    // Navigate to the video call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          roomId: roomId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    remoteRenderer.initialize();
    signaling.onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
      setState(() {});
    });
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
                builder: (BuildContext dialogContext) => CupertinoActionSheet(
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: const Text('Video Call'),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Setting up video call...'),
                                ],
                              ),
                            );
                          },
                        );

                        try {
                          Navigator.pop(context); // Dismiss the loading dialog
                          String roomId =
                              await signaling.createRoom(remoteRenderer);

                          initiateVideoCall(roomId);
                        } catch (e) {
                          // Handle any errors that might occur during navigation
                          print("Error during navigation: $e");
                          // Optionally, show an error message to the user
                          // You can also dismiss the loading dialog here if an error occurs
                          Navigator.pop(context); // Dismiss the loading dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                    'Failed to set up video call. Please try again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Dismiss the error dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: const Text('Voice Call'),
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your logic for 'Option 2' here
                      },
                    ),
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
            padding: const EdgeInsets.all(10),
            child: isCalling ? _buildCallingText() : _buildUserInput(),
          ),
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
  Widget _buildCallingText() {
    return Center(
      child: Text(
        'Calling...',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = currentUser!.uid;
    int? lastMessageHour;
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
            final showDateChip =
                shouldShowDateChip(currentDate, lastMessageHour);

            if (showDateChip) {
              hourMarkers.add(currentDate);
            }

            lastMessageHour = currentDate.hour;

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

  bool shouldShowDateChip(DateTime currentDate, int? lastMessageHour) {
    if (lastMessageHour == null) {
      return true;
    }
    return currentDate.hour != lastMessageHour;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
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
                ),
              ),
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
                MessageKind.text,
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
