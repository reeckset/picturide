import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/project.dart';

List<String> buildInputArgsForClip(
  Clip clip, ClipTimeInfo clipTimeInfo
) => [
    '-ss', clip.startTimestamp.toString(),
    '-t', clipTimeInfo.duration.abs().toString(),
    '-stream_loop', '-1',
    '-i', clip.getFilePath(),
];


List<String> buildAudioInputArgsForClip(
  ClipTimeInfo clipTimeInfo, Project project
){
  final AudioTrack audio = project.audioTracks[clipTimeInfo.songIndex];
  final double audioStartTime = clipTimeInfo.beatNumber*audio.getBeatSeconds();

   return [
    '-ss', audioStartTime.toString(),
    '-i', audio.getFilePath()
  ];
}

String getClipFilterComplex(int i, Clip clip, {outputResolution}){
  return """[$i:v]
    scale=${outputResolution['w']}:${outputResolution['h']}
    :force_original_aspect_ratio=decrease,setsar=1,
    pad=${outputResolution['w']}:${outputResolution['h']}:(ow-iw)/2:(oh-ih)/2
    ,setpts=PTS-STARTPTS
    [v$i]""";
}