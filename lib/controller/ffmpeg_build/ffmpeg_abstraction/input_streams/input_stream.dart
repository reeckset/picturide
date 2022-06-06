import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_input_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class InputStream extends FFMPEGStream {

  int inputIndex = 0;

  bool hasVideo = false;
  bool hasAudio = false;

  @override
  buildFilterComplex() async => '';

  @override
  buildOutputArgs() async => [];

  @override
  int updateInputIndicesAndReturnNext(int newStartIndex) =>
    (this.inputIndex = newStartIndex)+1;


  @override
  FFMPEGLabel getAudioStreamLabel() =>
    hasAudio ? FFMPEGInputLabel('$inputIndex:a') : null;

  @override
  FFMPEGLabel getVideoStreamLabel() =>
    hasVideo ? FFMPEGInputLabel('$inputIndex:v') : null;

  static Future<MediaInformation> getFileInfo(filePath) async => 
    (await FFprobeKit.getMediaInformation(filePath)).getMediaInformation();
}