import 'package:flutter/material.dart';

class LabeledText extends StatelessWidget {
  final String label;
  final String text;
  final double fontSize;
  final double textMaxWidth;

  const LabeledText(String label, String text, double fontSize, double textMaxWidth)
      : label = label, text = text, fontSize = fontSize, textMaxWidth = textMaxWidth;

  @override
  Widget build(BuildContext context) {
    return
        Row(
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, fontFamily: "AndaleMono")),
        Text(label != "" ? ": " : ""),
        SizedBox( width: textMaxWidth, child:Text(text, overflow: TextOverflow.fade, maxLines: 1, softWrap: false, style: TextStyle(fontSize: fontSize),)),
      ],

    );
  }
}
