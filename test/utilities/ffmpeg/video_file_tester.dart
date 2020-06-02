import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class VideoFileTester {
  String filePath;
  var _streamsInfo;
  VideoFileTester(this.filePath){
    expect(File(this.filePath).existsSync(), true);
  }

  init() async {
    _streamsInfo = await generateStreamsInfo();
    return this;
  }

  /**
   * Returns an array of maps (0 -> video stream, 1 -> audio stream)
   */
  Future<dynamic> generateStreamsInfo() async {
      final ProcessResult pr = await Process.run('ffprobe', [
        '-v','quiet','-print_format','json',
        '-show_format','-show_streams','-print_format','json',
        this.filePath]);
      return json.decode(pr.stdout)['streams'];
  }

  checkInited(){
    if(_streamsInfo == null){
      throw Exception('''VideoFileTester needs to call
        init before checking properties''');
    }
  }

  _getVideoInfo(String field) {
    checkInited();
    return _streamsInfo[0][field];
  }

  _getAudioInfo(String field){
    checkInited();
    return _streamsInfo[1][field];
  }
  

  _expectValueEquivalence(a, b, tolerance) {
    expect((a-b).abs() <= tolerance, true);
  }

  checkResolution(Map<String, int> expected) {
    expect(_getVideoInfo('width'), expected['w']);
    expect(_getVideoInfo('height'), expected['h']);
  }

  checkFrameRate(int expected) {
    expect(_getVideoInfo('r_frame_rate'), '$expected/1');
  }

  checkDuration(double expected) {
    final tolerance = 0.2;
    _expectValueEquivalence(
      double.parse(_getVideoInfo('duration')),
      expected,
      tolerance
    );
  }

  checkAVDurationMatch() {
    final tolerance = 0.2;
    _expectValueEquivalence(
      double.parse(_getVideoInfo('duration')),
      double.parse(_getAudioInfo('duration')),
      tolerance
    );
  }
}