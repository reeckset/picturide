import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class SourceFileStream extends InputStream {
  String sourceFile;
  int startTimeSeconds = 0;

  SourceFileStream(this.sourceFile);

  int inputIndex = 0;

  @override
  List<String> buildInputArgs() => [
    '-ss', startTimeSeconds.toString(),
    '-i', sourceFile
  ];

  @override
  String getAudioStreamLabel() => '$inputIndex:a';

  @override
  String getVideoStreamLabel() => '$inputIndex:v';
  
}