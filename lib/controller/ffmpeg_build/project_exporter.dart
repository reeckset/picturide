import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_project_runner.dart';
import 'package:picturide/model/clip_time_info.dart';

class ProjectExporter extends FfmpegProjectRunner {

  final FlutterFFmpegConfig _flutterFFmpegConfig;
  String tmpDir;
  String _finalOutputPath;
  final int frameRate = 30;
  Function progressListener;
  
  String phase = 'Waiting to export...';
  int framesInPhase = 0;

  ProjectExporter(project, ffmpegController, {this.progressListener})
    : _flutterFFmpegConfig = (
      progressListener != null ? FlutterFFmpegConfig() : null),
    super(project, ffmpegController);

  @override
  Map<String, int> getOutputResolution() => project.outputResolution;

  getTmpDirectory() async => (await getTemporaryDirectory()).path;

  @override
  Future<void> run() async {
    _registerProgressListener();
    tmpDir = await getTmpDirectory();

    await forEachClipAsync(_exportClip);
    await _compileAndExportClipsWithAudio();
    await saveToGallery(_getFinalOutputPath());
    
    forEachClip((i, c, t) => File(_getClipTmpPath(i)).delete());
    File(_getFinalOutputPath()).delete();
    _removeProgressListener();
  }

  List<String> _getOutputArgs(path) => [
    '-r', frameRate.toString(), '-f', 'mp4', '-y', path
  ];

  String _getClipTmpPath(i) => '$tmpDir/clip$i.mp4';

  _exportClip(i, clip, timeInfo) async {
    _setPhaseExportClip(i, timeInfo);
    await ffmpegController.executeWithArguments([
      ...getClipInputArgs(clip, timeInfo),
      '-filter_complex', getClipFilter(0, clip),
      '-map', '[v0]', '-map', '0:a',
      ..._getOutputArgs(_getClipTmpPath(i)),
    ]);
  }

  _compileAndExportClipsWithAudio() async {
    _setPhaseCompileClips();
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
    File(clipsConcatInput).delete();
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

    await File(listPath).writeAsString(concatDemuxerList);
    return listPath;
  }

  saveToGallery(String tmpPath) async {
    _setPhaseSaveGallery();
    await GallerySaver.saveVideo(tmpPath, albumName:'Picturide');
  }

  _registerProgressListener() {
    if(this.progressListener == null) return;

    _flutterFFmpegConfig.enableStatisticsCallback(
      (int time,
      int size,
      double bitrate,
      double speed,
      int videoFrameNumber,
      double videoQuality,
      double videoFps){
        this.progressListener(
          videoFrameNumber/this.framesInPhase,
          phase
        );
    });
  }

  _removeProgressListener() {
    _flutterFFmpegConfig?.disableStatistics();
  }

  _setPhaseExportClip(int i, ClipTimeInfo timeInfo){
    this.phase = 'Encoding clip ${i+1} of ${getNumberOfClips()}';
    this.framesInPhase = (timeInfo.duration * this.frameRate).toInt();
  }

  _setPhaseCompileClips() {
    this.phase = 'Joining clips together and adding audio tracks...';
    this.framesInPhase = _getTotalNumberOfFrames();
  }

  _setPhaseSaveGallery() {
    this.phase = 'Saving final file to device gallery...';
    this.framesInPhase = 1;
  }

  _getTotalNumberOfFrames() => (project.getDuration()*this.frameRate).toInt();

}