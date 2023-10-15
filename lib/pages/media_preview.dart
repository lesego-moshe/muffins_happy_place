import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaPreviewPage extends StatefulWidget {
  final File mediaFile;
  final bool isImage;

  MediaPreviewPage({Key key, @required this.mediaFile, @required this.isImage})
      : super(key: key);

  @override
  _MediaPreviewPageState createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  double progressValue = 0.0;
  bool uploading = false;
  List<String> imageUrls = [];
  List<String> videoUrls = [];

  Future<void> _uploadMediaToFirestore(File file, bool isImage) async {
    final storageReference = FirebaseStorage.instance.ref().child(isImage
        ? 'images/${DateTime.now().millisecondsSinceEpoch}.jpg'
        : 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4');

    final uploadTask = storageReference.putFile(file);

    // Start the upload, set uploading to true
    setState(() {
      uploading = true;
    });

    // Listen for changes in the task
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      print('Upload progress: $progress');
      setState(() {
        progressValue = progress;
      });
    });

    try {
      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await storageReference.getDownloadURL();

        // Store the download URL and other metadata in Firestore
        await FirebaseFirestore.instance.collection('media').add({
          'url': downloadUrl,
          'isImage': isImage,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Store the download URL in the appropriate list
        setState(() {
          if (isImage) {
            imageUrls.add(downloadUrl);
          } else {
            videoUrls.add(downloadUrl);
          }
          // Set uploading to false after the upload is complete
          uploading = false;
        });

        // Show a Snackbar and navigate back after successful upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded Successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        // Handle upload failure here
        print('Upload failed');
        setState(() {
          uploading = false;
        });
      }
    } catch (e) {
      // Handle any errors that occur during the upload process
      print('Error uploading media: $e');
      setState(() {
        uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        title: Text(
          widget.isImage ? 'Image Preview' : 'Video Preview',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: widget.isImage
                ? Image.file(widget.mediaFile)
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayerWidget(url: widget.mediaFile.path),
                  ),
          ),
          SizedBox(height: 20.0),
          if (uploading)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      10.0), // Adjust the radius as needed
                ),
                child: LinearProgressIndicator(
                  minHeight: 20,
                  value: progressValue,
                  backgroundColor: Colors.grey,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.pink.shade100),
                ),
              ),
            ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: uploading
                ? null
                : () {
                    _uploadMediaToFirestore(widget.mediaFile, widget.isImage);
                  },
            child: Text(uploading ? 'Uploading...' : 'Upload to Firebase'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    // Return the disabled color
                    return Colors.grey;
                  }

                  return Colors.pink.shade100;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({Key key, @required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.url))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // You can adjust the aspect ratio as needed
      child: VideoPlayer(_controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
