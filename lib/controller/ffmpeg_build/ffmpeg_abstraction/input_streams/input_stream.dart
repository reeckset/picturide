import 'dart:ffi';

import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class InputStream extends FFMPEGStream {

  @override
  String getAudioStreamLabel() => null;

  @override
  String getVideoStreamLabel() => null;

  @override
  String buildFilterComplex() => '';

  @override
  List<String> buildOutputArgs() => [];
}