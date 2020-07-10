import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

class ConcatenateFilterStream extends MultiInputFilterStream {

  ConcatenateFilterStream(List<FFMPEGStream> sourceStreams)
    :super(sourceStreams){
      if(sourceStreams.length < 2){
        throw Exception('Concatenate needs at least two source streams');
      }
    }

  @override
  buildFilter() {
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
  String getVideoStreamLabel() {
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getVideoStreamLabel() + '-';
    }
    return label + 'concatenate';
  }

  @override
  String getAudioStreamLabel() {
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getAudioStreamLabel() + '-';
    }
    return label + 'concatenate';
  }

  @override
  List<String> buildInputArgs() => sourceStreams.fold([],
    (acc, FFMPEGStream s) {
      acc.addAll(s.buildInputArgs());
      return acc;
    }
  );
}