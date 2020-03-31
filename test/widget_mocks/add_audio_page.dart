import 'dart:io';
import 'package:picturide/view/add_audio_page.dart';

class _MockAddAudioPageState extends AddAudioPageState {
  @override
  getAudioFile() async => File('mockAudioPath');
}

class MockAddAudioPage extends AddAudioPage {
  @override
  _MockAddAudioPageState createState() => _MockAddAudioPageState();
}