import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/view/theme.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ClipTile extends StatefulWidget {
  final Clip clip;
  final int index;
  ClipTile(this.clip, this.index, {key}):super(key: key);

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

  _getThumbnail() async {
    return await VideoThumbnail.thumbnailData(
      video: widget.clip.filePath,
      maxWidth: 72,
      quality: 20,
      timeMs: (widget.clip.startTimestamp*1000.0).toInt(),
    );
  }

  _incrementClipTempo(context, clipIndex){
    StoreProvider.of<AppState>(context)
      .dispatch(IncrementClipTempoAction(clipIndex));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 10.0),
      leading: Container(
        height: 50.0,
        width: 72.0,
        child: FutureBuilder(
          future: _getThumbnail(),
          builder: (context, thumbnail) => thumbnail.data is Uint8List
            ? Image.memory(thumbnail.data, scale: 1.0)
            : Center(child: Text(
              '?',
              style: TextStyle(color: lightBackgroundColor
            ),)),
        )
      ),
      title: Text(basename(widget.clip.filePath)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          ButtonTheme(
            minWidth: 36.0,
            height: 36.0,
            child: OutlineButton(
              child: Text(widget.clip.getTempoDurationText()),
              padding: EdgeInsets.zero,
              onPressed: () => _incrementClipTempo(context, widget.index)
            )
          ),
          _buildPopupMenu(context),
      ]),
      dense: true,
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
    final Clip editedClip = await Navigator.of(context)
      .pushNamed<dynamic>('/edit_clip_page', arguments: widget.clip);

    if (editedClip != null) {
      StoreProvider.of<AppState>(context).dispatch(
        EditClipAction(editedClip, widget.index)
      );
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