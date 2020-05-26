import 'package:flutter/cupertino.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/pages/edit_clip_page.dart';

class _MockIjkMediaController extends Mock implements IjkMediaController {
  @override
  final VideoInfo videoInfo = VideoInfo.fromMap({
    'width': 1920,
      'height': 1080,
      'duration': 300.0,
      'currentPosition': 15.1,
      'isPlaying': false,
      'degree': 0,
      'tcpSpeed': 0,
  });

  @override
  Future<VideoInfo> getVideoInfo() async => videoInfo;
}

class _TestableEditClipPageState extends EditClipPageState {
  @override
  final IjkMediaController controller = _MockIjkMediaController();

  @override
  previewer(context) { return Container(); }
}

class TestableEditClipPage extends EditClipPage {
  TestableEditClipPage(Clip originalClip) : super(originalClip);

  @override
  _TestableEditClipPageState createState() => _TestableEditClipPageState();
}