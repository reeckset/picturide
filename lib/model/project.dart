import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(nullable: true)
class Project {
  List<Clip> clips;
  List<AudioTrack> audioTracks;
  Map<String, int> outputResolution = {'w':640, 'h':360};

  Project({this.clips, this.audioTracks, this.outputResolution});
  Project.create(){
    this.clips = List<Clip>();
    this.audioTracks = List<AudioTrack>();
    this.outputResolution = {'w':640, 'h':360};
  }

  getAspectRatio() => outputResolution['w'] / outputResolution['h'];


  //serialization
  factory Project.fromJson(Map<String, dynamic> json) => 
    _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}