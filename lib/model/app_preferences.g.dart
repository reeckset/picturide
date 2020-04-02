// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppPreferences _$AppPreferencesFromJson(Map<String, dynamic> json) {
  return AppPreferences(
    createdProjectsCount: json['createdProjectsCount'] as int,
    projectPaths: (json['projectPaths'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$AppPreferencesToJson(AppPreferences instance) =>
    <String, dynamic>{
      'createdProjectsCount': instance.createdProjectsCount,
      'projectPaths': instance.projectPaths,
    };
