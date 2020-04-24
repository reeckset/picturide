import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:picturide/model/clip_time_info.dart';

part 'project.g.dart';

@JsonSerializable(nullable: true)
class Project {
  List<Clip> clips;
  List<AudioTrack> audioTracks;
  Map<String, int> outputResolution;
  String filepath;

  Project({this.filepath, this.clips, this.audioTracks, this.outputResolution});
  Project.create(this.filepath){
    this.clips = List<Clip>();
    this.audioTracks = List<AudioTrack>();
    this.outputResolution = {'w':1280, 'h':720};
  }

  Project.fromProject(Project p){
    clips = p.clips;
    audioTracks = p.audioTracks;
    outputResolution = p.outputResolution;
    filepath = p.filepath;
  }

  getClipsTimeInfo(){
    double audioTrackBeatCounter = 0;
    double durationCounter = 0;
    double audioTrackDurationCounter = 0;
    int currentAudioTrackIndex = 0;
    final Map<int, ClipTimeInfo> clipTimeInfos = Map<int, ClipTimeInfo>();
    for(int i = 0; i < clips.length; i++){
      final Clip clip = clips[i];
      final AudioTrack currentAudioTrack = 
        audioTracks.isEmpty
        ? AudioTrack(filePath: '', bpm: 1, sourceDuration: double.infinity)
        : audioTracks[currentAudioTrackIndex];
      bool isLastOfAudioTrack = false;

      double calculatedDuration = clip.getTempoDurationMultiplier()
        * currentAudioTrack.getBeatSeconds();

      if(audioTrackDurationCounter + calculatedDuration
        > currentAudioTrack.sourceDuration
        && currentAudioTrack != null){

        calculatedDuration = currentAudioTrack.sourceDuration
          - (audioTrackDurationCounter + calculatedDuration);
        audioTrackDurationCounter = 0;
        isLastOfAudioTrack = true;
      } else {
        audioTrackDurationCounter += calculatedDuration;
      }

      clipTimeInfos.addAll({i: ClipTimeInfo(
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
    return clipTimeInfos;
  }

  getAspectRatio() => outputResolution['w'] / outputResolution['h'];

  double getDuration() {
    double totalDuration = 0;
    for(Clip clip in clips){
      totalDuration +=
        60.0/audioTracks[0].bpm*clip.getTempoDurationMultiplier();
        // TODO account for different tracks
    }
    return totalDuration;
  }

  //serialization
  factory Project.fromJson(Map<String, dynamic> json) => 
    _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}