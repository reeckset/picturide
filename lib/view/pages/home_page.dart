import 'package:flutter/material.dart';
import 'package:picturide/controller/app_preferences_controller.dart';
import 'package:picturide/controller/project_storage.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/view/pages/project_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Map<String, String> projectPaths = Map<String, String>();

  @override
  initState(){
    super.initState();

    AppPreferencesController.getProjectsList().then((projectPaths){
      setState(() {
        this.projectPaths = projectPaths;
      });
    });
  }

  _createNewProject() async {
    final String projectName = 'TESTE';
    final Project project = 
    await AppPreferencesController.createProject(projectName);
    this.setState((){
      this.projectPaths.putIfAbsent(project.filepath, () => projectName);
    });
    _openProject(project.filepath);
  }

  _openProject(String projectPath) async {
    final Project project = await getProject(projectPath);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ProjectPage(project: project)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Picturide!')),
      body: _listProjects(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProject,
        tooltip: 'Create New Project',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listProjects(){
    return ListView(
      children: this.projectPaths.entries.map(
          (entry) => 
            RaisedButton(
              child: Text(entry.value),
              onPressed: () => _openProject(entry.key),
            )
        ).toList()
    );
  }
}