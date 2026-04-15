import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HoverVideoPlayer extends StatefulWidget {
  final String assetPath;

  const HoverVideoPlayer({super.key, required this.assetPath});

  @override
  State<HoverVideoPlayer> createState() => _HoverVideoPlayerState();
}

class _HoverVideoPlayerState extends State<HoverVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (kIsWeb) {
      final String fileName = widget.assetPath.split('/').last;
      // Získa "checkin" alebo inú base path
      final String baseHref = Uri.base.path.split('/').where((s) => s.isNotEmpty).first;
      final String fullUrl = "${Uri.base.origin}/$baseHref/videos/$fileName";
      _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
    } else {
      _controller = VideoPlayerController.asset(widget.assetPath);
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.setVolume(0); // Musí byť muted pre web policy
          _controller.setLooping(true);
          // Video necháme na začiatku pauznuté
        });
      }
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

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.play();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.pause();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          // Zobrazíme Play ikonu, ak sa na video nepozerá (nie je hover)
          AnimatedOpacity(
            opacity: _isHovering ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
            ),
          ),
        ],
      ),
    );
  }
}