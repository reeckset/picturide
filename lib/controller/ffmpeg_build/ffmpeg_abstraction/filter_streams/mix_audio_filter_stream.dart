import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';

class MixAudioFilterStream extends MultiInputFilterStream {

  MixAudioFilterStream(sourceStreams)
    :super(sourceStreams);

  @override
  buildFilter() {
    ensureAudioStream();
    return '''[${sourceStream.getAudioStreamLabel()}]
      amix=inputs=${sourceStreams.length}:duration=first,pan=stereo|c0<c0+c2|c1<c1+c3
      [${getAudioStreamLabel()}]''';
  }

  @override
  String getAudioStreamLabel() => getDefaultAudioStreamLabel() + 'mix';
}