// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPreferences _$OutputPreferencesFromJson(Map<String, dynamic> json) {
  return OutputPreferences(
    (json['resolution'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    json['framerate'] as int,
  );
}

Map<String, dynamic> _$OutputPreferencesToJson(OutputPreferences instance) =>
    <String, dynamic>{
      'resolution': instance.resolution,
      'framerate': instance.framerate,
    };
