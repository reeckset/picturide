// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return Project(
    clips: (json['clips'] as List)
        ?.map(
            (e) => e == null ? null : Clip.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    audioTracks: (json['audioTracks'] as List)
        ?.map((e) =>
            e == null ? null : AudioTrack.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    outputResolution: (json['outputResolution'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'clips': instance.clips,
      'audioTracks': instance.audioTracks,
      'outputResolution': instance.outputResolution,
    };
