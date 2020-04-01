import 'package:picturide/model/audio_track.dart';
import 'package:picturide/view/project_page.dart';

class _MockProjectPageState extends ProjectPageState {
  @override
  askClipFile() async => 'mockVideoPath';
  @override
  askAudioTrack(_) async => AudioTrack(bpm: 0, filePath: 'mockAudioPath');
}
  
class MockProjectPage extends ProjectPage {
  @override
  _MockProjectPageState createState() => _MockProjectPageState();
}