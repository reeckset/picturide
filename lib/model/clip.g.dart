// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clip _$ClipFromJson(Map<String, dynamic> json) {
  return Clip(
    json['filePath'] as String,
  )..tempoMultiplierDuration = json['tempoMultiplierDuration'] as int;
}

Map<String, dynamic> _$ClipToJson(Clip instance) => <String, dynamic>{
      'tempoMultiplierDuration': instance.tempoMultiplierDuration,
      'filePath': instance.filePath,
    };
