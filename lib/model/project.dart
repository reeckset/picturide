import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/output_preferences.dart';

part 'project.g.dart';

@JsonSerializable(nullable: true)
class Project {
  List<Clip> clips;
  List<AudioTrack> audioTracks;
  OutputPreferences outputPreferences;
  String filepath;
  @JsonKey(ignore: true)
  Map<int, ClipTimeInfo> clipsTimeInfo;

  Project({
    this.filepath,
    this.clips,
    this.audioTracks,
    this.outputPreferences
  }){
    generateClipsTimeInfo();
    if(outputPreferences == null){
      outputPreferences = OutputPreferences.create();
    }
  }

  Project.create(filepath):this(
    filepath: filepath,
    clips: List<Clip>(),
    audioTracks: List<AudioTrack>(),
    outputPreferences: OutputPreferences.create(),
  );

  Project.fromProject(Project p):this(
    clips: p.clips,
    audioTracks: p.audioTracks,
    outputPreferences: p.outputPreferences,
    filepath: p.filepath,
  );

  Map<int, ClipTimeInfo> getClipsTimeInfo(){
    return clipsTimeInfo;
  }

  void generateClipsTimeInfo(){
    double audioTrackBeatCounter = 0,
      durationCounter = 0,
      audioTrackDurationCounter = 0;
    int currentAudioTrackIndex = 0;
    final Map<int, ClipTimeInfo> result = Map<int, ClipTimeInfo>();
    for(int i = 0; i < clips.length; i++){
      final Clip clip = clips[i];
      final AudioTrack currentAudioTrack = 
        audioTracks.isEmpty
        ? AudioTrack(filePath: '', bpm: 1, sourceDuration: double.infinity)
        : audioTracks[min(currentAudioTrackIndex, audioTracks.length-1)];

      double calculatedDuration = clip.getTempoDurationMultiplier()
        * currentAudioTrack.getBeatSeconds();

      final bool isLastOfAudioTrack =
        audioTrackDurationCounter + calculatedDuration
          > currentAudioTrack.sourceDuration
        && currentAudioTrack != null;

      if(isLastOfAudioTrack){
        calculatedDuration = currentAudioTrack.sourceDuration
          - audioTrackDurationCounter;
        audioTrackDurationCounter = 0;
      } else {
        audioTrackDurationCounter += calculatedDuration;
      }

      result.addAll({i: ClipTimeInfo(
        beatNumber: audioTrackBeatCounter,
        beats: clip.getTempoDurationMultiplier(),
        songIndex: currentAudioTrackIndex,
        startTime: durationCounter,
        duration: calculatedDuration
      )});

      if(isLastOfAudioTrack){
        audioTrackBeatCounter = 0;
        currentAudioTrackIndex++;
      }else{
        audioTrackBeatCounter += clip.getTempoDurationMultiplier();
      }
      durationCounter += calculatedDuration;

    }
    this.clipsTimeInfo = result;
  }

  getAspectRatio() =>
    outputPreferences.resolution['w'] / outputPreferences.resolution['h'];

  double getDuration() {
    final lastClipInfo = getClipsTimeInfo()[this.clips.length-1];
    return lastClipInfo.startTime+lastClipInfo.duration;
  }

  //serialization
  factory Project.fromJson(Map<String, dynamic> json) => 
    _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}