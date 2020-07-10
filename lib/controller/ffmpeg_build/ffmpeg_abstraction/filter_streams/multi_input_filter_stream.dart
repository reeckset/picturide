import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class MultiInputFilterStream extends FilterStream {

  final List<FFMPEGStream> sourceStreams;

  MultiInputFilterStream(this.sourceStreams) : super(null){
    if(sourceStreams.length < 2){
      throw Exception('This filter needs at least two source streams');
    }
  }
  
  @override
  int updateInputIndicesAndReturnNext(int newStartIndex){
    int nextIndex = newStartIndex;
    for(final sourceStream in sourceStreams){
      nextIndex = sourceStream.updateInputIndicesAndReturnNext(nextIndex);
    }
    return nextIndex;
  }

  @override
  buildFilterComplex() {
    if(sourceStreams == null) {
      throw Exception(
        'Multi input filter has no source streams'
      );
    }
    final childrenFilterComplexes =
      sourceStreams.map((s) => s.buildFilterComplex());
    final currentFilterComplex = 
      childrenFilterComplexes.where((fc) => fc.isNotEmpty).join(';');

    return (currentFilterComplex.isNotEmpty
        ? '$currentFilterComplex;'
        : '')
      + buildFilter();
  }

  @override
  List<String> buildOutputArgs() => 
    sourceStreams.fold([],
      (acc, s) {
        acc.addAll(s.buildOutputArgs());
        return acc;
      }); 

  String getDefaultAudioStreamLabel() {
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getAudioStreamLabel() + '-';
    }
    return label;
  }

  String getDefaultVideoStreamLabel() {
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getVideoStreamLabel() + '-';
    }
    return label;
  }

  @override
  ensureVideoStream(){
    if(!sourceStreams.every((stream) => stream.hasVideoStream())){
      throw Exception('Trying to apply video filter to a stream with no video');
    }
  }

  @override
  ensureAudioStream(){
    if(!sourceStreams.every((stream) => stream.hasAudioStream())){
      throw Exception('Trying to apply audio filter to a stream with no audio');
    }
  }
}