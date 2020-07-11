import 'dart:io';

import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_stream.dart';

// Use this only with clips of the same stream codecs and resolution
class ConcatInputStream extends InputStream {
  final List<InputFile> sourceFiles;
  final List<dynamic> firstFileStreamsInfo;

  static importAsync(List<InputFile> sourceFiles) async =>
    ConcatInputStream.fromStreamsInfo(
      sourceFiles,
      (await InputStream.getFileInfo(sourceFiles[0].file))['streams']
    );

  ConcatInputStream.fromStreamsInfo(
    this.sourceFiles,
    this.firstFileStreamsInfo
  ){
    firstFileStreamsInfo.forEach((streamInfo) { 
      hasVideo = hasVideo || streamInfo['type'] == 'video';
      hasAudio = hasAudio || streamInfo['type'] == 'audio';
    });
  }

  @override
  buildInputArgs() async {
    final String listPath = '${await getTmpDirectory()}/$inputIndex-concat-list.txt';
    File(listPath).writeAsStringSync(
      sourceFiles.map(getListEntryForFile).join('\n')
    );

    return [
      '-f', 'concat', '-safe', '0',
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