import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoplayVideo extends StatefulWidget {
  final String assetPath;

  const AutoplayVideo({super.key, required this.assetPath});

  @override
  State<AutoplayVideo> createState() => _AutoplayVideoState();
}

class _AutoplayVideoState extends State<AutoplayVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        // Keď je video pripravené
        setState(() {
          _isInitialized = true;
          _controller.setVolume(0); // MUST BE MUTED for autoplay on web
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dôležité pre uvoľnenie RAM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Kým sa video načítava, ukážeme prázdny box s farbou pozadia
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}