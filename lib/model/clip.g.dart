// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clip _$ClipFromJson(Map<String, dynamic> json) {
  return Clip(
    filePath: json['filePath'] as String,
    tempoDurationPower: json['tempoDurationPower'] as int,
    startTimestamp: (json['startTimestamp'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ClipToJson(Clip instance) => <String, dynamic>{
      'tempoDurationPower': instance.tempoDurationPower,
      'startTimestamp': instance.startTimestamp,
      'filePath': instance.filePath,
    };
