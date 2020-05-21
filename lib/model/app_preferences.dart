import 'package:json_annotation/json_annotation.dart';

part 'app_preferences.g.dart';

@JsonSerializable(nullable: true)
class AppPreferences {
  int createdProjectsCount;
  //projectPaths -> { filePath: projectName }
  Map<String, String> projectPaths;

  AppPreferences({this.createdProjectsCount, this.projectPaths});
  AppPreferences.create(){
    createdProjectsCount = 0;
    projectPaths = Map<String, String>();
  }
  
  //serialization
  factory AppPreferences.fromJson(Map<String, dynamic> json) => 
    _$AppPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$AppPreferencesToJson(this);
}