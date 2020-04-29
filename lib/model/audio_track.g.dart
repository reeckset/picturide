// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioTrack _$AudioTrackFromJson(Map<String, dynamic> json) {
  return AudioTrack(
    filePath: json['filePath'] as String,
    bpm: json['bpm'] as int,
    sourceDuration: (json['sourceDuration'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$AudioTrackToJson(AudioTrack instance) =>
    <String, dynamic>{
      'bpm': instance.bpm,
      'filePath': instance.filePath,
      'sourceDuration': instance.sourceDuration,
    };
