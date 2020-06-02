import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mockito/mockito.dart';

class FlutterFFmpegMock extends Mock with FlutterFFmpeg {
  @override
  Future<int> executeWithArguments(List<String> arguments) async {   
    final process = await Process.start('ffmpeg', arguments, runInShell: true);
    // for debug:
    // process.stderr.transform(utf8.decoder).listen((event){ print(event); });
    // process.stdout.transform(utf8.decoder).listen((event){ print(event); });
    return await process.exitCode;
  }
}