import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/models/message.dart';
import 'package:muffins_happy_place/services/notification_service.dart';
import 'package:sizer/sizer.dart';

import 'conversation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> users = [];
  NotificationService notificationService = NotificationService();

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    List<Map<String, dynamic>> userData = [];
    final currentUser = auth.currentUser;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    snapshot.docs.forEach((doc) {
      if (doc.id != currentUser!.uid) {
        userData.add(doc.data() as Map<String, dynamic>);
      }
    });

    return userData;
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetUsers();
    notificationService.requestPermission();
    notificationService.getToken();
    notificationService.initInfo();
  }

  Future<void> fetchAndSetUsers() async {
    List<Map<String, dynamic>> fetchedUsers = await fetchUserData();
    setState(() {
      users = fetchedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Chat Page",
          style: TextStyle(color: Colors.pink.shade100),
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Lottie.asset(
                'lib/images/loading.json',
                height: 200,
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                final avatarUrl = user['avatarUrl'] ?? '';
                final hasAvatar = avatarUrl.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationPage(
                          user: user,
                          onSwipedMessage: (Message value) {},
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipOval(
                      child: hasAvatar
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error, //
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  user['firstName'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    title: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <InlineSpan>[
                              TextSpan(
                                text: user['userName'],
                                style: TextStyle(
                                    fontSize: 3.w,
                                    fontFamily: 'SF-Bold',
                                    fontWeight: FontWeight.w500),
                              ),
                              const WidgetSpan(
                                  child: SizedBox(
                                width: 5,
                              )),
                              const WidgetSpan(
                                child: Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text("${user['firstName']} ${user['lastName']}"),
                  ),
                );
              },
            ),
    );
  }
}
