import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/signaling_service.dart';

class CallPage extends StatefulWidget {
  final String roomId;

  const CallPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
    print('Room ID: ${widget.roomId}');
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    remoteRenderer.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void startPiPMode() {
    PictureInPicture.startPiP(
      pipWidget: PiPWidget(
        child: PiPCapableWidget(
          whileNotInPip: Stack(
            children: [
              Positioned.fill(
                child: RTCVideoView(remoteRenderer, mirror: true),
              ),
              Positioned(
                bottom: 8.0,
                right: 8.0,
                width: 120,
                height: 160,
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ],
          ),
          whileInPip: Stack(
            children: [
              Positioned.fill(
                child: RTCVideoView(remoteRenderer, mirror: true),
              ),
              Positioned(
                bottom: 8.0,
                right: 8.0,
                width: 120,
                height: 160,
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ],
          ),
        ),
        onPiPClose: () {},
        elevation: 10,
        pipBorderRadius: 10,
      ),
    );
  }

  void stopPiPMode() {
    PictureInPicture.stopPiP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, remoteRenderer);
                    },
                    child: Text("Open camera and microphone"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // roomId = await signaling.createRoom(_remoteRenderer);
                      // textEditingController.text = roomId!;
                    },
                    child: Text("Create room"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      signaling.joinRoom(textEditingController.text);
                    },
                    child: Text("Join room"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RTCVideoView(remoteRenderer, mirror: true),
                  ),
                  Positioned(
                    bottom: 8.0,
                    right: 8.0,
                    width: 120,
                    height: 160,
                    child: RTCVideoView(_localRenderer, mirror: true),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following room"),
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                signaling.hangUp(_localRenderer);
              },
              icon: Icon(
                CupertinoIcons.phone_down_circle_fill,
                color: Colors.red,
                size: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
