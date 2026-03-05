import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quill_utils.dart'; // tvoja pomocná trieda

class QuillViewer extends StatefulWidget {
  final String? jsonText;

  const QuillViewer({super.key, this.jsonText});

  @override
  State<QuillViewer> createState() => _QuillViewerState();
}

class _QuillViewerState extends State<QuillViewer> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillUtils.stringToController(widget.jsonText);
    _controller.readOnly = true;
  }

  @override
  void didUpdateWidget(QuillViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jsonText != widget.jsonText) {
      _controller = QuillUtils.stringToController(widget.jsonText);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jsonText == null || widget.jsonText!.isEmpty) return const SizedBox.shrink();

    return QuillEditor.basic(
      controller: _controller,
      config: QuillEditorConfig(
        showCursor: false,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        enableInteractiveSelection: true,
        onLaunchUrl: (String url) async {
          try {
            final Uri uri = Uri.parse(url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint("Could not launch $url: $e");
          }
        },
      ),
    );
  }
}