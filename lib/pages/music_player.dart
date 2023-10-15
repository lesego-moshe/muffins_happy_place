import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MusicPlayerPage extends StatefulWidget {
  final String url;
  final String message;

  MusicPlayerPage({Key key, this.url, this.message}) : super(key: key);

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  YoutubePlayerController _controller;
  bool _isLooping = false;

  void listener() {
    if (_controller.value.playerState == PlayerState.ended && _isLooping) {
      _controller.seekTo(const Duration(seconds: 0));
      _controller.play();
    }
    setState(() {});
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url),
      flags: const YoutubePlayerFlags(
        showLiveFullscreenButton: false,
        hideControls: true,
        forceHD: true,
        autoPlay: true,
        mute: false,
      ),
    );
    _controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.pink.shade100),
        title: Text(
          'Music Player',
          style: TextStyle(color: Colors.pink.shade100),
        ),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              _controller.addListener(listener);
            },
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: Text(
              _controller.metadata.title,
              style: TextStyle(
                  fontFamily: "SF-Bold",
                  fontSize: 4.1.w,
                  fontWeight: FontWeight.w900,
                  color: Colors.pink.shade200),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              _controller.metadata.author,
              style: TextStyle(
                  fontFamily: "SF-Bold",
                  fontSize: 4.1.w,
                  fontWeight: FontWeight.w900,
                  color: Colors.pink.shade300),
            ),
          ),
          Slider(
            activeColor: Colors.pink.shade100,
            inactiveColor: Colors.grey.shade300,
            value: _controller.value.position.inSeconds.toDouble(),
            min: 0.0,
            max: _controller.metadata.duration.inSeconds.toDouble(),
            onChanged: (value) {
              setState(() {
                _controller.seekTo(Duration(seconds: value.toInt()));
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  formatDuration(_controller.value.position),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.pink.shade300,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  formatDuration(_controller.metadata.duration),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.pink.shade300,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                icon: Icon(
                  CupertinoIcons.backward_fill,
                  color: Colors.pink.shade100,
                ),
                onPressed: () {
                  _controller.seekTo(Duration(
                      seconds: _controller.value.position.inSeconds - 10));
                },
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(
                  _controller.value.isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: Colors.pink.shade100,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(
                  CupertinoIcons.forward_fill,
                  color: Colors.pink.shade100,
                ),
                onPressed: () {
                  _controller.seekTo(Duration(
                      seconds: _controller.value.position.inSeconds + 10));
                },
              ),
              // IconButton(
              //   icon: Icon(
              //     _isLooping ? CupertinoIcons.repeat_1 : CupertinoIcons.repeat,
              //     color: Colors.pink.shade100,
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       _isLooping = !_isLooping;
              //     });
              //   },
              // ),
            ],
          ),
          const Divider(
            thickness: 1.5,
            height: 1,
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.black.withOpacity(0.5)),
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.message,
                      style: TextStyle(
                          fontFamily: "SF-Bold",
                          fontSize: 4.1.w,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade100),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Lottie.asset('lib/images/dancing.json',
                height: 200,
                animate: _controller.value.isPlaying ? true : false),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
    _controller.dispose();
  }
}
