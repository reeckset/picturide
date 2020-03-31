import 'package:picturide/model/file_wrapper.dart';

class AudioTrack extends FileWrapper {
  int bpm;

  AudioTrack({file, this.bpm}):super(file);
}