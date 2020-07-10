import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class InputStream extends FFMPEGStream {

  int inputIndex = 0;

  @override
  String getAudioStreamLabel() => null;

  @override
  String getVideoStreamLabel() => null;

  @override
  String buildFilterComplex() => '';

  @override
  List<String> buildOutputArgs() => [];

  @override
  int updateInputIndicesAndReturnNext(int newStartIndex) =>
    (this.inputIndex = newStartIndex)+1;
}