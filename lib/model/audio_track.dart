import 'package:picturide/model/file_wrapper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audio_track.g.dart';

@JsonSerializable()
class AudioTrack implements FileWrapper {
  int bpm;
  String filePath;

  AudioTrack({this.filePath, this.bpm});

  @override
  String getFilePath() => filePath;

  //serialization
  factory AudioTrack.fromJson(Map<String, dynamic> json) => 
    _$AudioTrackFromJson(json);
  Map<String, dynamic> toJson() => _$AudioTrackToJson(this);
}