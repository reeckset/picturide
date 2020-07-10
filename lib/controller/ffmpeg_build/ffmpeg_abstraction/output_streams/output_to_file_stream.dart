import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_stream.dart';

class OutputToFileStream extends OutputStream {
  String file;
  bool replace;

  OutputToFileStream(this.file, streamToOutput, {this.replace = false})
    :super(streamToOutput);

  @override
  List<String> appendArgs() => [
    ...replace ? ['-y'] : [],
    file,
  ];
}