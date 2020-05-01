import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:memoize/memoize.dart';
import 'package:path/path.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/preview_state.dart';
import 'package:picturide/view/theme.dart';
import 'package:picturide/view/widgets/inform_dialog.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ClipTile extends StatefulWidget {
  final Clip clip;
  final int index;
  final String warning;
  final ClipTimeInfo timeInfo;
  ClipTile(
    this.clip,
    this.index,
    this.timeInfo,
  {key, this.warning}):super(key: key);

  @override
  State<StatefulWidget> createState() => ClipTileState();
}

class ClipTileState extends State<ClipTile> with AutomaticKeepAliveClientMixin {

  Map<String, Function> popupMenuEntries;

  ClipTileState(){
    popupMenuEntries = {
      'Edit': (ctx) => _editClip(ctx),
      'Remove': (ctx) => _removeClip(ctx),
    };
  }

  static _getThumbnail(clip) async {
    return await VideoThumbnail.thumbnailData(
      video: clip.filePath,
      maxWidth: 72,
      quality: 20,
      timeMs: (clip.startTimestamp*1000.0).toInt(),
    );
  }

  _incrementClipTempo(context, clipIndex){
    StoreProvider.of<AppState>(context)
      .dispatch(IncrementClipTempoAction(clipIndex));
  }

  _isBeingPlayed(PreviewState previewState) =>
    widget.timeInfo.startTime <= previewState.currentTime
      && widget.timeInfo.startTime
        + widget.timeInfo.duration
        > previewState.currentTime;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return 
    StoreConnector<AppState, bool>(
      converter: (store) => _isBeingPlayed(store.state.preview),
      distinct: true,
      builder: (context, isBeingPlayed) => 
      Container(
        color: isBeingPlayed
          ? lightBackgroundColor : Colors.transparent,
        child: _buildListTile(context),
      )
    );
  }

  _buildListTile(context) => ListTile(
    contentPadding: EdgeInsets.only(left: 10.0),
    leading: _buildLeading(context),
    title: Text(basename(widget.clip.filePath)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _buildIncrementTempoButton(context),
        _buildPopupMenu(context),
    ]),
    dense: true,
  );

  _showWarning(context){
    informDialog('Warning', widget.warning, context);
  }

  final _buildThumbnailMemo = memo1((clip) => _buildThumbnail(clip));

  static _buildThumbnail(clip){
    return FutureBuilder(
      future: _getThumbnail(clip),
      builder: (context, thumbnail) => thumbnail.data is Uint8List
        ? Image.memory(thumbnail.data, scale: 1.0)
        : Center(child: Text(
          '?',
          style: TextStyle(color: lightBackgroundColor
        ),)),
    );
  }

  _buildLeading(context){
    return Container(
      height: 50.0,
      width: 72.0,
      child: Stack(children: [
        Center(child: _buildThumbnailMemo(widget.clip)),
        ...widget.warning != null
          ? [Center(child:
              IconButton(icon: Icon(Icons.warning),
                onPressed: () => _showWarning(context),
                color: Colors.yellow[300],
              )
            )]
          : []
      ]));
  }

  _buildIncrementTempoButton(context){
     return ButtonTheme(
        minWidth: 36.0,
        height: 36.0,
        child: OutlineButton(
          child: Text(widget.clip.getTempoDurationText()),
          padding: EdgeInsets.zero,
          onPressed: () => _incrementClipTempo(context, widget.index)
        )
      );
  }

  Widget _buildPopupMenu(context) => 
    PopupMenuButton(
      itemBuilder: (_) => popupMenuEntries.entries.map(
        (entry) => PopupMenuItem(
          value: entry.key,
          child: Text(entry.key),
        )
      ).toList(),
      onSelected: (val){
        popupMenuEntries[val](context);
      },
    );

  _editClip(context) async {
    final List<Clip> editedClips = await Navigator.of(context)
      .pushNamed<dynamic>('/edit_clip_page', arguments: widget.clip);

    if (editedClips != null) {
      StoreProvider.of<AppState>(context).dispatch(
        EditClipAction(editedClips[0], widget.index)
      );
      for(int i = 1; i < editedClips.length; i++){
        StoreProvider.of<AppState>(context).dispatch(
          AddClipAction(editedClips[i], index: widget.index)
        );
      }
    }
  }

  _removeClip(context) async {
    StoreProvider.of<AppState>(context).dispatch(
      RemoveClipAction(widget.index)
    );
  }

  @override
  bool get wantKeepAlive => true;
  
}