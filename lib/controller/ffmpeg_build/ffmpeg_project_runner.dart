import 'dart:math';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/audio_volume_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/fit_to_resolution_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/source_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/project.dart';


abstract class FfmpegProjectRunner {

  final int maxClips = -1;

  final int startClip;
  int endClip = 0;
  final Project project;
  Map<int, ClipTimeInfo> clipsTimeInfo;
  Map<String, int> outputResolution;
  final FlutterFFmpeg ffmpegController;

  FfmpegProjectRunner(
    this.project,
    this.ffmpegController,
    {this.startClip = 0}
  ) {
    this.clipsTimeInfo = project.getClipsTimeInfo();
    this.endClip =
      min(
        project.clips.length,
        maxClips > 0 ? startClip + maxClips : project.clips.length
      ) - 1;
    this.outputResolution = getOutputResolution();
  }

  Map<String, int> getOutputResolution();

  run();

  getNumberOfClips() => endClip - startClip + 1;

  mapActiveClips<T>(callBack) {
    final List<T> result = [];
    for(int i = startClip; i <= endClip; i++) {
      result.add(
        callBack(i-startClip, this.project.clips[i], clipsTimeInfo[i])
      );
    }
    return result;
  }

  mapActiveClipsAsync<T>(callBack) async {
    final List<T> result = [];
    for(int i = startClip; i <= endClip; i++) {
      result.add(
        await callBack(i-startClip, this.project.clips[i], clipsTimeInfo[i])
      );
    }
    return result;
  }

  Future<FFMPEGStream> getClipStream(Clip clip, ClipTimeInfo clipTimeInfo)
  async =>
    AudioVolumeFilterStream(clip.volume,
      FitToResolutionFilterStream(
        await SourceFileStream.importAsync(
          InputFile(
            clip.getFilePath(),
            durationSeconds: clipTimeInfo.duration.abs(),
            loop: true,
            startTimeSeconds: clip.startTimestamp,
          )
        ), outputResolution['w'], outputResolution['h']
      )
    );
}