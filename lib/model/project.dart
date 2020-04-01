import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';

class Project {
  List<Clip> clips = List<Clip>();
  List<AudioTrack> audioTracks = List<AudioTrack>();
  Map<String, int> outputResolution = {'w':256, 'h':144};

  getAspectRatio() => outputResolution['w'] / outputResolution['h'];
}