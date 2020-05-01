import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:picturide/model/clip.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditClip extends StatefulWidget {
  final Clip originalClip;
  final IjkMediaController playerController;
  final Function onChange;
  EditClip(
    this.originalClip,
    IjkMediaController this.playerController,
  { this.onChange, Key key}) : super(key: key);

  @override
  EditClipState createState() => EditClipState();
}

class EditClipState extends State<EditClip> {
  double startTimestamp = 0.0;

  _generateNewClip() async {
    final VideoInfo fileInfo = await _getController().getVideoInfo();
    final Clip editedClip = Clip.fromClip(widget.originalClip);
    editedClip.startTimestamp = startTimestamp;
    editedClip.sourceDuration = fileInfo.duration;
    return editedClip;
  }

  @override
  void setState(fn){
    super.setState(() {
      fn();
      _generateNewClip().then((clip) => widget.onChange(clip));
    });
  }

  _setStart({double position}){
    position = position == null
      ? _getController().videoInfo.currentPosition
      : position;
    this.setState(() {startTimestamp = position; });
  }

  _scrub({bool forward = true}){

    final double newValue = forward
    ? min(startTimestamp + 0.1, _getController().videoInfo.duration)
    : max(0, startTimestamp - 0.1);

    _getController().seekTo(newValue);
    _setStart(position: newValue);
  }

  _getThumbnail(double time) async {
    return await VideoThumbnail.thumbnailData(
      video: _getFilePath(),
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 50,
      timeMs: (time*1000.0).toInt(),
    );
  }

  _getFilePath() => widget.originalClip.filePath;
  _getController() => widget.playerController;

  @override
  void initState() {
    super.initState();
    this.setState(() {
      this.startTimestamp = widget.originalClip.startTimestamp;
    });
    this._setStart(position: widget.originalClip.startTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    return this._getFilePath() != null ? Column(children: [
      _setStartControls(),
    ]) : Text('');
  }

  _setStartControls(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStartThumbnail(),
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: ()=>_scrub(forward:false),
        ),
        FlatButton(
          padding: EdgeInsets.all(10.0),
          child: Text('Starting at: ${startTimestamp.toStringAsFixed(1)}s'),
          onPressed: () => _getController().seekTo(this.startTimestamp),
        ),
        IconButton(icon: Icon(Icons.shutter_speed), onPressed: _setStart,),
        IconButton(icon: Icon(Icons.arrow_right), onPressed: _scrub,),
      ]
    ,);
  }

  _buildStartThumbnail(){
    return FutureBuilder(
      future: _getThumbnail(this.startTimestamp),
      builder: (context, startThumbnail) => 
        Expanded(child:Container(
          height: 50.0,
          child: startThumbnail.data != null
            ? Image.memory(startThumbnail.data, scale: 1.0)
            : Text(''),
        )
    ));
  }
}