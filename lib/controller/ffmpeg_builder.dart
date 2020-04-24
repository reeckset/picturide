import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/project.dart';

const int previewFrameRate = 30;

List<String> buildFFMPEGArgsPreview(Project project, String pipePath){
  return [
    ...buildFFMPEGArgs(project, outputResolution: {'w':640, 'h':360}),
    '-r', previewFrameRate.toString(),
    '-f', 'matroska', '-c:a', 'aac', '-preset', 'ultrafast',
    '-y', pipePath
  ];
}

buildFFMPEGArgs(Project project, {outputResolution}){
  if(outputResolution == null) outputResolution = project.outputResolution;
  final List<String> inputArgs = [];
  String filterComplexMapping = '';
  final Map<int, ClipTimeInfo> clipTimeInfos = project.getClipsTimeInfo();

  for(int i = 0; i < project.clips.length; i++){
    final Clip clip = project.clips[i];
    inputArgs.add('-ss');
    inputArgs.add(clip.startTimestamp.toString());
    inputArgs.add('-t');
    inputArgs.add(clipTimeInfos[i].duration.toString());
    inputArgs.add('-stream_loop');
    inputArgs.add('-1');
    inputArgs.add('-i');
    inputArgs.add(clip.getFilePath());
    filterComplexMapping += _getClipFilterComplex(
      i, clip, project, outputResolution: outputResolution);
  }

  inputArgs.add('-i');
  inputArgs.add(project.audioTracks[0].getFilePath());

  final String filterComplex =
    filterComplexMapping
    + _getFilterComplexMappingConcat(project.clips.length)
    + ';[${project.clips.length}:a][a]'
    + 'amix=duration=shortest,pan=stereo|c0<c0+c2|c1<c1+c3[ba]';

  final List<String> args = [
    ...inputArgs,
    '-filter_complex', '$filterComplex',
    '-map', '[v]', '-map', '[ba]',
  ];
  // for debugging: print(args);
  return args;
}

_getClipFilterComplex(int i, Clip clip, Project project, {outputResolution}){
  return """[$i:v]
    scale=${outputResolution['w']}:${outputResolution['h']}
    :force_original_aspect_ratio=decrease,setsar=1,
    pad=${outputResolution['w']}:${outputResolution['h']}:(ow-iw)/2:(oh-ih)/2
    ,setpts=PTS-STARTPTS
    [v$i];""";
}

String _getFilterComplexMappingConcat(int numberOfClips){
  String result = '';
  for(int i = 0; i < numberOfClips; i++){
    result += '[v$i][$i:a]';
  }
  return result + 'concat=n=${numberOfClips}:v=1:a=1 [v] [a]';
}