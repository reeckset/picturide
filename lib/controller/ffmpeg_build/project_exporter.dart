import 'dart:io';

import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_project_runner.dart';

class ProjectExporter extends FfmpegProjectRunner {

  String tmpDir;
  String _finalOutputPath;
  final int frameRate = 30;

  ProjectExporter(project, ffmpegController)
    :super(project, ffmpegController);

  @override
  Map<String, int> getOutputResolution() => project.outputResolution;

  @override
  Future<void> run() async {
    tmpDir = (await getTemporaryDirectory()).path;

    await forEachClipAsync(_exportClip);
    await _compileAndExportClipsWithAudio();

    await GallerySaver.saveVideo(_getFinalOutputPath(), albumName:'Picturide');
    
    forEachClip((i, c, t) => File(_getClipTmpPath(i)).delete());
    File(_getFinalOutputPath()).delete();
  }

  List<String> _getOutputArgs(path) => [
    '-r', frameRate.toString(), '-f', 'mp4', '-y', path
  ];

  String _getClipTmpPath(i) => '$tmpDir/clip$i.mp4';

  _exportClip(i, clip, timeInfo) async =>
    await ffmpegController.executeWithArguments([
      ...getClipInputArgs(clip, timeInfo),
      '-filter_complex', getClipFilter(0, clip),
      '-map', '[v0]', '-map', '0:a',
      ..._getOutputArgs(_getClipTmpPath(i)),
  ]);

  _compileAndExportClipsWithAudio() async {
    final String clipsConcatInput = await _makeConcatInputFile();
    await ffmpegController.executeWithArguments([
      '-f', 'concat', '-safe', '0', 
      '-i', clipsConcatInput,
      ..._getAudioTrackInputArgs(),
      '-c:v', 'libx264', '-crf', '18',
      '-filter_complex',
      '[0:a][1:a]amix=duration=first,pan=stereo|c0<c0+c2|c1<c1+c3[a]',
      '-map', '0:v', '-map', '[a]',
      ..._getOutputArgs(_getFinalOutputPath())
    ]);
  }

  _getFinalOutputPath() {
    if(_finalOutputPath == null){
      final String currentTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
      _finalOutputPath = '$tmpDir/${currentTimestamp}.mp4';
    }
    return _finalOutputPath;
  }
  
  List<String> _getAudioTrackInputArgs() {
    return ['-i', project.audioTracks[0].getFilePath()];
  }

  _makeConcatInputFile() async {
    final String listPath = '$tmpDir/encodedClips.txt';
    String concatDemuxerList = '';
    forEachClip((i, clip, timeInfo){
      concatDemuxerList += 
        """file '${_getClipTmpPath(i)}'
        duration ${clipsTimeInfo[i].duration.toString()}
        outpoint ${clipsTimeInfo[i].duration.toString()}\n""";
    });

    await File(listPath)
      .writeAsString(concatDemuxerList);
    return listPath;
  }
}