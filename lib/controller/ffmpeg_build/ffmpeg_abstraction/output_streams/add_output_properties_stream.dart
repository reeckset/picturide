import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_stream.dart';

class AddOutputPropertiesStream extends OutputStream {

  List<String> properties;

  AddOutputPropertiesStream(this.properties, sourceStream)
    : super(sourceStream);

  @override
  List<String> prependArgs() => properties;
}