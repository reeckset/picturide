import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

class FitToResolutionFilterStream extends FilterStream {
  final int width, height;
  final bool fillFrame;

  FitToResolutionFilterStream(sourceStream, this.width, this.height,
    {this.fillFrame = false}
  ):super(sourceStream);

  @override
  buildFilter() {
    ensureVideoStream();
    return '''${sourceStream.getVideoStreamLabel().forFilterInput()}
      scale=$width:$height
      :force_original_aspect_ratio=${this.fillFrame ? 'increase' : 'decrease'},setsar=1,
      ${this.fillFrame ? 'crop' : 'pad'}=$width:$height:(ow-iw)/2:(oh-ih)/2
      ,setpts=PTS-STARTPTS
      ${getVideoStreamLabel().forFilterInput()}''';
  }
 
  @override
  FFMPEGLabel getVideoStreamLabel() =>
    generateVideoStreamLabel('fit${width}x$height');
}