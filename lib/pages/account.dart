import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muffins_happy_place/pages/register_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:settings_ui/settings_ui.dart';
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
        title: const Text(
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
          icon: const Icon(
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
          physics: const BouncingScrollPhysics(),
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              title: const Text('Manage Account',
                  style: TextStyle(
                      color: CupertinoColors.darkBackgroundGray,
                      fontFamily: 'SF',
                      fontWeight: FontWeight.bold)),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  onPressed: (BuildContext context) async {
                    const url =
                        "https://www.freeprivacypolicy.com/live/ac15444f-c1fd-4e7d-a2ae-1264417c860d";
                    if (canLaunchUrl(Uri.parse(url)) != null) {
                      await launchUrl(Uri.parse(url));
                    } else
                      // can't launch url, there is some error
                      throw "Could not launch $url";
                  },
                  leading: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  title: const Text('Privacy',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF',
                          fontWeight: FontWeight.bold)),
                  value: const Text(''),
                ),
                SettingsTile.navigation(
                  onPressed: (BuildContext context) async {
                    final screenHeight = MediaQuery.of(context).size.height;

                    Navigator.push(
                        context,
                        PageTransition(
                            childCurrent: const Account(),
                            ctx: context,
                            fullscreenDialog: true,
                            type: PageTransitionType.bottomToTopJoined,
                            child: const RegisterPage(),
                            curve: Curves.easeInOutCubicEmphasized,
                            duration: const Duration(milliseconds: 900)));
                  },
                  leading: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
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
