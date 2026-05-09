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
  bool _isPlaying = false; // Premenované pre lepšiu sémantiku

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (kIsWeb) {
      final String fileName = widget.assetPath.split('/').last;
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
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pridaná funkcia pre manuálne prepínanie (ťuknutím prsta)
  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // GestureDetector zachytí ťuknutie na mobile
    return GestureDetector(
      onTap: _togglePlay,
      child: MouseRegion(
        // MouseRegion zachytí myš na desktope
        onEnter: (_) {
          setState(() => _isPlaying = true);
          _controller.play();
        },
        onExit: (_) {
          setState(() => _isPlaying = false);
          _controller.pause();
        },
        child: Stack(
          alignment: Alignment.center,
          children:[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            // Play ikona (zmizne, ak sa video prehráva)
            AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Trochu tmavšie pre lepšiu viditeľnosť
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}