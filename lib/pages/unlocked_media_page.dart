import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

import 'media_preview.dart';

class UnlockedMediaPage extends StatefulWidget {
  const UnlockedMediaPage({Key key}) : super(key: key);

  @override
  State<UnlockedMediaPage> createState() => _UnlockedMediaPageState();
}

class _UnlockedMediaPageState extends State<UnlockedMediaPage> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch media data from Firestore when the page loads
    _fetchMedia();
  }

  Future<void> _previewImage(String imageUrl) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGallery(
          pageController: PageController(),
          scrollPhysics: BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
          pageOptions: [
            PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ],
          onPageChanged: (index) {
            // handle page change
          },
        ),
      ),
    );
  }

  void _previewVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: VideoPlayerWidget(url: videoUrl),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _previewMedia(String mediaUrl, bool isImage) async {
    if (isImage) {
      await _previewImage(mediaUrl);
    } else {
      _previewVideo(mediaUrl);
    }
  }

  Future<void> _fetchMedia() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('media') // Replace with your collection name
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          // Clear existing data
          imageUrls.clear();
          videoUrls.clear();

          // Extract and update data from Firestore
          for (DocumentSnapshot mediaDocument in querySnapshot.docs) {
            Map<String, dynamic> data =
                mediaDocument.data() as Map<String, dynamic>;

            String url = data['url'];
            bool isImage = data['isImage'];

            if (isImage) {
              imageUrls.add(url);
            } else {
              videoUrls.add(url);
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching media collection: $e');
      // Handle the error as needed
    }
  }

  Future<void> _navigateToPreview(File mediaFile, bool isImage) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPreviewPage(
          mediaFile: mediaFile,
          isImage: isImage,
        ),
      ),
    );
  }

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

  Future<void> _showMediaSourceModal(bool isImage) async {
    final source = isImage ? ImageSource.camera : ImageSource.gallery;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                'Camera',
                style: TextStyle(color: Colors.pink.shade300),
              ),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final result = isImage
                    ? await ImagePicker().pickImage(source: source)
                    : await ImagePicker().pickVideo(source: ImageSource.camera);
                if (result == null) return;

                if (isImage) {
                  final imageTemporary = File(result.path);
                  _navigateToPreview(imageTemporary, true);
                } else {
                  final videoTemporary = File(result.path);
                  _navigateToPreview(videoTemporary, false);
                }
              },
            ),
            ListTile(
              title: Text(
                'Gallery',
                style: TextStyle(color: Colors.pink.shade300),
              ),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final result = isImage
                    ? await ImagePicker().pickImage(source: ImageSource.gallery)
                    : await ImagePicker()
                        .pickVideo(source: ImageSource.gallery);
                if (result == null) return;

                if (isImage) {
                  final imageTemporary = File(result.path);
                  _navigateToPreview(imageTemporary, true);
                } else {
                  final videoTemporary = File(result.path);
                  _navigateToPreview(videoTemporary, false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadMedia() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Pick Image or Video",
              style: TextStyle(
                  color: Colors.pink.shade300,
                  fontFamily: 'SF',
                  fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _showMediaSourceModal(true); // Show image options
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.photo,
                            color: Colors.pink.shade100,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Image",
                            style: TextStyle(
                              color: Colors.pink.shade100,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _showMediaSourceModal(false);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.video_camera_solid,
                            color: Colors.pink.shade100,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Video",
                            style: TextStyle(
                              color: Colors.pink.shade100,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
    if (image != null) {
      await _uploadMediaToFirestore(image, true);
    }

    if (video != null) {
      await _uploadMediaToFirestore(video, false);
    }
  }

  double progressValue = 0.0;
  File image;
  File video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.pink.shade100,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: _uploadMedia,
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  children: const [
                    Icon(
                      CupertinoIcons.photo_on_rectangle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Upload",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),

          // Display selected images and videos or "No media"
          if (imageUrls.isNotEmpty || videoUrls.isNotEmpty)
            Expanded(
              child: LiquidPullToRefresh(
                height: 200,
                color: Colors.pink.shade100,
                onRefresh: _fetchMedia,
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                  ),
                  itemCount: imageUrls.length + videoUrls.length,
                  itemBuilder: (context, index) {
                    if (index < imageUrls.length) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            _previewMedia(imageUrls[index], true);
                          },
                          child: Image.network(imageUrls[index]),
                        ),
                      );
                    } else {
                      final videoIndex = index - imageUrls.length;
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            _previewMedia(videoUrls[videoIndex], false);
                          },
                          child: VideoPlayerWidget(url: videoUrls[videoIndex]),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          if (imageUrls.isEmpty && videoUrls.isEmpty)
            LiquidPullToRefresh(
              onRefresh: _fetchMedia,
              child: const Expanded(
                child: Center(
                  child: Text(
                    'No media',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: _controller.value.isPlaying
                ? Container()
                : const Icon(
                    Icons.play_arrow,
                    size: 50.0,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
