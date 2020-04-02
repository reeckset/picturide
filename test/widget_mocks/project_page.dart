import 'package:flutter/cupertino.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/view/pages/project_page.dart';

class _MockProjectPageState extends ProjectPageState {
  _MockProjectPageState(Project projectState) : super(projectState);

  @override
  askClipFile() async => 'mockVideoPath';
  @override
  askAudioTrack(_) async => AudioTrack(bpm: 0, filePath: 'mockAudioPath');
}
  
class MockProjectPage extends ProjectPage {
  MockProjectPage({Key key, project}) : super(key: key, project: project);

  @override
  _MockProjectPageState createState() => _MockProjectPageState(project);
}