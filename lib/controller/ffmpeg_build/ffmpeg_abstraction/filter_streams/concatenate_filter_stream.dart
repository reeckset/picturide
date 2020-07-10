import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

class ConcatenateFilterStream extends MultiInputFilterStream {

  ConcatenateFilterStream(List<FFMPEGStream> sourceStreams)
    :super(sourceStreams);

  @override
  buildFilter() {
    ensureVideoStream();
    ensureAudioStream();
    String filter = '';
    // createFilterInputs
    for(final sourceStream in sourceStreams) {
      filter += '''${sourceStream.getVideoStreamLabel().forFilterInput()}
        ${sourceStream.getAudioStreamLabel().forFilterInput()}''';
    }
    //apply filter
    filter += '''concat=n=${sourceStreams.length}:v=1:a=1
      ${getVideoStreamLabel().forFilterInput()}${getAudioStreamLabel().forFilterInput()}''';
    return filter;
  }
 
  @override
  FFMPEGLabel getVideoStreamLabel() =>
    generateVideoStreamLabel('concatenate');

  @override
  FFMPEGLabel getAudioStreamLabel() =>
    generateAudioStreamLabel('concatenate');
}