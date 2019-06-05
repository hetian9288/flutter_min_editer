import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './richTextSpanBuilder.dart';
import 'package:flutter_min_editer/flutter_min_editer.dart';

class AtRichTextSpan extends RichTextWidget {
  static const String flag = "@";
  final int start;

  final BuilderType type;
	AtRichTextSpan(TextStyle textStyle, TapGestureRecognizer gestureRecognizer, {this.type, this.start})
      : super(flag, " ", textStyle);

  @override
  TextSpan finishText() {
    TextStyle textStyle = this.textStyle?.copyWith(color: Colors.blue, fontSize: 16.0);

    final String atText = toString();

    if (type == BuilderType.extendedText)
      return TextSpan(text: atText, style: textStyle);

    return RichTextSpan(
      text: atText,
      actualText: atText,
      start: start,
      style: textStyle,
      deleteAll: true,
      recognizer: type == BuilderType.extendedText ? null : null,
    );
  }
}
