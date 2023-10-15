import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../components/message_bubble.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ConversationPage({Key key, @required this.user}) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final messageController = TextEditingController();
  List<Message> messages = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isReplying = false;
  ValueNotifier<String> textValueNotifier;
  int selectedMessageIndex = -1;
  final _audioRecorder = Record();
  bool isRecordingAudio = false;
  String audioFilePath;

  void sendMessage(String senderId, String content, MessageType type) {
    final message = Message(
      senderId: senderId,
      content: content,
      type: type,
      timestamp: Timestamp.now(),
    );

    FirebaseFirestore.instance.collection('messages').add({
      'senderId': message.senderId,
      'content': message.content,
      'type': message.type.toString(),
      'timestamp': message.timestamp,
    });

    setState(() {
      messages.add(message);
    });
  }

  @override
  void initState() {
    super.initState();
    textValueNotifier = ValueNotifier<String>(messageController.text);
    messageController.addListener(() {
      textValueNotifier.value = messageController.text;
    });
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final messagesCollection =
        FirebaseFirestore.instance.collection('messages');
    final query = messagesCollection.orderBy('timestamp', descending: false);

    final snapshot = await query.get();
    final List<Message> fetchedMessages = [];

    snapshot.docs.forEach((doc) {
      final data = doc.data();
      final messageType = data['type'] as String;
      MessageType type;
      if (messageType == 'MessageType.text') {
        type = MessageType.text;
      } else if (messageType == 'MessageType.audio') {
        type = MessageType.audio;
      } else if (messageType == 'MessageType.image') {
        type = MessageType.image;
      } else if (messageType == 'MessageType.video') {
        type = MessageType.video;
      } else {
        type = MessageType.document;
      }

      fetchedMessages.add(Message(
        senderId: data['senderId'],
        content: data['content'],
        type: type ?? MessageType.text,
        timestamp: data['timestamp'],
      ));
    });

    setState(() {
      messages = fetchedMessages;
    });
  }

  void selectMessage(int index) {
    setState(() {
      selectedMessageIndex = index;
    });
  }

  void clearSelectedMessage() {
    setState(() {
      selectedMessageIndex = -1;
    });
  }

  bool isNewDay(int currentIndex) {
    if (currentIndex == 0) {
      return true;
    }

    final currentMessageDate = messages[currentIndex].timestamp.toDate();
    final previousMessageDate = messages[currentIndex - 1].timestamp.toDate();

    return currentMessageDate.day != previousMessageDate.day;
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
        title: Text(widget.user['userName'].toString()),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.videocam),
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
                    child: const Text('Cancel'),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        color: Colors.pink.shade100,
        onRefresh: fetchMessages,
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message.senderId == currentUser.uid;
                    final currentDate = message.timestamp.toDate();
                    final showDateChip = isNewDay(index);

                    return Column(
                      children: [
                        if (showDateChip)
                          DateChip(
                            date: currentDate,
                            color: Colors.transparent,
                          ),
                        CupertinoContextMenu(
                          actions: [
                            CupertinoContextMenuAction(
                              onPressed: () {
                                // Handle your context menu option 1
                              },
                              trailingIcon:
                                  CupertinoIcons.arrowshape_turn_up_left,
                              child: const Text('Reply'),
                            ),
                            CupertinoContextMenuAction(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: message.content));
                                Navigator.pop(context);
                              },
                              trailingIcon: CupertinoIcons.doc_on_doc,
                              child: const Text('Copy'),
                            ),
                            if (isSender)
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Delete'),
                                    Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.systemRed,
                                    ),
                                  ],
                                ),
                                onPressed: () {},
                              ),
                          ],
                          child: Material(
                            type: MaterialType.transparency,
                            child: MessageBubble(
                              text: message.content,
                              isSender: isSender,
                              onTap: () {
                                clearSelectedMessage();
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
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
                              child: const Text('Camera Image'),
                              onPressed: () async {
                                final pickedImage = await ImagePicker()
                                    .getImage(source: ImageSource.camera);
                                // Do something with the picked image here
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Camera Video'),
                              onPressed: () async {
                                final pickedVideo = await ImagePicker()
                                    .getVideo(source: ImageSource.camera);
                                // Do something with the picked video here
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Gallery'),
                              onPressed: () {
                                Navigator.pop(context);
                                // Add your logic for 'Option 2' here
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Music'),
                              onPressed: () {
                                Navigator.pop(context);
                                // Add your logic for 'Option 2' here
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Documents'),
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
                    child: ValueListenableBuilder<String>(
                      valueListenable: textValueNotifier,
                      builder:
                          (BuildContext context, String value, Widget child) {
                        if (isRecordingAudio) {
                          // Show the microphone button when recording audio.
                          return IconButton(
                            onPressed: () {
                              // Stop audio recording logic
                              // Set isRecordingAudio to false
                              setState(() {
                                isRecordingAudio = false;
                              });
                            },
                            icon: const Icon(
                              CupertinoIcons.mic,
                            ),
                            color: Colors.pink.shade100,
                          );
                        } else {
                          // Show the text field when not recording audio.
                          return TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: messageController,
                            obscureText: false,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(500),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(500),
                                borderSide:
                                    BorderSide(color: Colors.pink.shade100),
                              ),
                              contentPadding: EdgeInsets.only(left: 3.w),
                              fillColor: Colors.white10,
                              filled: true,
                              hintText: "Start typing...",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              suffixIcon: ValueListenableBuilder<String>(
                                valueListenable: textValueNotifier,
                                builder: (BuildContext context, String value,
                                    Widget child) {
                                  return GestureDetector(
                                    onLongPress: () async {
                                      final dir =
                                          await getApplicationDocumentsDirectory();
                                      final path = '${dir.path}/audio.aac';

                                      if (await _audioRecorder
                                          .hasPermission()) {
                                        // Start audio recording
                                        await _audioRecorder.start(path: path);
                                        // Set isRecordingAudio to true
                                        setState(() {
                                          isRecordingAudio = true;
                                        });
                                      }
                                    },
                                    onLongPressEnd: (details) async {
                                      // Stop audio recording
                                      final path = await _audioRecorder.stop();

                                      // Set isRecordingAudio to false
                                      setState(() {
                                        isRecordingAudio = false;
                                      });

                                      // Save the recorded audio file path
                                      audioFilePath = path;

                                      // Now you can send the recorded audio file as a message
                                      final message = Message(
                                        senderId: currentUser.uid,
                                        content:
                                            audioFilePath, // path of the audio file
                                        type: MessageType.audio,
                                        timestamp: Timestamp.now(),
                                      );

                                      await FirebaseFirestore.instance
                                          .collection('messages')
                                          .add({
                                        'senderId': message.senderId,
                                        'content': message
                                            .content, // this will be the path of the audio file
                                        'type': message.type.toString(),
                                        'timestamp': message.timestamp,
                                      });
                                    },
                                    child: IconButton(
                                      onPressed: () {
                                        String newMessage =
                                            messageController.text;
                                        if (newMessage.isNotEmpty) {
                                          sendMessage(
                                            currentUser.uid,
                                            newMessage,
                                            MessageType.text,
                                          );
                                          messageController.clear();
                                        }
                                      },
                                      icon: Icon(
                                        messageController.text.isNotEmpty
                                            ? CupertinoIcons
                                                .arrow_up_circle_fill
                                            : CupertinoIcons.mic,
                                      ),
                                      color: Colors.pink.shade100,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
