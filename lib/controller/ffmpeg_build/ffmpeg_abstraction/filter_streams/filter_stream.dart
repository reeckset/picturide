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
    return sourceStream.buildFilterComplex() + buildFilter();
  }

  String buildFilter();

  @override
  List<String> buildMappingArgs() => [
    ...sourceStream.getVideoStreamLabel() != null
      ? ['-map', '[${sourceStream.getVideoStreamLabel()}]']
      : [],
    ...sourceStream.getAudioStreamLabel() != null
      ? ['-map', '[${sourceStream.getAudioStreamLabel()}]']
      : [],
  ];
}