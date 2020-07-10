import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

class AudioVolumeFilterStream extends FilterStream {

  double volume;

  AudioVolumeFilterStream(this.volume, sourceStream)
    :super(sourceStream);

  @override
  buildFilter() {
    ensureVideoStream();
    return '''${sourceStream.getAudioStreamLabel().forFilterInput()}
      volume=$volume
      ${getAudioStreamLabel().forFilterInput()}''';
  }
 
  @override
  FFMPEGLabel getAudioStreamLabel() =>
    generateAudioStreamLabel('volume-$volume');
}