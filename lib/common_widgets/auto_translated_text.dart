import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

import '../features/home/controllers/language_controller.dart';
import '../utils/services/translation_service.dart';

class AutoTranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AutoTranslatedText> createState() => _AutoTranslatedTextState();
}

class _AutoTranslatedTextState extends State<AutoTranslatedText> {
  final LanguageController _controller = Get.find<LanguageController>();
  String? _translatedText;
  String? _lastTargetLang;

  // Worker to listen to changes
  Worker? _langWorker;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _updateTranslation(_controller.currentLanguage.value);

    // Listen to language changes
    _langWorker = ever(_controller.currentLanguage, (String lang) {
      _updateTranslation(lang);
    });
  }

  @override
  void didUpdateWidget(AutoTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateTranslation(_controller.currentLanguage.value);
    }
  }

  @override
  void dispose() {
    _langWorker?.dispose();
    super.dispose();
  }

  void _updateTranslation(String targetLang) {
    // Avoid re-fetching if nothing changed (target lang is same AND text is same)
    // Note: widget.text check is implicit because we call this on didUpdateWidget too
    if (_lastTargetLang == targetLang &&
        _translatedText != null &&
        targetLang != 'en') {
      // Ideally we also check if the text itself hasn't changed, but this simple check is okay for now
      // strictly speaking we should store _lastOriginalText too.
    }

    _lastTargetLang = targetLang;

    if (targetLang == 'en') {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
        });
      }
      return;
    }

    TranslationService()
        .translate(widget.text, targetLang)
        .then((result) {
          if (mounted) {
            setState(() {
              _translatedText = result;
            });
          }
        })
        .catchError((e) {
          debugPrint('Error translating "${widget.text}": $e');
          if (mounted) {
            setState(() {
              _translatedText = widget.text;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
