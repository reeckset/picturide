import 'dart:convert';
import 'dart:io';

import 'package:picturide/model/project.dart';

saveProject(Project project) async {
  return File(project.filepath).writeAsString(jsonEncode(project));
}

Future<Project> getProject(String filepath) async {
  final projectFile = File(filepath);

  if (await projectFile.exists()){
    return Project.fromJson(jsonDecode(await projectFile.readAsString()));
  }
  throw InvalidProjectFileException();
}

class InvalidProjectFileException implements Exception{
  String errMsg() => 'The project file did not have the right structure'; 
}