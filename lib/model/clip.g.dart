// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clip _$ClipFromJson(Map<String, dynamic> json) {
  return Clip(
    json['filePath'] as String,
  )..tempoDurationPower = json['tempoDurationPower'] as int;
}

Map<String, dynamic> _$ClipToJson(Clip instance) => <String, dynamic>{
      'tempoDurationPower': instance.tempoDurationPower,
      'filePath': instance.filePath,
    };
