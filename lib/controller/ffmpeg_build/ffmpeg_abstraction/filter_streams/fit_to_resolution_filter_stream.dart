import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/filter_stream.dart';

class FitToResolutionFilterStream extends FilterStream {
  final int width, height;

  FitToResolutionFilterStream(sourceStream, this.width, this.height)
    :super(sourceStream);

  @override
  buildFilter() {
    ensureVideoStream();
    return '''[${sourceStream.getVideoStreamLabel()}]
      scale=$width:$height
      :force_original_aspect_ratio=decrease,setsar=1,
      pad=$width:$height:(ow-iw)/2:(oh-ih)/2
      ,setpts=PTS-STARTPTS
      [${getVideoStreamLabel()}]''';
  }
 
  @override
  String getVideoStreamLabel() =>
    '${sourceStream.getVideoStreamLabel()}-fit${width}x$height';
}