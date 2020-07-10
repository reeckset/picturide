import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';

class FormatAudioFilterStream extends FilterStream {

  FormatAudioFilterStream(sourceStream)
    :super(sourceStream);

  @override
  buildFilter() {
    ensureVideoStream();
    return '''[${sourceStream.getAudioStreamLabel()}]
      aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
      [${getAudioStreamLabel()}]''';
  }
 
  @override
  String getAudioStreamLabel() =>
    '${sourceStream.getAudioStreamLabel()}-format';
}