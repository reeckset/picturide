import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

class SourceFileStream extends InputStream {
  final String sourceFile;
  int startTimeSeconds = 0;
  final List<dynamic> streamsInfo;
  static final FlutterFFprobe flutterFFprobe = FlutterFFprobe();

  bool _hasVideoStream = false;
  bool _hasAudioStream = false;
 

  static importAsync(String sourceFile, {FlutterFFprobe probeClient}) async {
    if(probeClient == null) probeClient = flutterFFprobe;

    final Map<String, dynamic> probeInfo =
      await probeClient.getMediaInformation(sourceFile);

    return SourceFileStream.fromStreamsInfo(sourceFile,
      probeInfo['streams']);
  } 

  SourceFileStream.fromStreamsInfo(
    this.sourceFile,
    this.streamsInfo,
  ){
    streamsInfo.forEach((streamInfo) { 
      _hasVideoStream = _hasVideoStream || streamInfo['type'] == 'video';
      _hasAudioStream = _hasAudioStream || streamInfo['type'] == 'audio';
    });
  }

  @override
  List<String> buildInputArgs() => [
    '-ss', startTimeSeconds.toString(),
    '-i', sourceFile
  ];

  @override
  String getAudioStreamLabel() => _hasAudioStream ? '$inputIndex:a' : null;

  @override
  String getVideoStreamLabel() => _hasVideoStream ? '$inputIndex:v' : null;
  

}