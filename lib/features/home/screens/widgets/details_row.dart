import 'package:flutter/material.dart';

import '../../../../common_widgets/auto_translated_text.dart';


class DetailsRow extends StatelessWidget {
  String label;
  String? value;

  DetailsRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: AutoTranslatedText(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: AutoTranslatedText(value!)),
        ],
      ),
    );
  }
}
