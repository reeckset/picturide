import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

class OutputToFileStream extends OutputStream {
  String file;
  bool replace;

  OutputToFileStream(
    this.file,
    FFMPEGStream streamToOutput,
    {this.replace = false}
  ):super(streamToOutput);

  @override
  List<String> appendArgs() => [
    ...replace ? ['-y'] : [],
    file,
  ];
}