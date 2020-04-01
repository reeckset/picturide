import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/project_storage.dart';
import 'package:picturide/model/app_preferences.dart';
import 'package:picturide/model/project.dart';

class AppPreferencesController {

  static final AppPreferencesController
    _instance = AppPreferencesController._internal();

  factory AppPreferencesController() {
    return _instance;
  }

  AppPreferencesController._internal();

  static getProjectsList() async {
    final preferences = await _getAppPreferences();
    return preferences.projectPaths;
  }

  static Future<Project> createProject(String projectName) async {
    final AppPreferences preferences = await _getAppPreferences();
    final directory = await getApplicationDocumentsDirectory();
    final String projectPath = '${directory.path}/project${preferences.createdProjectsCount}.json';
    final Project project = Project.create(projectPath);
    saveProject(project);
    preferences.createdProjectsCount++;
    preferences.projectPaths.putIfAbsent(projectPath, () => projectName);
    _saveAppPreferences(preferences);
    return project;
  }

  static Future<AppPreferences> _getAppPreferences() async {
    final path = await _getPreferencesPath();
    final file = File(path);

    if (await file.exists()){
      return AppPreferences.fromJson(
        jsonDecode(await file.readAsString())
      );
    }
    return _createAppPreferences();
  }

  static Future<AppPreferences> _createAppPreferences() async {
    final path = await _getPreferencesPath();
    final AppPreferences preferences = AppPreferences.create();
    File(path).writeAsString(jsonEncode(preferences));
    return preferences;
  }

  static _saveAppPreferences(AppPreferences preferences) async {
    final path = await _getPreferencesPath();
    File(path).writeAsString(jsonEncode(preferences));
    return preferences;
  }

  static _getPreferencesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/preferences.json';
  }
}

