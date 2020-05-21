import 'dart:math';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/model/audio_track.dart';
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

  forEachClip(callBack) {
    for(int i = startClip; i <= endClip; i++) {
      callBack(i, this.project.clips[i], clipsTimeInfo[i]);
    }
  }

  forEachClipAsync(callBack) async {
    for(int i = startClip; i <= endClip; i++) {
      await callBack(i, this.project.clips[i], clipsTimeInfo[i]);
    }
  }

  List<String> getClipInputArgs(
    Clip clip, ClipTimeInfo clipTimeInfo
  ) => [
      '-ss', clip.startTimestamp.toString(),
      '-t', clipTimeInfo.duration.abs().toString(),
      '-stream_loop', '-1',
      '-i', clip.getFilePath(),
  ];

  List<String> buildAudioInputArgsForClip(
    ClipTimeInfo clipTimeInfo, Project project
  ){
    final AudioTrack audio = project.audioTracks[clipTimeInfo.songIndex];
    final double audioStartTime =
      clipTimeInfo.beatNumber * audio.getBeatSeconds();

    return [
      '-ss', audioStartTime.toString(),
      '-i', audio.getFilePath()
    ];
  }

  String getClipFilter(int i, Clip clip){
    return """[$i:v]
      scale=${outputResolution['w']}:${outputResolution['h']}
      :force_original_aspect_ratio=decrease,setsar=1,
      pad=${outputResolution['w']}:${outputResolution['h']}:(ow-iw)/2:(oh-ih)/2
      ,setpts=PTS-STARTPTS
      [v$i]""";
  }

}