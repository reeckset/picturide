import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

class FormatAudioFilterStream extends FilterStream {

  FormatAudioFilterStream(sourceStream)
    :super(sourceStream);

  @override
  buildFilter() {
    ensureVideoStream();
    return '''${sourceStream.getAudioStreamLabel().forFilterInput()}
      aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo
      ${getAudioStreamLabel().forFilterInput()}''';
  }
 
  @override
  FFMPEGLabel getAudioStreamLabel() =>
    generateAudioStreamLabel('format');
}