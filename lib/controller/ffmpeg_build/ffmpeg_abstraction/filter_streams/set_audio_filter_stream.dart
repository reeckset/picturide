import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/multi_input_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

class SetAudioFilterStream extends MultiInputFilterStream {

  SetAudioFilterStream(FFMPEGStream videoStream, FFMPEGStream audioStream)
    :super([videoStream, audioStream]){
      if(!videoStream.hasVideoStream() || !audioStream.hasAudioStream()){
        throw Exception(
          'SetAudioFilter must have a stream with video and another with audio'
        );
      }
  }

  @override
  buildFilter() => '';

  @override
  FFMPEGLabel getAudioStreamLabel() => sourceStreams[1].getAudioStreamLabel();

  @override
  FFMPEGLabel getVideoStreamLabel() => sourceStreams[0].getVideoStreamLabel();
}