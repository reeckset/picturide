import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/labels/ffmpeg_label.dart';

class FFMPEGFilteredLabel extends FFMPEGLabel{

  FFMPEGFilteredLabel(String label):super(label);

  @override
  String forMapping() => forFilterInput();
}