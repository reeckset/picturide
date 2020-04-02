import 'package:picturide/model/file_wrapper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clip.g.dart';

@JsonSerializable()
class Clip implements FileWrapper {
  int tempoMultiplierDuration = 1;
  String filePath;

  Clip(this.filePath);

  @override
  String getFilePath() => filePath;

  //serialization
  factory Clip.fromJson(Map<String, dynamic> json) => 
    _$ClipFromJson(json);
  Map<String, dynamic> toJson() => _$ClipToJson(this);
}