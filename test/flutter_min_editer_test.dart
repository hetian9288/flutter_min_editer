import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_min_editer/flutter_min_editer.dart';

void main() {
  test("正则", () async {
    print(double.tryParse("12"));
    final f = r"\[color=#(.*?)\]$";
    final v = "测试[color=#FFab2e2e fontSize=321]";
    final r = RegExp(f);
    print(r.allMatches(v).length);
    r.allMatches(v).forEach((e) {
      print(e.input);
      print(e.groupCount);
      final params = e.group(1);
      final arrParams = params.split(" ");
      final styleMap = <String, String>{};
      styleMap["color"] = arrParams.first;
      for (int i = 1; i < arrParams.length; i++) {
        final item = arrParams[i];
        final itemOption = item.split("=");
        if (itemOption.length == 2) {
          styleMap[itemOption[0]] = itemOption[1];
        }
      }
      print(styleMap);
    });
  });
}
