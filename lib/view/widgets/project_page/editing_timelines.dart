import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/actions/project_actions/sound_editing_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/view/theme.dart';

class EditingTimelines extends StatefulWidget { 
  @override
  _EditingTimelinesState createState() => _EditingTimelinesState();
}

class _EditingTimelinesState extends State<EditingTimelines> {

  _incrementClipTempo(context, clipIndex){
    StoreProvider.of<AppState>(context)
      .dispatch(IncrementClipTempoAction(clipIndex));
  }

  _askClipFile() async => (await FilePicker.getFile(type: FileType.video)).path;

  _askAudioTrack(context) async => Navigator.pushNamed(context, '/add_audio_page');

  _addVideoClip(context) {
    _askClipFile().then((clipFile) {
      if(clipFile is String){
        StoreProvider.of<AppState>(context).dispatch(
          AddClipAction(Clip(clipFile))
        );
      }
    });
  }

  _addAudioTrack(context){
    _askAudioTrack(context)
      .then((track){
        if(track is AudioTrack) {
          StoreProvider.of<AppState>(context).dispatch(
            AddAudioAction(track)
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Project>(
      converter: (store) => store.state.history.project,
      builder: (context, project) => _timelineViews(project, context),
    );
  }

  Widget _sourceFilesExplorer<T>(
    List<T> files,
    Widget Function(T, int, BuildContext) tileBuilder,
    BuildContext context
  ) =>
    ListView(
      padding: EdgeInsets.all(10.0),
      children: files.asMap().entries.map(
          (entry) => tileBuilder(entry.value, entry.key, context)
      ).toList()
    );

  Widget _timelineViews(Project project, context) => 
    DefaultTabController(
      length: 2,
      child: Expanded(
        child: Column(
          children: [
            Container(
              color: lightBackgroundColor,
              child: TabBar(labelPadding: EdgeInsets.zero,
                  tabs: [
                    _timelineTab('Video', Icons.local_movies,
                      () => _addVideoClip(context)),
                    _timelineTab('Audio', Icons.music_note,
                      () => _addAudioTrack(context), isLeft: false),
                  ],  
                ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _sourceFilesExplorer(project.clips, _clipTileBuilder,context),
                  _sourceFilesExplorer(
                    project.audioTracks, _audioTrackTileBuilder, context
                  ),
                ]
              )
            )
          ]
        )
      )
  );

  Widget _timelineTab(String title, IconData icon, onAdd,{bool isLeft = true}) {
    final addBtn = Tooltip(message: 'Add ' + title, child: IconButton(
      icon: Icon(Icons.add_circle_outline), onPressed: onAdd));
    return Tab(
      child: Row(
        children: [
          ...(isLeft ? [addBtn] : []),
          Expanded(child: Row(
            children: [
              Icon(icon), 
              Text(' ' + title)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )),
          ...(isLeft ? [] : [addBtn]),
      ])
    );
  }

  Widget _clipTileBuilder(Clip clip, int index, context) {

    return ListTile(
      contentPadding: EdgeInsets.only(left: 10.0),
      title: Text(basename(clip.filePath)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          ButtonTheme(
            minWidth: 36.0,
            height: 36.0,
            child: OutlineButton(
              child: Text(clip.getTempoDurationText()),
              padding: EdgeInsets.zero,
              onPressed: () => _incrementClipTempo(context, index)
            )
          ),
          IconButton(icon: Icon(Icons.more_vert), onPressed: (){}),
      ]),
      dense: true,
    );
  }

  Widget _audioTrackTileBuilder(AudioTrack audioTrack, int index, context) {
    return ListTile(
      title: Text(basename(audioTrack.filePath)),
      trailing: IconButton(icon: Icon(Icons.delete)),
      dense: true,
    );
  }
  

}