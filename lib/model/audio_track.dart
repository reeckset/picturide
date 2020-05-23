import 'package:json_annotation/json_annotation.dart';

part 'audio_track.g.dart';

@JsonSerializable()
class AudioTrack {
  int bpm;
  String filePath;
  double sourceDuration;

  AudioTrack({
    this.filePath,
    this.bpm,
    this.sourceDuration
  });

  String getFilePath() => filePath;

  double getBeatSeconds(){
    return 60.0/this.bpm.toDouble();
  }

  //serialization
  factory AudioTrack.fromJson(Map<String, dynamic> json) => 
    _$AudioTrackFromJson(json);
  Map<String, dynamic> toJson() => _$AudioTrackToJson(this);
}