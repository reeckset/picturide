import 'dart:math';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/audio_volume_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/concatenate_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/fit_to_resolution_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/set_audio_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/null_audio_stream.dart';
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
  async {

    FFMPEGStream stream = FitToResolutionFilterStream(
        await SourceFileStream.importAsync(
          InputFile(
            clip.getFilePath(),
            durationSeconds: clipTimeInfo.duration,
            loop: true,
            startTimeSeconds: clip.startTimestamp,
          )
        ), outputResolution['w'], outputResolution['h']
      );

    if(!stream.hasAudioStream()){
      stream = SetAudioFilterStream(
        stream,
        NullAudioStream(clipTimeInfo.duration)
      );
    }

    return AudioVolumeFilterStream(clip.volume, stream);
  }

  Future<FFMPEGStream> getAudioTracksStream() async {
    final firstAudioIndex = clipsTimeInfo[startClip].songIndex;

    final List<FFMPEGStream> result = [];

    for(int i = firstAudioIndex; i < this.project.audioTracks.length; i++) {
      final double startTimeSeconds = (i == firstAudioIndex
            ? clipsTimeInfo[startClip].startTime : 0);
      result.add(await SourceFileStream.importAsync(
        InputFile(
          project.audioTracks[i].getFilePath(),
          startTimeSeconds: startTimeSeconds,
          durationSeconds:
            project.audioTracks[i].sourceDuration - startTimeSeconds
        )
      ));
    }

    if(result.length == 1){
      return result[0];
    }

    return ConcatenateFilterStream(result);   
  }
}