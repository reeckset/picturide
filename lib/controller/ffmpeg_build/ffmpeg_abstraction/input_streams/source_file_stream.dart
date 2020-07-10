import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class SourceFileStream extends InputStream {
  final InputFile sourceFile;
  final List<dynamic> streamsInfo;

  static importAsync(InputFile sourceFile,
    {FlutterFFprobe probeClient,
    
    }
  ) async {
    if(probeClient == null) probeClient = InputStream.flutterFFprobe;

    final Map<String, dynamic> probeInfo =
      await probeClient.getMediaInformation(sourceFile.file);

    return SourceFileStream.fromStreamsInfo(
      sourceFile,
      probeInfo['streams']
    );
  } 

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
  List<String> buildInputArgs() => [
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