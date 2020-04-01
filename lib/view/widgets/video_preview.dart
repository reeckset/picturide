import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:picturide/controller/ffmpeg_builder.dart';
import 'package:picturide/model/project.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class VideoPreview extends StatefulWidget {
  final Project project;

  VideoPreview(this.project);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  final IjkMediaController _controller = IjkMediaController();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
  String pipePath;
  IjkStatus playerStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.ijkStatusStream.listen((IjkStatus status) {
      if(status == IjkStatus.complete){
        _controller.reset();
      }
      this.setState((){ playerStatus = status; });
    });
  }

  @override
  void setState(fn) {
    if(this.mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) =>
        IjkPlayer(
          mediaController: _controller,
          controllerWidgetBuilder: 
            (mediaController) {
              return this.playerStatus != IjkStatus.playing 
              ? Center(
                child: IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: _refresh,
                )
              ) : IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: _refresh,
                );
            }
        );

  _refresh(){
    try{_flutterFFmpeg.cancel();}catch(e){}

    if(widget.project.audioTracks.isEmpty){
      _showNoSoundAlert();
      return;
    }

    _flutterFFmpegConfig.registerNewFFmpegPipe().then((path) {
      pipePath = path;
      _flutterFFmpeg.executeWithArguments(
        [...buildFFMPEGArgs(widget.project),
        '-r', '30', '-f', 'matroska', '-c:a', 'aac', '-preset', 'ultrafast',
        '-y', pipePath]
      );
      _controller.setNetworkDataSource(path, autoPlay: true);
    });
  }

  Future<void> _showNoSoundAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Missing audio'),
          content: Text('Please add at least one audio file'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}