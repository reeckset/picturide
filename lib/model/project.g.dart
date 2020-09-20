// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return Project(
    filepath: json['filepath'] as String,
    clips: (json['clips'] as List)
        ?.map(
            (e) => e == null ? null : Clip.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    audioTracks: (json['audioTracks'] as List)
        ?.map((e) =>
            e == null ? null : AudioTrack.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    outputPreferences: json['outputPreferences'] == null
        ? null
        : OutputPreferences.fromJson(
            json['outputPreferences'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'clips': instance.clips,
      'audioTracks': instance.audioTracks,
      'outputPreferences': instance.outputPreferences,
      'filepath': instance.filepath,
    };
