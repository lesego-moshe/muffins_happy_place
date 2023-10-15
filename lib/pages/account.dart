import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:muffins_happy_place/pages/register_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  const Account({Key key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Account',
          style: TextStyle(
              color: Colors.black,
              fontFamily: "SF-Bold",
              fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(children: [
        SettingsList(
          lightTheme: SettingsThemeData(
              settingsSectionBackground:
                  CupertinoColors.extraLightBackgroundGray.withOpacity(0.6),
              settingsListBackground: CupertinoColors.white),
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              title: Text('Manage Account',
                  style: TextStyle(
                      color: CupertinoColors.darkBackgroundGray,
                      fontFamily: 'SF',
                      fontWeight: FontWeight.bold)),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  onPressed: (BuildContext context) async {
                    const url =
                        "https://www.freeprivacypolicy.com/live/ac15444f-c1fd-4e7d-a2ae-1264417c860d";
                    if (canLaunchUrl(Uri.parse(url)) != null)
                      await launchUrl(Uri.parse(url));
                    else
                      // can't launch url, there is some error
                      throw "Could not launch $url";
                  },
                  leading: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  title: Text('Privacy',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF',
                          fontWeight: FontWeight.bold)),
                  value: Text(''),
                ),
                SettingsTile.navigation(
                  onPressed: (BuildContext context) async {
                    final screenHeight = MediaQuery.of(context).size.height;

                    Navigator.push(
                        context,
                        PageTransition(
                            childCurrent: Account(),
                            ctx: context,
                            fullscreenDialog: true,
                            type: PageTransitionType.bottomToTopJoined,
                            child: RegisterPage(),
                            curve: Curves.easeInOutCubicEmphasized,
                            duration: Duration(milliseconds: 900)));
                  },
                  leading: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete Account',
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'SF',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
