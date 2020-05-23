import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/controller/ffmpeg_build/project_previewer.dart';
import 'package:picturide/model/project.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:picturide/redux/actions/preview_actions.dart';
import 'package:picturide/view/widgets/modals/inform_dialog.dart';
import 'package:picturide/redux/state/app_state.dart';

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
  Timer pollingTimer;
  double startTime = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setPlayerPositionListener();
    _controller.addIjkPlayerOptions(
      [TargetPlatform.iOS, TargetPlatform.android],
      [
        IjkOption(IjkOptionCategory.format, 'analyzemaxduration', 10),
        IjkOption(IjkOptionCategory.format, 'probesize', 10240),
        IjkOption(IjkOptionCategory.format, 'flush_packets', 1),
        IjkOption(IjkOptionCategory.player, 'packet-buffering', 0),
        IjkOption(IjkOptionCategory.player, 'framedrop', 1),
      ].toSet());
    _controller.ijkStatusStream.listen((IjkStatus status) {
      if(status == IjkStatus.complete){
        _controller.reset();
      }
      this.setState((){ playerStatus = status; });
    });
  }

  void _setPlayerPositionListener() {
    _controller.videoInfoStream.listen(
      (VideoInfo vi) => StoreProvider.of<AppState>(context)
      .dispatch(UpdatePreviewCurrentTime(vi.currentPosition+startTime)));
    this.pollingTimer = Timer.periodic(Duration(milliseconds: 100),
      (Timer t) => _controller.refreshVideoInfo());
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
              onPressed: _play,
            )
          ) : IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _play,
            );
        }
    );

  _play(){
    try{_flutterFFmpeg.cancel();}catch(e){}

    if(widget.project.audioTracks.isEmpty){
      _showNoSoundAlert();
      return;
    }
    

    final selectedClip =
      StoreProvider.of<AppState>(context).state.preview.selectedClip;

    this.setState(() {
      startTime = selectedClip == null ? 0
        : widget.project.getClipsTimeInfo()[selectedClip].startTime;

      _flutterFFmpegConfig.registerNewFFmpegPipe().then((path) {
        pipePath = path;
        ProjectPreviewer(
          widget.project, path,
          _flutterFFmpeg,
          startClip: selectedClip == null ? 0 : selectedClip
        ).run();
        _controller.setNetworkDataSource(path, autoPlay: true);
      });
    });
  }

  Future<void> _showNoSoundAlert() async {
    return informDialog(
      'Missing audio',
      'Please add at least one audio file',
    context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    pollingTimer.cancel();
    _flutterFFmpeg.cancel();
  }
}