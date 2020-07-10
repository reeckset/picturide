import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

// Keeps video from first source with video
class MixAudioFilterStream extends MultiInputFilterStream {

  MixAudioFilterStream(List<FFMPEGStream> sourceStreams)
    :super(sourceStreams);

  @override
  buildFilter() {
    ensureAudioStream();
    String filter = '';
    for(final sourceStream in sourceStreams) {
      filter += '${sourceStream.getAudioStreamLabel().forFilterInput()}';
    }
    return filter +
      '''amix=inputs=${sourceStreams.length}:duration=first,pan=stereo|c0<c0+c2|c1<c1+c3
      ${getAudioStreamLabel().forFilterInput()}''';
  }

  @override
  FFMPEGLabel getAudioStreamLabel() => generateAudioStreamLabel('mix');

  @override
  FFMPEGLabel getVideoStreamLabel() => 
    sourceStreams.firstWhere(
      (source) => source.hasVideoStream(),
      orElse: () => sourceStreams[0]
    ).getVideoStreamLabel();
}