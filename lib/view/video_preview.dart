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
    _refresh();
  }

  @override
  Widget build(BuildContext context) =>
        IjkPlayer(
          mediaController: _controller,
          controllerWidgetBuilder: 
            (mediaController) {
              return this.playerStatus == IjkStatus.noDatasource ? Center(
                child: IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: _refresh,
                )
              ) : Container();
            }
        );

  _refresh(){
    try{
      _flutterFFmpeg.cancel();
    }catch(e){

    }
    _flutterFFmpegConfig.registerNewFFmpegPipe().then((path) {
      pipePath = path;
      _flutterFFmpeg.executeWithArguments(
        [...buildFFMPEGArgs(widget.project),
        '-f', 'flv', '-ar', '44100', '-ab', '64000', '-ac', '1',
        '-y', pipePath]
      );
      _controller.setNetworkDataSource(path, autoPlay: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}