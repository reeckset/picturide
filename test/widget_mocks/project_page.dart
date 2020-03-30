import 'dart:io';
import 'package:picturide/view/project_page.dart';

class _MockProjectPageState extends ProjectPageState {
  @override
  getClipFile() async => File('mockFilePath');
}

class MockProjectPage extends ProjectPage {
  @override
  _MockProjectPageState createState() => _MockProjectPageState();
}