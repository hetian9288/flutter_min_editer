// Flutter code sample for material.BottomNavigationBar.1

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:example/richTextSpan/richTextSpanBuilder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_min_editer/flutter_min_editer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "@dasds dasdsa@dasdas ");
    _focusNode = FocusNode();
  }

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: <Widget>[
          Column(
            children: <Widget>[
              RichEditableTextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
                cursorColor: Colors.pinkAccent[400],
                cursorWidth: 2,
                richTextSpanBuilder: MyRichTextSpanBuilder(),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 28),
                  decoration: InputDecoration(
                    hintText: "这里输入手机号码",
                    hintStyle: TextStyle(fontWeight: FontWeight.w200, color: Colors.grey),
                  ),
                  validator: (val) {
                    return RegExp(r'^1\d{10}').hasMatch(val) ? null : "请输入正确的11位手机号码";
                  },
                ),
              )
            ],
          ),
          Text(
            'Index 2: School',
            style: optionStyle,
          ),
        ].elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('demo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
