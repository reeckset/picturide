import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
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

  @override
  void initState() {
    super.initState();
    _flutterFFmpegConfig.registerNewFFmpegPipe().then((path) {
      _flutterFFmpeg.executeWithArguments(
        ['-i', widget.project.clips[0].file.path,
        '-f', 'flv', '-ar', '44100', '-ab', '64000', '-ac', '1',
        '-y', path]
      );
      _controller.setNetworkDataSource(path, autoPlay: true);
    });
  }

  @override
  Widget build(BuildContext context) => IjkPlayer(mediaController: _controller);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}