import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_filtered_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class FilterStream extends FFMPEGStream {

  FilterStream(sourceStream):super(sourceStream: sourceStream);

  @override
  buildFilterComplex() async {
    if(sourceStream == null) {
      throw Exception(
        'Filter Stream has no source stream'
      );
    }
    final currentFilterComplex = await sourceStream.buildFilterComplex();

    return (currentFilterComplex.isNotEmpty
        ? '$currentFilterComplex;'
        : '')
      + buildFilter();
  }

  String buildFilter();

  @override
  buildMappingArgs() async => [
    ...hasVideoStream()
      ? ['-map', getVideoStreamLabel().forMapping()]
      : [],
    ...hasAudioStream()
      ? ['-map', getAudioStreamLabel().forMapping()]
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

  FFMPEGLabel generateAudioStreamLabel(String appendText) =>
    FFMPEGFilteredLabel(
      '${sourceStream.getAudioStreamLabel().label}-$appendText'
    );

  FFMPEGLabel generateVideoStreamLabel(String appendText) =>
    FFMPEGFilteredLabel(
      '${sourceStream.getVideoStreamLabel().label}-$appendText'
    );
}