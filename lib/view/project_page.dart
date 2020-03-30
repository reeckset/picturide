import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/video_preview.dart';

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  final Project _projectState = Project();

  getClipFile() async => FilePicker.getFile(type: FileType.video);

  void _selectAndAddFile() {
    getClipFile().then((clipFile) {
      setState(() { _projectState.clips.add(Clip(clipFile));});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
            _projectState.clips.isNotEmpty
              ? VideoPreview(_projectState)
              : Text('Add a video!'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Files added:'),
                Text('${_projectState.clips.length}'),
              ],
            ),
          Expanded(
            child: ListView(
              children: _projectState.clips.map(
                  (Clip clip) => Text(clip.file.path)
                ).toList()
            )
          )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectAndAddFile,
        tooltip: 'Add video clip',
        child: Icon(Icons.add),
      ),
    );
  }
}