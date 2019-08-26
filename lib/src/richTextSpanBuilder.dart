import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class RichTextSpanBuilder {

  TextSpan build(
    String data, {
    TextStyle textStyle,
  }) {
    if (data == null || data == "") return TextSpan(text: "", style: textStyle);
    List<TextSpan> inlineList = new List<TextSpan>();
    if (data.length > 0) {
			RichTextWidget specialText;
      String textStack = "";
      //String text
      for (int i = 0; i < data.length; i++) {
        String char = data[i];
        textStack += char;
        if (specialText != null) {
          if (!specialText.isEnd(textStack)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
            textStack = "";
          }
        } else {
          specialText = createSpecialText(
            textStack,
            textStyle: textStyle,
            index: i,
          );
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(0, textStack.length - specialText.startFlag.length);
              if (textStack.length > 0) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = "";
          }
        }
      }

      if (specialText != null) {
        inlineList.add(TextSpan(text: specialText.startFlag + specialText.getContent(), style: textStyle));
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }

    return TextSpan(children: inlineList, style: textStyle);
  }

	RichTextWidget createSpecialText(
    String flag, {
    TextStyle textStyle,
    int index,
  });

  /// start with SpecialText
  bool isStart(String value, String startFlag) {
    return value.endsWith(startFlag);
  }
}

abstract class RichTextWidget {
  final StringBuffer _contetnt;

  ///start flag of SpecialText
  final String startFlag;

  ///end flag of SpecialText
  final String endFlag;

  ///TextStyle of SpecialText
  final TextStyle textStyle;


	RichTextWidget(this.startFlag, this.endFlag, this.textStyle) : _contetnt = StringBuffer();

  ///finish SpecialText
  TextSpan finishText();

  ///is end of SpecialText
  bool isEnd(String value) {
    return value.endsWith(endFlag);
  }

  ///append text of SpecialText
  void appendContent(String value) {
    _contetnt.write(value);
  }

  ///get content of SpecialText
  String getContent() {
    if (endFlag.length > 1) {
      final cont = _contetnt.toString();
      return cont.substring(0, cont.length - (endFlag.length - 1));
    }
    return _contetnt.toString();
  }

  static int getStart(int index, String flag) {
  	return index - (flag.length - 1);
	}

  @override
  String toString() {
    return startFlag + getContent() + endFlag;
  }
}
