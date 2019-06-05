import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_min_editer/flutter_min_editer.dart';

TextPosition convertTextInputPostionToTextPainterPostion(TextSpan text, TextPosition textPosition) {
  if (text != null && text.children != null) {
    int caretOffset = textPosition.offset;
    int textOffset = 0;
    for (TextSpan ts in text.children) {
      if (ts is RichTextSpan) {
        var length = ts.actualText.length;
        caretOffset -= (length - ts.toPlainText().length);
        textOffset += length;
      } else {
        textOffset += ts.toPlainText().length;
      }
      if (textOffset >= textPosition.offset) {
        break;
      }
    }
    if (caretOffset != textPosition.offset) {
      return TextPosition(offset: max(0, caretOffset), affinity: textPosition.affinity);
    }
  }
  return textPosition;
}

TextSelection convertTextInputSelectionToTextPainterSelection(TextSpan text, TextSelection selection) {
  if (selection.isValid) {
    if (selection.isCollapsed) {
      var extent = convertTextInputPostionToTextPainterPostion(text, selection.extent);
      if (selection.extent != extent) {
        selection = selection.copyWith(
            baseOffset: extent.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    } else {
      var extent = convertTextInputPostionToTextPainterPostion(text, selection.extent);

      var base = convertTextInputPostionToTextPainterPostion(text, selection.base);

      if (selection.extent != extent || selection.base != base) {
        selection = selection.copyWith(
            baseOffset: base.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    }
  }

  return selection;
}

TextPosition convertTextPainterPostionToTextInputPostion(TextSpan text, TextPosition textPosition) {
  if (text != null && text.children != null && textPosition != null) {
    int caretOffset = textPosition.offset;
    if (caretOffset <= 0) return textPosition;

    int textOffset = 0;
    for (TextSpan ts in text.children) {
      if (ts is RichTextSpan) {
        var length = ts.actualText.length;
        caretOffset += (length - ts.toPlainText().length);

        ///make sure caret is not in text when caretIn is false
        if (ts.deleteAll && caretOffset > ts.start && caretOffset < ts.end) {
          if (caretOffset > (ts.end - ts.start) / 2.0 + ts.start) {
            //move caretOffset to end
            caretOffset = ts.end;
          } else {
            caretOffset = ts.start;
          }
          break;
        }
      }
      textOffset += ts.toPlainText().length;
      if (textOffset >= textPosition.offset) {
        break;
      }
    }
    if (caretOffset != textPosition.offset) {
      return TextPosition(offset: caretOffset, affinity: textPosition.affinity);
    }
  }
  return textPosition;
}

TextSelection convertTextPainterSelectionToTextInputSelection(TextSpan text, TextSelection selection) {
  if (selection.isValid) {
    if (selection.isCollapsed) {
      var extent = convertTextPainterPostionToTextInputPostion(text, selection.extent);
      if (selection.extent != extent) {
        selection = selection.copyWith(
            baseOffset: extent.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    } else {
      var extent = convertTextPainterPostionToTextInputPostion(text, selection.extent);

      var base = convertTextPainterPostionToTextInputPostion(text, selection.base);

      if (selection.extent != extent || selection.base != base) {
        selection = selection.copyWith(
            baseOffset: base.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    }
  }

  return selection;
}

TextPosition makeSureCaretNotInSpecialText(TextSpan text, TextPosition textPosition) {
  if (text != null && text.children != null && textPosition != null) {
    int caretOffset = textPosition.offset;
    if (caretOffset <= 0) return textPosition;

    int textOffset = 0;
    for (TextSpan ts in text.children) {
      if (ts is RichTextSpan) {
        ///make sure caret is not in text when caretIn is false
        if (ts.deleteAll && caretOffset > ts.start && caretOffset < ts.end) {
          if (caretOffset > (ts.end - ts.start) / 2.0 + ts.start) {
            //move caretOffset to end
            caretOffset = ts.end;
          } else {
            caretOffset = ts.start;
          }
          break;
        }
      }
      textOffset += ts.toPlainText().length;
      if (textOffset >= textPosition.offset) {
        break;
      }
    }
    if (caretOffset != textPosition.offset) {
      return TextPosition(offset: caretOffset, affinity: textPosition.affinity);
    }
  }
  return textPosition;
}

///correct caret Offset
///make sure caret is not in text when caretIn is false
TextEditingValue correctCaretOffset(
    TextEditingValue value, TextSpan textSpan, TextInputConnection textInputConnection,
    {TextSelection newSelection}) {
  if (textSpan == null || textSpan.children == null) return value;

  TextSelection selection = newSelection ?? value.selection;

  if (selection.isValid && selection.isCollapsed) {
    int caretOffset = selection.extentOffset;
    var specialTextSpans = textSpan.children.where((x) => x is RichTextSpan && x.deleteAll);
    //correct caret Offset
    //make sure caret is not in text when caretIn is false
    for (RichTextSpan ts in specialTextSpans) {
      if (caretOffset > ts.start && caretOffset < ts.end) {
        if (caretOffset > (ts.end - ts.start) / 2.0 + ts.start) {
          //move caretOffset to end
          caretOffset = ts.end;
        } else {
          caretOffset = ts.start;
        }
        break;
      }
    }

    ///tell textInput caretOffset is changed.
    if (caretOffset != selection.baseOffset) {
      value =
          value.copyWith(selection: selection.copyWith(baseOffset: caretOffset, extentOffset: caretOffset));
      textInputConnection?.setEditingState(value);
    }
  }
  return value;
}

TextEditingValue handleRichTextSpanDelete(TextEditingValue value, TextEditingValue oldValue,
    TextSpan oldTextSpan, TextInputConnection textInputConnection) {
  var oldText = oldValue?.text;
  var newText = value?.text;
  if (oldTextSpan != null && oldTextSpan.children != null) {
    var richSpans = oldTextSpan.children.where((x) => (x is RichTextSpan && x.deleteAll));

    ///take care of image span
    if (richSpans.length > 0 && oldText != null && newText != null && oldText.length > newText.length) {
      int difStart = 0;
      //int difEnd = oldText.length - 1;
      for (; difStart < newText.length; difStart++) {
        if (oldText[difStart] != newText[difStart]) {
          break;
        }
      }

      int caretOffset = value.selection.extentOffset;
      if (difStart > 0) {
        for (RichTextSpan ts in richSpans) {
          if (difStart > ts.start && difStart < ts.end) {
            //difStart = ts.start;
            newText = newText.replaceRange(ts.start, difStart, "");
            caretOffset -= (difStart - ts.start);
            break;
          }
        }
        if (newText != value.text) {
          value = TextEditingValue(
              text: newText,
              selection: value.selection.copyWith(
                  baseOffset: caretOffset,
                  extentOffset: caretOffset,
                  affinity: value.selection.affinity,
                  isDirectional: value.selection.isDirectional));
          textInputConnection?.setEditingState(value);
        }
      }
    }
  }

  return value;
}

//bool hasSpecialText(List<TextSpan> value) {
//  if (value == null) return false;
//
//  for (var textSpan in value) {
//    if (textSpan is RichTextSpan) return true;
//    if (hasSpecialText(textSpan.children)) {
//      return true;
//    }
//  }
//  return false;
//}

bool hasSpecialText(TextSpan textSpan) {
  if (textSpan == null || textSpan.children == null) return false;

  //for performance, make sure your all RichTextSpan are only in textSpan.children
  //extended_text_field will only check textSpan.children
  return textSpan.children.firstWhere((x) => x is RichTextSpan, orElse: () => null) != null;
}
