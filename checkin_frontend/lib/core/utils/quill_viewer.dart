import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quill_utils.dart';

/// A read-only rich text viewer that renders Quill Delta JSON content.
/// It automatically handles link launching and standard plain text fallbacks.
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
    // Initialize the controller from the provided string and lock it for viewing only
    _controller = QuillUtils.stringToController(widget.jsonText);
    _controller.readOnly = true;
  }

  /// Refreshes the controller if the parent widget provides a new content string.
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
    // Return empty space if no content is available
    if (widget.jsonText == null || widget.jsonText!.isEmpty) return const SizedBox.shrink();

    return QuillEditor.basic(
      controller: _controller,
      config: QuillEditorConfig(
        showCursor: false,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        enableInteractiveSelection: true,
        // Handler for opening links in an external browser
        onLaunchUrl: (String url) async {
          try {
            final Uri uri = Uri.parse(url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            // Silently fail if the URL is malformed or no browser is available
          }
        },
      ),
    );
  }
}