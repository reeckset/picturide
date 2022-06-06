import 'package:ffmpeg_kit_flutter/stream_information.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class SourceFileStream extends InputStream {
  final InputFile sourceFile;
  final List<dynamic> streamsInfo;

  static importAsync(InputFile sourceFile) async =>
    SourceFileStream.fromStreamsInfo(
      sourceFile,
      (await InputStream.getFileInfo(sourceFile.file)).getStreams()
    );

  SourceFileStream.fromStreamsInfo(
    this.sourceFile,
    List<StreamInformation> this.streamsInfo
  ){
    streamsInfo.forEach((streamInfo) { 
      hasVideo = hasVideo || (streamInfo as StreamInformation).getType() == 'video';
      hasAudio = hasAudio || (streamInfo as StreamInformation).getType() == 'audio';
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