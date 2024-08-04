import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:muffins_happy_place/pages/auth_page.dart';
import 'package:sizer/sizer.dart';

Future<void> _firebaseMesagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  _showIncomingCall(message);
}

void _showIncomingCall(RemoteMessage message) {
  final data = message.data;
  final roomId = data['roomId'];

  if (roomId != null) {
    final params = <String, dynamic>{
      'id': 'unique_call_id',
      'nameCaller': 'Caller Name',
      'handle': roomId,
      'type': 0,
      'duration': 30000,
      'textAccept': 'Accept',
      'textDecline': 'Decline',
      'extra': <String, dynamic>{},
      'headers': <String, dynamic>{},
      'ios': <String, dynamic>{
        'iconName': 'CallKitIcon',
        'handleType': 'generic'
      },
      'android': <String, dynamic>{
        'isCustomNotification': true,
        'isShowLogo': false,
        'isShowCallback': true,
        'isShowMissedCallNotification': true,
        'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        'background': 'background_image_name',
        'actionColor': '#4CAF50'
      },
    };
    FlutterCallkitIncoming.showCallkitIncoming(params as CallKitParams);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox("Habit_Database");
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMesagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      );
    });
  }
}
