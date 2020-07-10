import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class FilterStream extends FFMPEGStream {

  FilterStream(sourceStream):super(sourceStream: sourceStream);

  @override
  buildFilterComplex() {
    if(sourceStream == null) {
      throw Exception(
        'Filter Stream has no source stream'
      );
    }
    final currentFilterComplex = sourceStream.buildFilterComplex();

    return (currentFilterComplex.isNotEmpty
        ? '$currentFilterComplex;'
        : '')
      + buildFilter();
  }

  String buildFilter();

  @override
  List<String> buildMappingArgs() => [
    ...hasVideoStream()
      ? ['-map', '[${getVideoStreamLabel()}]']
      : [],
    ...hasAudioStream()
      ? ['-map', '[${getAudioStreamLabel()}]']
      : [],
  ];

  ensureVideoStream(){
    if(!sourceStream.hasVideoStream()){
      throw Exception('Trying to apply video filter to a stream with no video');
    }
  }

  ensureAudioStream(){
    if(!sourceStream.hasAudioStream()){
      throw Exception('Trying to apply audio filter to a stream with no audio');
    }
  }
}