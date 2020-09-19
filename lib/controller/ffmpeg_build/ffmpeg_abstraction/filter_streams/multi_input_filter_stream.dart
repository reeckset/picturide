import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_filtered_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
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
  buildInputArgs() async {
    final List<String> result = [];
    for(final s in sourceStreams){
      result.addAll(await s.buildInputArgs());
    }
    return result;
  }

  @override
  buildFilterComplex() async {
    if(sourceStreams == null) {
      throw Exception(
        'Multi input filter has no source streams'
      );
    }
    final childrenFilterComplexes =
      await Future.wait(sourceStreams.map(
        (s) async => await s.buildFilterComplex())
      );
    final currentFilterComplex = 
      [...childrenFilterComplexes, buildFilter()]
      .where((fc) => fc.isNotEmpty).join(';');

    return currentFilterComplex;
  }

  @override
  buildOutputArgs() async {
    final List<String> result = [];
    for(final s in sourceStreams){
      result.addAll(await s.buildOutputArgs());
    }
    return result;
  }

  @override
  FFMPEGLabel generateAudioStreamLabel(String appendText) {
    if(!sourceStreams.every((stream) => stream.hasAudioStream())) return null;
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getAudioStreamLabel().label + '-';
    }
    return FFMPEGFilteredLabel(label + appendText);
  }

  @override
  FFMPEGLabel generateVideoStreamLabel(String appendText) {
    if(!sourceStreams.every((stream) => stream.hasVideoStream())) return null;
    String label = '';
    for(final sourceStream in sourceStreams) {
      label += sourceStream.getVideoStreamLabel().label + '-';
    }
    return FFMPEGFilteredLabel(label + appendText);
  }

  @override
  ensureVideoStream(){
    if(!this.hasVideoStream()){
      throw Exception('Trying to apply video filter to a stream with no video');
    }
  }

  @override
  ensureAudioStream(){
    if(!this.hasAudioStream()){
      throw Exception('Trying to apply audio filter to a stream with no audio');
    }
  }
}