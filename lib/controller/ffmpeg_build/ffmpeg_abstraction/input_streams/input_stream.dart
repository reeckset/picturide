import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class InputStream extends FFMPEGStream {

  static final FlutterFFprobe flutterFFprobe = FlutterFFprobe();

  int inputIndex = 0;

  bool hasVideo = false;
  bool hasAudio = false;

  @override
  String buildFilterComplex() => '';

  @override
  List<String> buildOutputArgs() => [];

  @override
  int updateInputIndicesAndReturnNext(int newStartIndex) =>
    (this.inputIndex = newStartIndex)+1;


  @override
  String getAudioStreamLabel() => hasAudio ? '$inputIndex:a' : null;

  @override
  String getVideoStreamLabel() => hasVideo ? '$inputIndex:v' : null;
}