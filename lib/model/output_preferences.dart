import 'package:json_annotation/json_annotation.dart';

part 'output_preferences.g.dart';

@JsonSerializable(nullable: true)
class OutputPreferences {
  Map<String, int> resolution;
  int framerate;

  OutputPreferences(
    this.resolution,
    this.framerate
  );

  OutputPreferences.create(): this(
    {'w': 1920, 'h': 1080},
    30
  );

  OutputPreferences.fromOutputPreferences(OutputPreferences o): this(
    {...o.resolution}, o.framerate
  );

  //serialization
  factory OutputPreferences.fromJson(Map<String, dynamic> json) => 
    _$OutputPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$OutputPreferencesToJson(this);
}