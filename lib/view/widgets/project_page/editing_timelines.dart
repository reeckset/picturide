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
import 'package:picturide/view/pages/edit_clip_page.dart';
import 'package:picturide/view/theme.dart';
import 'package:picturide/view/widgets/project_page/clip_tile.dart';

class EditingTimelines extends StatefulWidget { 
  @override
  _EditingTimelinesState createState() => _EditingTimelinesState();
}

class _EditingTimelinesState extends State<EditingTimelines> {

  _getVideoFile() async =>
    (await FilePicker.getFile(type: FileType.video)).path;

  _editClip(context, clip) async =>
    await Navigator.of(context)
    .push(MaterialPageRoute(builder: (c) => EditClipPage(clip)));

  _askAudioTrack(context) async => Navigator.pushNamed(context, '/add_audio_page');

  _addVideoClip(context) {
    _getVideoFile().then((path) =>
      _editClip(context, Clip(filePath: path)).then((clip) {
        if(clip is Clip){
          StoreProvider.of<AppState>(context).dispatch(
            AddClipAction(clip)
          );
        }
      })
    ).catchError((){});
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

  Widget _clipTileBuilder(Clip clip, int index, _) {
    return ClipTile(clip, index);
  }

  Widget _audioTrackTileBuilder(AudioTrack audioTrack, int index, context) {
    return ListTile(
      title: Text(basename(audioTrack.filePath)),
      trailing: IconButton(icon: Icon(Icons.delete),
        onPressed: (){
          StoreProvider.of<AppState>(context)
            .dispatch(RemoveAudioAction(index));
        }),
      dense: true,
    );
  }
  

}