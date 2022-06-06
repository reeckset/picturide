import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/format_audio_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/mix_audio_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/concat_input_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/null_audio_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/add_output_properties_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_to_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_project_runner.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';

class ProjectExporter extends FfmpegProjectRunner {

  String tmpDir;
  String _finalOutputPath;
  Function progressListener;
  
  String phase = 'Waiting to export...';
  int framesInPhase = 0;

  ProjectExporter(project, ffmpegController, {this.progressListener})
    : super(project, ffmpegController);

  @override
  Map<String, int> getOutputResolution() =>
    project.outputPreferences.resolution;

  int _getFrameRate() =>
    project.outputPreferences.framerate;

  getTmpDirectory() async => (await getTemporaryDirectory()).path;

  @override
  Future<void> run() async {
    _registerProgressListener();
    tmpDir = await getTmpDirectory();

    await mapActiveClipsAsync(_exportClip);
    await _compileAndExportClipsWithAudio();
    await saveToGallery(_getFinalOutputPath());
    
    mapActiveClips((i, c, t) => File(_getClipTmpPath(i)).delete());
    File(_getFinalOutputPath()).delete();
    _removeProgressListener();
  }

  List<String> _getOutputArgs() => [
    '-r', _getFrameRate().toString(), '-f', 'mp4'
  ];

  String _getClipTmpPath(i) => '$tmpDir/clip$i.mp4';

  _exportClip(i, Clip clip, timeInfo) async {
    final stream = OutputToFileStream(
      _getClipTmpPath(i),
      AddOutputPropertiesStream(
        ['-video_track_timescale', '29971',
        '-ac', '1', '-fflags', '+genpts',
        '-async', '1', ..._getOutputArgs()],
        await getClipStream(clip, timeInfo),
      ),
      replace: true,
    );

    _setPhaseExportClip(i, timeInfo);

    await FFmpegKit.executeWithArguments(await stream.build());
  }

  _compileAndExportClipsWithAudio() async {
    _setPhaseCompileClips();

    final stream = OutputToFileStream(
      _getFinalOutputPath(),
      AddOutputPropertiesStream(
        ['-c:v', 'libx264', '-crf', '18', ..._getOutputArgs()],
        FormatAudioFilterStream(
          MixAudioFilterStream([
            NullAudioStream(project.getDuration()),
            await ConcatInputStream.importAsync(
              mapActiveClips<InputFile>((i, clip, timeInfo) =>
                InputFile(
                  _getClipTmpPath(i),
                  durationSeconds: clipsTimeInfo[i].duration
                )
              )
            ),
            await getAudioTracksStream(),
          ]),
        ),
      ),
      replace: true
    );

    await FFmpegKit.executeWithArguments(await stream.build());
  }

  _getFinalOutputPath() {
    if(_finalOutputPath == null){
      final String currentTimestamp =
        DateTime.now().millisecondsSinceEpoch.toString();
      _finalOutputPath = '$tmpDir/${currentTimestamp}.mp4';
    }
    return _finalOutputPath;
  }

  saveToGallery(String tmpPath) async {
    _setPhaseSaveGallery();
    await GallerySaver.saveVideo(tmpPath, albumName:'Picturide');
  }

  _registerProgressListener() {
    if(this.progressListener == null) return;

    FFmpegKitConfig.enableStatisticsCallback(
      (Statistics statistics){
        this.progressListener(
          statistics.getVideoFrameNumber()/this.framesInPhase,
          phase
        );
    });
  }

  _removeProgressListener() {
    FFmpegKitConfig.disableStatistics();
  }

  _setPhaseExportClip(int i, ClipTimeInfo timeInfo){
    this.phase = 'Encoding clip ${i+1} of ${getNumberOfClips()}';
    this.framesInPhase = (timeInfo.duration * _getFrameRate()).toInt();
  }

  _setPhaseCompileClips() {
    this.phase = 'Joining clips together and adding audio tracks...';
    this.framesInPhase = _getTotalNumberOfFrames();
  }

  _setPhaseSaveGallery() {
    this.phase = 'Saving final file to device gallery...';
    this.framesInPhase = 1;
  }

  _getTotalNumberOfFrames() => (project.getDuration()*_getFrameRate()).toInt();

}