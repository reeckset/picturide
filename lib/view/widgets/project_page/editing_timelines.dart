import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/actions/project_actions/sound_editing_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/view/theme.dart';
import 'package:picturide/view/widgets/modals/ask_video_files.dart';
import 'package:picturide/view/widgets/project_page/clip_tile.dart';

class EditingTimelines extends StatefulWidget { 
  @override
  _EditingTimelinesState createState() => _EditingTimelinesState();
}

class _EditingTimelinesState extends State<EditingTimelines> {

  _getEditedClips(context, clip) async =>
    await Navigator.of(context)
    .pushNamed('/edit_clip_page', arguments:clip);

  _askAudioTrack(context) async => Navigator.of(context).pushNamed('/add_audio_page');

  _addVideoClip(context) {
    askVideoFiles().then((List<String> paths) async {
      for(String path in paths){
        final clips = await _getEditedClips(context, Clip(filePath: path));
        if(clips != null){
          for(var clip in clips){
            StoreProvider.of<AppState>(context).dispatch(
              AddClipAction(clip)
            );
        }}
    }}).catchError((_){});
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
      distinct: true,
      builder: (context, project) => _timelineViews(project, context),
    );
  }

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
                  _clipsTimeline(project, context),
                  _audioTracksTimeline(project.audioTracks, context),
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

  _clipsTimelineBarDivider() => Divider(color: accentColor, height: 1);

  _clipsTimelineBeatDivider() => Divider(
      color: lightBackgroundColor,
      indent: 10,
      endIndent: 10,
      height: 1
  );

  _clipsTimelineAudioTrackDivider(String title) => Padding(
    padding: EdgeInsets.only(bottom: 10.0),
    child: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: accentColor))
    );

  Widget _clipsTimeline(
    Project project, BuildContext context
  ) {
    final List<Widget> timelineContent = [];
    final List<Clip> clips = project.clips;
    final Map<int, ClipTimeInfo> clipsTimeInfo = project.getClipsTimeInfo();
    for(int i = 0; i < clips.length; i++){
      final Clip clip = clips[i];
      final ClipTimeInfo timeInfo = clipsTimeInfo[i];

      if(timeInfo.isFirstOfTrack()
        && project.audioTracks.length > timeInfo.songIndex){
        
        timelineContent.add(_clipsTimelineAudioTrackDivider(
          basename(project.audioTracks[timeInfo.songIndex].filePath)
        ));
      }
      if(timeInfo.isOnBarFirstBeat()){
        timelineContent.add(_clipsTimelineBarDivider());
      } else if(timeInfo.isOnBeat()){
        timelineContent.add(_clipsTimelineBeatDivider());
      }
      timelineContent.add(
        ClipTile(clip, i, timeInfo, key: ValueKey(clip),
          warning: timeInfo.isSyncedToBeat()
            ? null : 'Clip not synced with tempo')
      );
    }
    return _timeline(timelineContent);
  }

  Widget _timeline(children){
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: children
    );
  }

  Widget _audioTracksTimeline(
    List files,
    BuildContext context
  ) =>
    _timeline(files.asMap().entries.map(
          (entry) => _audioTrackTileBuilder(entry.value, entry.key, context)
      ).toList()
    );

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