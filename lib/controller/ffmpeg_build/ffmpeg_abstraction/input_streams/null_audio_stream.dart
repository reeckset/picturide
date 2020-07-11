import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class NullAudioStream extends InputStream {
  double durationSeconds;
  NullAudioStream(this.durationSeconds){
    hasAudio = true;
  }

  @override
  Future<List<String>> buildInputArgs() async => [
    '-f', 'lavfi', '-t', durationSeconds.toString(),
    '-i', 'anullsrc=channel_layout=stereo:sample_rate=44100'
  ];
}