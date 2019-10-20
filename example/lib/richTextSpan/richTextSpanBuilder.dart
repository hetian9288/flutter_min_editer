import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_min_editer/flutter_min_editer.dart';
import 'atRichTextSpan.dart';
import 'colorRichTextSpan.dart';

class MyRichTextSpanBuilder extends RichTextSpanBuilder {
  final BuilderType type;

  MyRichTextSpanBuilder({this.type = BuilderType.extendedTextField});

  @override
  RichTextWidget createSpecialText(String flag,
      {TextStyle textStyle, TapGestureRecognizer gestureRecognizer, int index}) {
    if (flag == null || flag == "") return null;

    if (isStart(flag, AtRichTextSpan.flag)) {
      return AtRichTextSpan(textStyle, gestureRecognizer, start: RichTextWidget.getStart(index, AtRichTextSpan.flag), type: type);
    }

    final colorRich = ColorRichTextSpan.isStart(index, flag, textStyle, gestureRecognizer);
    if (colorRich != null) {
      return colorRich;
    }

    return null;
  }
}

enum BuilderType { extendedText, extendedTextField }
