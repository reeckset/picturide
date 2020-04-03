import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/file_wrapper.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/actions/project_actions/sound_editing_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/view/theme.dart';
import 'package:picturide/view/widgets/ask_options.dart';
import 'package:picturide/view/widgets/project_page/editing_toolbar.dart';
import 'package:picturide/view/widgets/video_preview.dart';

enum EditingMode { audio, video }

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key}) : super(key: key);

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  EditingMode editingMode = EditingMode.video;

  askClipFile() async => (await FilePicker.getFile(type: FileType.video)).path;

  askAudioTrack(context) async => Navigator.pushNamed(context, '/add_audio_page');

  _addVideoClip(context) {
    askClipFile().then((clipFile) {
      if(clipFile is String){
        StoreProvider.of<AppState>(context).dispatch(
          AddClipAction(Clip(clipFile))
        );
      }
    });
  }

  _addAudioTrack(context){
    askAudioTrack(context)
      .then((track){
        if(track is AudioTrack) {
          StoreProvider.of<AppState>(context).dispatch(
            AddAudioAction(track)
          );
        }
      });
  }

  _isEditingAudio() => editingMode == EditingMode.audio;

  _confirmWantsToLeave(context) async {
    if(StoreProvider.of<AppState>(context)
      .state.history.savingStatus == SavingStatus.saved){
      return true;
    }
    
    final int option = await askOptions(
      'You are leaving this project',
      'Do you want to save?',
      ['Cancel', 'No', 'Yes'],
      context
    );
    if(option == 0) return false;
    if(option == 2) {
      StoreProvider.of<AppState>(context)
        .dispatch(saveCurrentProjectActionCreator());
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _confirmWantsToLeave(context),
      child: StoreConnector<AppState, Project>(
          converter: (store) => store.state.history.project,
          builder: (context, Project project) =>
            _getPageContent(context, project)
        )
    );
  }

  _getPageContent(context, Project project){
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 10.0),
          child:
            project == null
            ? Text('Loading project...')
            : Column(children: [
              Container(
                height: mediaQuery.size.width / project.getAspectRatio(),
                child:
                  project.clips.isNotEmpty
                    ? VideoPreview(project)
                    : Center(child: Text('Add a video!')),
              ),
              EditingToolbar(),
              _editingModeSelector(),
              _isEditingAudio()
              ? _sourceFilesExplorer(project.audioTracks)
              : _sourceFilesExplorer(project.clips)
            ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _isEditingAudio()
            ? _addAudioTrack(context) : _addVideoClip(context),
          tooltip: 'Add ${_isEditingAudio() ? 'audio track' : 'video clip' }',
          child: Icon(
            _isEditingAudio() ? Icons.music_note : Icons.local_movies
          ),
        ),
      );
  }

  Widget _sourceFilesExplorer(List<FileWrapper> files) =>
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(10.0),
            children: files.map(
                (FileWrapper clipOrAudio) => 
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(basename(clipOrAudio.getFilePath()))
                  )
            ).toList()
          )
        );

  Widget _editingModeSelector() => 
    Container(
      color: lightBackgroundColor,
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Editing: ${editingMode.toString().split('.').last}'),
          Switch(
            value: _isEditingAudio(),
            onChanged: (val) => setState((){
                if(val){
                  this.editingMode = EditingMode.audio;
                }else{
                  this.editingMode = EditingMode.video;
                }
            }),
            inactiveThumbColor: themeData.toggleableActiveColor,
            inactiveTrackColor: themeData.toggleableActiveColor.withAlpha(128),
          )
        ]
      )
    );
    
}