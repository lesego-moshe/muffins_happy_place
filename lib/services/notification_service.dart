import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:muffins_happy_place/pages/call_page.dart';

import '../constants.dart';

class NotificationService {
  final currentUser = FirebaseAuth.instance.currentUser;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  String? mtoken = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("UserTokens")
        .doc(currentUser!.uid)
        .set({'token': token});
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mtoken = token;
      print('My token is $mtoken');

      saveToken(token!);
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse? response) {
      try {
        if (response != null &&
            response.payload != null &&
            response.payload!.isEmpty) {
        } else {}
      } catch (e) {
        return;
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('..............onMessage..........');
      print(
          'onMessage: ${message.notification?.title}/${message.notification?.body}');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContentTitle: true);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'muffinshappyplace',
        'muffinshappyplace',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: true,
        fullScreenIntent: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('id_1', 'Reply'),
        ],
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data['body'],
      );
    });
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': body,
                'title': title,
              },
              "notification": <String, dynamic>{
                "title": title,
                "body": body,
                "android_channel_id": "muffinshappyplace"
              },
              "to": token,
            },
          ));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void sendVideoCallNotification(
      String token, String roomId, String callerName) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'room_id': roomId,
                'caller_name': callerName,
                'type': 'video_call',
              },
              "notification": <String, dynamic>{
                "title": "Incoming Video Call",
                "body": "$callerName is calling you",
                "android_channel_id": "muffinshappyplace"
              },
              "to": token,
            },
          ));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> showIncomingCall(
      String uuid, String handle, String callerName) async {
    CallKitParams params = CallKitParams(
      id: uuid,
      nameCaller: callerName,
      handle: handle,
      type: 0, // Video call type
      duration: 30000, // Duration in milliseconds
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{'userId': handle},
      headers: <String, dynamic>{'apiKey': 'Abc@123!'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowCallID: true,
        isShowFullLockedScreen: true,
        ringtonePath: 'system_ringtone_default',
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  void handleIncomingCall(BuildContext context, Map<String, dynamic> data) {
    final roomId = data['room_id'];
    final callerName = data['caller_name'];

    showIncomingCall(roomId, currentUser!.uid, callerName);

    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(roomId: roomId),
            ),
          );
          break;
        case Event.actionCallDecline:
          Navigator.pop(context);
          break;
        default:
          break;
      }
    });
  }
}
