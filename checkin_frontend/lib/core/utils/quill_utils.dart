import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillUtils {
  static QuillController stringToController(String? text) {
    if (text == null || text.isEmpty) {
      return QuillController.basic();
    }

    try {
      // Skúsime, či je to JSON (nový formát)
      final json = jsonDecode(text);
      return QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Ak to nie je JSON, je to starý čistý text
      final doc = Document();
      doc.insert(0, text);
      return QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        config: QuillControllerConfig(),
      );
    }
  }

  static String controllerToString(QuillController controller) {
    // Toto uložíš do databázy ako string
    return jsonEncode(controller.document.toDelta().toJson());
  }
}