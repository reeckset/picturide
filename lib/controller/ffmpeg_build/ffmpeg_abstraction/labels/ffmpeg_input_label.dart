import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

class FFMPEGInputLabel extends FFMPEGLabel{

  FFMPEGInputLabel(String label):super(label);

  @override
  String forMapping() => label;
}