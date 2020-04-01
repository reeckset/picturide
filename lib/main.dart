import 'package:flutter/material.dart';
import 'package:picturide/view/pages/add_audio_page.dart';
import 'package:picturide/view/pages/home_page.dart';
import 'package:picturide/view/pages/project_page.dart';
import 'package:picturide/view/theme.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData,
     // home: ProjectPage(title: 'Flutter Demo Home Page'),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/add_audio_page': (context) => AddAudioPage(),
        '/project_page': (context) => ProjectPage(),
      },
    );
  }
}
