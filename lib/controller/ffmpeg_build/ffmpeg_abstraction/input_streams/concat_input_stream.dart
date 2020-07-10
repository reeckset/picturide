import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

// Use this only with clips of the same stream codecs and resolution
class ConcatInputStream extends InputStream {
  final List<InputFile> sourceFiles;
  final List<dynamic> firstFileStreamsInfo;
 
  static String tmpDirectory;

  static importAsync(
    List<InputFile> sourceFiles,
    {FlutterFFprobe probeClient, String tmpDir}
  ) async {
    if(probeClient == null) probeClient = InputStream.flutterFFprobe;

    final Map<String, dynamic> probeInfo =
      await probeClient.getMediaInformation(sourceFiles[0].file);

    tmpDirectory = tmpDir != null
      ? tmpDir : (await getTemporaryDirectory()).path;

    return ConcatInputStream.fromStreamsInfo(sourceFiles,
      probeInfo['streams']);
  } 

  ConcatInputStream.fromStreamsInfo(
    this.sourceFiles,
    this.firstFileStreamsInfo,
  ){
    firstFileStreamsInfo.forEach((streamInfo) { 
      hasVideo = hasVideo || streamInfo['type'] == 'video';
      hasAudio = hasAudio || streamInfo['type'] == 'audio';
    });
  }

  @override
  List<String> buildInputArgs() {
    final String listPath = '$tmpDirectory/$inputIndex-concat-list.txt';
    File(listPath).writeAsStringSync(
      sourceFiles.map(getListEntryForFile).join('\n')
    );

    return [
      '-i', listPath
    ];
  }

  String getListEntryForFile(InputFile inputFile) =>
    'file \'${inputFile.file}\''
    + (inputFile.durationSeconds != null 
      ? '\nduration ${inputFile.durationSeconds}'
        + '\noutpoint ${inputFile.durationSeconds}'
      : '');

}