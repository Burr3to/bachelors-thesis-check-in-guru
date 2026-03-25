import 'package:flutter/foundation.dart';
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
    _initializeController();
  }

  void _initializeController() {
    if (kIsWeb) {
      final String fileName = widget.assetPath.split('/').last;
      final String baseHref = Uri.base.path.split('/')[1]; // Získa "checkin"
      final String fullUrl = "${Uri.base.origin}/$baseHref/videos/$fileName";

      debugPrint("VIDEO LOAD: $fullUrl");
      _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
    } else {
      _controller = VideoPlayerController.asset(widget.assetPath);
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.setVolume(0); // autoplay policy
          _controller.setLooping(true);
          _controller.play();
        });
      }
    }).catchError((error) {
      debugPrint("VIDEO ERROR: $error");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}