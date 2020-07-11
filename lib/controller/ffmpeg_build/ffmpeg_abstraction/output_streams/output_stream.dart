import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

abstract class OutputStream extends FFMPEGStream {

  OutputStream(FFMPEGStream sourceStream):super(sourceStream: sourceStream);

  @override
  buildOutputArgs() async {
    if(sourceStream == null) {
      throw Exception(
        'Output Stream has no source stream'
      );
    }
    return [
      ...prependArgs(),
      ...await sourceStream.buildOutputArgs(),
      ...appendArgs()
    ];
  }

  // to add an output argument, this should be overriden
  List<String> appendArgs() => [];

  // to add an output argument to the beggining, this should be overriden
  List<String> prependArgs() => [];

}