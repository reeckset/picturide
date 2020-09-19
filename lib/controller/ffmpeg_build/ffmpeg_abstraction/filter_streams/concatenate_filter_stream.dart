import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

class ConcatenateFilterStream extends MultiInputFilterStream {

  ConcatenateFilterStream(List<FFMPEGStream> sourceStreams)
    :super(sourceStreams);

  @override
  buildFilter() {
    String filter = '';
    final bool hasAudioStream = this.hasAudioStream();
    final bool hasVideoStream = this.hasVideoStream();

    // createFilterInputs
    for(final sourceStream in sourceStreams) {
      filter += 
      '''${hasVideoStream ? sourceStream.getVideoStreamLabel().forFilterInput() : ''}
      ${hasAudioStream ? sourceStream.getAudioStreamLabel().forFilterInput() : ''}''';
    }
    //apply filter
    filter += '''concat=n=${sourceStreams.length}:v=${hasVideoStream ? 1 : 0}:a=${hasAudioStream ? 1 : 0}
      ${hasVideoStream ? getVideoStreamLabel().forFilterInput() : ''}
      ${hasAudioStream ? getAudioStreamLabel().forFilterInput() : ''}''';
    return filter;
  }
 
  @override
  FFMPEGLabel getVideoStreamLabel() =>
    generateVideoStreamLabel('concatenate');

  @override
  FFMPEGLabel getAudioStreamLabel() =>
    generateAudioStreamLabel('concatenate');
}