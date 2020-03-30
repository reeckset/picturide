import 'package:flutter/material.dart';
import 'package:picturide/view/project_page.dart';
import 'package:picturide/view/theme.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData,
      home: ProjectPage(title: 'Flutter Demo Home Page'),
    );
  }
}
