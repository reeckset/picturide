import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:path/path.dart';
import 'package:picturide/model/clip.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditClipPage extends StatefulWidget {
  final Clip originalClip;
  EditClipPage(this.originalClip, {Key key}) : super(key: key);

  @override
  EditClipPageState createState() => EditClipPageState();
}

class EditClipPageState extends State<EditClipPage> {
  final IjkMediaController _controller = IjkMediaController();
  String filepath;
  bool unsuccessfulFileSelection = false;
  double startTimestamp = 0.0;
  Uint8List startThumbnail;

  _submit(context){
    _controller.stop();
    final Clip editedClip = Clip.fromClip(widget.originalClip);
    editedClip.startTimestamp = startTimestamp;
    Navigator.pop(context, editedClip);
  }

  _setStart({double position}){
    position = position == null
      ? _controller.videoInfo.currentPosition
      : position;
    _getThumbnail(position).then((thumbnail){
      this.setState(() {
        startThumbnail = thumbnail;
      });
    });
    this.setState(() {startTimestamp = position; });
  }

  _scrub({bool forward = true}){

    final double newValue = forward
    ? min(startTimestamp + 0.1, _controller.videoInfo.duration)
    : max(0, startTimestamp - 0.1);

    _controller.seekTo(newValue);
    _setStart(position: newValue);
  }

  _getThumbnail(double time) async {
    return await VideoThumbnail.thumbnailData(
      video: filepath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 50,
      timeMs: (time*1000.0).toInt(),
    );
  }

  @override
  void initState() {
    super.initState();
    this.setState(() { 
      this.filepath = widget.originalClip.filePath; 
      this.startTimestamp = widget.originalClip.startTimestamp;
    });
    _controller.setNetworkDataSource(filepath, autoPlay: false);
    this._setStart(position: widget.originalClip.startTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Clip Editing')),
        body: this.filepath != null ? Column(children: [
              Container(
                height: 200,
                child: IjkPlayer(
                  mediaController: _controller,
                ),),
              _setStartControls(),
              Text(basename(filepath)),
              RaisedButton(
                child: Text('Confirm'),
                onPressed: () => _submit(context),
              )
        ]) : Text('Loading video file...'),
      )
    );
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
          onPressed: () => _controller.seekTo(this.startTimestamp),
        ),
        IconButton(icon: Icon(Icons.shutter_speed), onPressed: _setStart,),
        IconButton(icon: Icon(Icons.arrow_right), onPressed: _scrub,),
      ]
    ,);
  }

  _buildStartThumbnail(){
    return Expanded(child:Container(
      height: 50.0,
      child: startThumbnail != null
        ? Image.memory(startThumbnail, scale: 1.0)
        : Text(''),
    ));
  }
}