import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:muffins_happy_place/models/user.dart';

import 'chat_page.dart';
import 'main_page.dart';
import 'media_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

CurrentUser myData = CurrentUser();

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
    MainPage(),
    ChatPage(),
    MediaPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _navigateBottomBar,
            activeColor: Colors.pink.shade200,
            color: Colors.grey.shade400,
            tabBackgroundColor: Colors.grey.shade200,
            gap: 8,
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: CupertinoIcons.bubble_left_bubble_right,
                text: 'Chat',
              ),
              GButton(
                icon: CupertinoIcons.photo_on_rectangle,
                text: 'Media',
              ),
              GButton(
                icon: CupertinoIcons.person,
                text: 'Profile',
              )
            ],
          ),
        ),
      ),
    );
  }
}
