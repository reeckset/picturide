import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/theme.dart';
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
  final _volumeSliderScale = 500; //how far down the volume slider is 1.00x
  final _maxVolume = 10;

  double startTimestamp = 0.0;
  double volume = 1;

  _generateNewClip() async {
    final VideoInfo fileInfo = await _getController().getVideoInfo();
    final Clip editedClip = Clip.fromClip(widget.originalClip);
    editedClip.startTimestamp = startTimestamp;
    editedClip.sourceDuration = fileInfo.duration;
    editedClip.volume = volume;
    return editedClip;
  }

  @override
  void setState(fn){
    super.setState(() {
      fn();
      _generateNewClip().then((clip) => widget.onChange(clip));
    });
  }

  @override
  void initState() {
    super.initState();
    this.setState(() {
      this.startTimestamp = widget.originalClip.startTimestamp;
      this.volume = widget.originalClip.volume;
    });
    this._setStart(position: widget.originalClip.startTimestamp);
  }

  _setStart({double position}){
    position = position == null
      ? _getController().videoInfo.currentPosition
      : position;
    this.setState(() {startTimestamp = position; });
  }

  void _setVolume(double volume){
    this.setState(() { this.volume = volume; });
  }

  _getSliderVolume() =>
    max(0.0, 
      log((this.volume + (_maxVolume/_volumeSliderScale))
        / (1+1/_volumeSliderScale)
        * (_volumeSliderScale/_maxVolume))
      / log(_volumeSliderScale)
    );

  _setVolumeFromSlider(double volume){
    this._setVolume(num.parse(
      (pow(_volumeSliderScale, volume)
        / (_volumeSliderScale/_maxVolume)
        * (1+1/_volumeSliderScale)
      - _maxVolume/_volumeSliderScale)
    .toStringAsFixed(2)));
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
  Widget build(BuildContext context) {
    return this._getFilePath() != null ? ExpansionTile(
      backgroundColor: lightBackgroundColor,
      leading: _buildStartThumbnail(),
      title: Text('Starting at: ${startTimestamp.toStringAsFixed(1)}s'),
      children: _editingControls(),
      initiallyExpanded: true,
    ) : Text('');
  }

  List<Widget> _editingControls() => [
    _startControls(),
    _volumeControls(),
  ];

  _startControls(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: ()=>_scrub(forward:false),
        ),
        FlatButton(
          padding: EdgeInsets.all(10.0),
          child: Text('Go to clip start'),
          onPressed: () => _getController().seekTo(this.startTimestamp),
        ),
        RaisedButton(child: Text('Set start'), onPressed: _setStart,),
        IconButton(icon: Icon(Icons.arrow_right), onPressed: _scrub,),
      ]
    ,);
  }

  _volumeControls() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(volume > 0 ? Icons.volume_up : Icons.volume_off),
          onPressed: ()=>volume > 0 ? _setVolume(0) : _setVolume(1)),
        Text('${this.volume.toStringAsFixed(2)}x'),
        Slider(
          onChanged: _setVolumeFromSlider,
          value: _getSliderVolume(),
          min: 0,
          max: 1,
        ),
      ]));

  

  _buildStartThumbnail(){
    return FutureBuilder(
      future: _getThumbnail(this.startTimestamp),
      builder: (context, startThumbnail) => 
        Container(
          height: 50.0,
          child: startThumbnail.data != null
            ? Image.memory(startThumbnail.data, scale: 1.0)
            : Text(''),
        )
    );
  }
}