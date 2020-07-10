import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
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
      filter += '''[${sourceStream.getVideoStreamLabel()}]
        [${sourceStream.getAudioStreamLabel()}]''';
    }
    //apply filter
    filter += '''concat=n=${sourceStreams.length}:v=1:a=1
      [${getVideoStreamLabel()}][${getAudioStreamLabel()}]''';
    return filter;
  }
 
  @override
  String getVideoStreamLabel() => getDefaultVideoStreamLabel() + 'concatenate';

  @override
  String getAudioStreamLabel() => getDefaultAudioStreamLabel() + 'concatenate';

  @override
  List<String> buildInputArgs() => sourceStreams.fold([],
    (acc, FFMPEGStream s) {
      acc.addAll(s.buildInputArgs());
      return acc;
    }
  );
}