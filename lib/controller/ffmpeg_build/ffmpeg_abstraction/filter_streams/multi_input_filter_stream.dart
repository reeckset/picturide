import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class MultiInputFilterStream extends FilterStream {

  final List<FFMPEGStream> sourceStreams;

  MultiInputFilterStream(this.sourceStreams) : super(null);
  
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
}