import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

abstract class FFMPEGStream {

  FFMPEGStream sourceStream;

  FFMPEGStream({this.sourceStream});

  static FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  static String forceTmpDirectory;

  Future<List<String>> build() async {
    sourceStream.updateInputIndicesAndReturnNext(0);
    final filterComplex = (await buildFilterComplex()).replaceAll(RegExp(r'\n|\s'), '');
    return [
      ...await buildInputArgs(),
      ...filterComplex != ''
        ? ['-filter_complex', filterComplex]
        : [],
      ...await buildMappingArgs(),
      ...await buildOutputArgs()
    ];
  }
  
  Future<List<String>> buildInputArgs() async {
    if(sourceStream == null) {
      throw Exception(
        'Input behavior not overriden for Stream with no sourceStream'
      );
    }
    return await sourceStream.buildInputArgs();
  }
  Future<String> buildFilterComplex() async {
    if(sourceStream == null) {
      throw Exception(
        'Filter Stream has no source stream'
      );
    }
    return await sourceStream.buildFilterComplex();
  }

  Future<List<String>> buildOutputArgs() async {
    if(sourceStream == null) {
      throw Exception(
        'Output Stream has no source stream'
      );
    }
    return await sourceStream.buildOutputArgs();
  }

  Future<List<String>> buildMappingArgs() async {
    if(sourceStream == null) {
      return [];
    }
    return await sourceStream.buildMappingArgs();
  }

  bool hasVideoStream(){
    return getVideoStreamLabel() != null;
  }

  bool hasAudioStream(){
    return getAudioStreamLabel() != null;
  }

  FFMPEGLabel getVideoStreamLabel() {
    return sourceStream.getVideoStreamLabel();
  }

  FFMPEGLabel getAudioStreamLabel() {
    return sourceStream.getAudioStreamLabel();
  }

  int updateInputIndicesAndReturnNext(int newStartIndex) {
    return sourceStream.updateInputIndicesAndReturnNext(newStartIndex);
  }

  Future<String> getTmpDirectory() async {
    return forceTmpDirectory == null
      ? (await getTemporaryDirectory()).path
      : forceTmpDirectory;
  }

}