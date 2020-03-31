import 'dart:io';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/view/project_page.dart';

class _MockProjectPageState extends ProjectPageState {
  @override
  askClipFile() async => File('mockVideoPath');
  @override
  askAudioTrack(_) async => AudioTrack(bpm: 0, file: File('mockAudioPath'));
}

class MockProjectPage extends ProjectPage {
  @override
  _MockProjectPageState createState() => _MockProjectPageState();
}