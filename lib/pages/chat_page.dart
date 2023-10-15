import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'conversation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> users = [];

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    List<Map<String, dynamic>> userData = [];
    final currentUser = auth.currentUser;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').get();

    snapshot.docs.forEach((doc) {
      // Exclude the current user by comparing user IDs
      if (doc.id != currentUser.uid) {
        userData.add(doc.data());
      }
    });

    return userData;
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetUsers();
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
                    // Navigate to the conversation page when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationPage(user: user),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipOval(
                      child: hasAvatar
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              width: 50, // Adjust the size as needed
                              height: 50,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error, // Placeholder when an error occurs
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
                        Text(
                          user['userName'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Lottie.asset(
                          'lib/images/pink.json',
                          animate: true,
                          height: 20,
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
