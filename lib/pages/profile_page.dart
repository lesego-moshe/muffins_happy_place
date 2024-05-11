import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/pages/calendar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sizer/sizer.dart';

import '../models/user.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Edit $field"),
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(newValue),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ));

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser!.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              myData = CurrentUser.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);

              return AnimationLimiter(
                child: SingleChildScrollView(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, right: 18),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 0.0, top: 0),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                child: TextButton(
                                  onPressed: () {
                                    //                                       isfromProfiletrepData = true;
                                    //                                       Navigator.push(
                                    // context,
                                    // PageTransition(
                                    //     type: PageTransitionType.fade,
                                    //     child: editProfileTrep(isFromProfile: true,),
                                    //     curve: Curves.easeInOutCubicEmphasized,
                                    //     duration: Duration(milliseconds: 900)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 23.w,
                                          height: 23.w,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(50)),
                                            color: Colors.white,
                                          ),
                                          child: ClipOval(
                                            child: myData.userAvatar != ''
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        myData.userAvatar!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Center(
                                                    child: Material(
                                                      type: MaterialType
                                                          .transparency,
                                                      child: Text(
                                                        myData.firstName![0]
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .pinkAccent,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 10),
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: 40.w),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    myData.firstName!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.white),
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(10),
                                                            ),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            return Container(
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                    child: Text(
                                                                      "Yay! You are someone important🩷",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            30,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .pink
                                                                            .shade200,
                                                                        fontFamily:
                                                                            'SF-Bold',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Lottie.asset(
                                                                      'lib/images/surprise.json',
                                                                      height:
                                                                          200,
                                                                      repeat:
                                                                          false
                                                                      // animate: false,
                                                                      ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Text(
                                                                    myData.firstName ==
                                                                            'Tisetso'
                                                                        ? "You are verified because your man created this application. I love you babe😚❤️"
                                                                        : "You are verified because you created this application(Shocking)",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'SF-Bold',
                                                                      fontSize:
                                                                          3.5.w,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Visibility(
                                                        visible: myData
                                                                    .firstName ==
                                                                'Lesego' ||
                                                            myData.firstName ==
                                                                'Tisetso',
                                                        child: Icon(
                                                          Icons.verified,
                                                          color:
                                                              Colors.pinkAccent,
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: 40.w),
                                              child: Text(
                                                FirebaseAuth.instance
                                                    .currentUser!.email!,
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //NumbersWidget2(),
                        //NumbersWidget2(), //buildAbout(doc),
                        SettingsList(
                          lightTheme: SettingsThemeData(
                              settingsSectionBackground:
                                  const Color(0xFFEFEFF4).withOpacity(0.6),
                              settingsListBackground: CupertinoColors.white),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          platform: DevicePlatform.iOS,
                          sections: [
                            SettingsSection(
                              title: Text('General',
                                  style: TextStyle(
                                      color: Colors.pink.shade100,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold)),
                              tiles: <SettingsTile>[
                                SettingsTile.navigation(
                                  onPressed: (BuildContext context) async {
                                    //                                                  Navigator.push(
                                    // context,
                                    // PageTransition(
                                    //   childCurrent: EntrepreneurProfile(),
                                    //     ctx: context,
                                    //     type: PageTransitionType.rightToLeftJoined,
                                    //     child: Account(),
                                    //     curve: Curves.easeInOutCubicEmphasized,
                                    //     duration: Duration(milliseconds: 900)));
                                  },
                                  leading: Icon(
                                    Icons.person,
                                    color: Colors.pink.shade100,
                                  ),
                                  title: Text('Account',
                                      style: TextStyle(
                                          color: Colors.pink.shade100,
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold)),
                                  value: const Text('Privacy'),
                                ),
                                SettingsTile.navigation(
                                  onPressed: (BuildContext context) async {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            childCurrent: const ProfilePage(),
                                            ctx: context,
                                            type: PageTransitionType
                                                .rightToLeftJoined,
                                            child: const Calendar(),
                                            curve:
                                                Curves.easeInOutCubicEmphasized,
                                            duration: const Duration(
                                                milliseconds: 900)));
                                  },
                                  leading: Icon(
                                    CupertinoIcons.calendar,
                                    color: Colors.pink.shade100,
                                  ),
                                  title: Text('Calendar',
                                      style: TextStyle(
                                          color: Colors.pink.shade100,
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold)),
                                  value: const Text('Events'),
                                ),
                                SettingsTile.navigation(
                                  onPressed: (BuildContext context) async {
                                    final screenHeight =
                                        MediaQuery.of(context).size.height;
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return AlertDialog(
                                          title: const Text(
                                            "Logout",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                              "Are you sure you wish to logout? You'll have to manually sign in next time.",
                                              style:
                                                  TextStyle(fontSize: 3.5.w)),
                                          actions: <Widget>[
                                            // usually buttons at the bottom of the dialog
                                            new ElevatedButton(
                                              child: new Text("Close"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            new ElevatedButton(
                                              child: new Text(
                                                "Yes, I'm sure",
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await FirebaseAuth.instance
                                                    .signOut();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  leading: Icon(
                                    Icons.exit_to_app_rounded,
                                    color: Colors.pink.shade100,
                                  ),
                                  title: const Text(
                                    'Logout',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'SF',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            // SettingsSection(
                            //   title: Text('Feedback',
                            //       style: TextStyle(
                            //           color: Colors.pink.shade100,
                            //           fontFamily: 'SF',
                            //           fontWeight: FontWeight.bold)),
                            //   tiles: <SettingsTile>[
                            //     SettingsTile.navigation(
                            //       onPressed: (BuildContext context) async {
                            //         //                                                  Navigator.push(
                            //         // context,
                            //         // PageTransition(
                            //         //     type: PageTransitionType.fade,
                            //         //     child: SendFeedBack(),
                            //         //     curve: Curves.easeInOutCubicEmphasized,
                            //         //     duration: Duration(milliseconds: 500)));
                            //       },
                            //       leading: Icon(
                            //         CupertinoIcons
                            //             .bubble_left_bubble_right_fill,
                            //         color: Colors.pink.shade100,
                            //       ),
                            //       title: Text('Send Feedback'),
                            //       // value: Text('Privacy'),
                            //     ),
                            //     SettingsTile.navigation(
                            //       onPressed: (BuildContext context) async {
                            //         //                                                Navigator.push(
                            //         // context,
                            //         // PageTransition(
                            //         //     type: PageTransitionType.fade,
                            //         //     child: ReportBug(),
                            //         //     curve: Curves.easeInOutCubicEmphasized,
                            //         //     duration: Duration(milliseconds: 500)));
                            //       },
                            //       leading: Icon(
                            //         Icons.bug_report_rounded,
                            //         color: Colors.black,
                            //       ),
                            //       title: Text('Report A Bug'),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Lottie.asset(
                          'lib/images/dandelion3.json',
                        ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleMedium
                            // .copyWith(color: Colors.black.withOpacity(0.5)),
                            ,
                            children: <TextSpan>[
                              const TextSpan(text: 'Made with love by '),
                              TextSpan(
                                text: 'LESEGO MOSHE',
                                style: TextStyle(
                                    fontFamily: "SF-Bold",
                                    fontSize: 4.1.w,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.pink.shade100),
                              ),
                              TextSpan(
                                text: ".",
                                style: TextStyle(
                                  fontFamily: "SF-Bold",
                                  fontSize: 4.6.w,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }

            return Center(
              child: Lottie.asset(
                'lib/images/loading.json',
                height: 200,
              ),
            );
          },
        ),
      ),
    );
  }
}

class IconWidget extends StatefulWidget {
  IconWidget({this.icon, this.color});
  final IconData? icon;
  final Color? color;
  @override
  _IconWidgetState createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
      ),
      child: Icon(
        widget.icon,
        color: Colors.white,
      ),
    );
  }
}
