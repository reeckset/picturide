import 'package:picturide/view/pages/add_audio_page.dart';

class _MockAddAudioPageState extends AddAudioPageState {
  @override
  getAudioFile() async => 'mockAudioPath';
}

class MockAddAudioPage extends AddAudioPage {
  @override
  _MockAddAudioPageState createState() => _MockAddAudioPageState();
}