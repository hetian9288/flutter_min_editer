import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './richTextSpanBuilder.dart';
import 'package:flutter_min_editer/src/func.dart' show mapToTextStyle;
import 'package:flutter_min_editer/flutter_min_editer.dart';

class ColorRichTextSpan extends RichTextWidget {
  static const String flag = r"\[color=#(.*?)\]$";
  static const String flagEnd = "[/color]";
  final int start;
  final TapGestureRecognizer gestureRecognizer;
  Map<String, String> styleMaps;

  final BuilderType type;
  ColorRichTextSpan(TextStyle textStyle, this.gestureRecognizer,
      {this.type, this.start})
      : super(flag, " ", textStyle);

  static ColorRichTextSpan isStart(int index, String value, TextStyle textStyle, TapGestureRecognizer gestureRecognizer,
      { type }) {
    final r = RegExp(flag);
    final all = r.allMatches(value);
    if (all.length == 0) {
      return null;
    }
    final myFlag = all.first.group(0);
    final params = all.first.group(1);
    final arrParams = params.split(" ");
    final styleMap = <String, String>{};
    styleMap["color"] = arrParams.first;
    for (int i = 1; i < arrParams.length; i ++) {
      final item = arrParams[i];
      final itemOption = item.split("=");
      if (itemOption.length == 2) {
        styleMap[itemOption[0]] = itemOption[1];
      }
    }
    return ColorRichTextSpan._(myFlag, textStyle, gestureRecognizer, type: type, start: index - (myFlag.length - 1), styleMaps: styleMap);
  }

  ColorRichTextSpan._(
    String myFlag,
    TextStyle textStyle,
    this.gestureRecognizer, {
    this.type,
    this.start,
    this.styleMaps,
  }) : super(myFlag, flagEnd, textStyle);

  @override
  TextSpan finishText() {
    TextStyle textStyle = mapToTextStyle(styleMaps, this.textStyle);

    final String atText = toString();
    final String content = getContent();

    if (type == BuilderType.extendedText)
      return TextSpan(text: content, style: textStyle);
    return RichTextSpan(
      text: content,
      actualText: atText,
      start: start,
      style: textStyle,
      deleteAll: true,
      recognizer: type == BuilderType.extendedText ? null : null,
    );
  }
}
