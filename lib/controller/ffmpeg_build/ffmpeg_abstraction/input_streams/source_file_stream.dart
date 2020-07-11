import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class SourceFileStream extends InputStream {
  final InputFile sourceFile;
  final List<dynamic> streamsInfo;

  static importAsync(InputFile sourceFile) async =>
    SourceFileStream.fromStreamsInfo(
      sourceFile,
      (await InputStream.getFileInfo(sourceFile.file))['streams']
    );

  SourceFileStream.fromStreamsInfo(
    this.sourceFile,
    this.streamsInfo
  ){
    streamsInfo.forEach((streamInfo) { 
      hasVideo = hasVideo || streamInfo['type'] == 'video';
      hasAudio = hasAudio || streamInfo['type'] == 'audio';
    });
  }

  @override
  Future<List<String>> buildInputArgs() async => [
    ...(sourceFile.startTimeSeconds != null
      ? ['-ss', sourceFile.startTimeSeconds.toString()]
      : []),
    ...(sourceFile.durationSeconds != null
      ? ['-t', sourceFile.durationSeconds.toString()]
      : []),
    ...(sourceFile.loop ? ['-stream_loop', '-1'] : []),
    '-i', sourceFile.file
  ];
}