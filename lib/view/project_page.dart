import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/file_wrapper.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/theme.dart';
import 'package:picturide/view/video_preview.dart';

enum EditingMode { audio, video }

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  final Project _projectState = Project();
  EditingMode editingMode = EditingMode.video;

  askClipFile() async => FilePicker.getFile(type: FileType.video);

  askAudioTrack(context) async => Navigator.pushNamed(context, '/add_audio_page');

  _addVideoClip() {
    askClipFile().then((clipFile) {
      if(clipFile is File){
        setState(() { _projectState.clips.add(Clip(clipFile));});
      }
    });
  }

  _addAudioTrack(context){
    askAudioTrack(context)
      .then((track){
        if(track is AudioTrack) {
          this.setState((){
            _projectState.audioTracks.add(track);
          });
        }
      });
  }

  _isEditingAudio() => editingMode == EditingMode.audio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        child:
          Column(children: [
            Container(
              height: 150,
              child:
                _projectState.clips.isNotEmpty
                  ? VideoPreview(_projectState)
                  : Center(child: Text('Add a video!')),
            ),
            _editingModeSelector(),
            _isEditingAudio() ? _sourceFilesExplorer(_projectState.audioTracks)
            : _sourceFilesExplorer(_projectState.clips)
          ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _isEditingAudio()
          ? _addAudioTrack(context) : _addVideoClip(),
        tooltip: 'Add ${_isEditingAudio() ? 'audio track' : 'video clip' }',
        child: Icon(_isEditingAudio() ? Icons.music_note : Icons.local_movies ),
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
                    child: Text(basename(clipOrAudio.file.path))
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