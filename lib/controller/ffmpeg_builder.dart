import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';

/*
-filter_complex 
"[0:v]scale=1920:808:force_original_aspect_ratio=decrease,setsar=1[a];
[1:v]scale=1920:808:force_original_aspect_ratio=decrease,setsar=1[b];
[a][0:a][b][1:a]concat=n=2:v=1:a=1[v][a]"
 -map "[v]" -map "[a]"
*/


buildFFMPEGArgs(Project project){
  final List<String> inputArgs = [];
  String filterComplexMapping = '';

  for(int i = 0; i < project.clips.length; i++){
    final Clip clip = project.clips[i];
    inputArgs.add('-i');
    inputArgs.add(clip.file.path);
    filterComplexMapping += _getClipFilterComplex(i, clip, project);
  }

  inputArgs.add('-i');
  inputArgs.add(project.audioTracks[0].file.path);

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

_getClipFilterComplex(int i, Clip clip, Project project){
  return """[$i:v]
    scale=${project.outputResolution['w']}:${project.outputResolution['h']}
    :force_original_aspect_ratio=decrease,setsar=1,trim=start=0:end=${60.0/project.audioTracks[0].bpm*2},setpts=PTS-STARTPTS
    [v$i];
    [$i:a]atrim=0:${60.0/project.audioTracks[0].bpm*2}[a$i];""";
}

String _getFilterComplexMappingConcat(int numberOfClips){
  String result = '';
  for(int i = 0; i < numberOfClips; i++){
    result += '[v$i][a$i]';
  }
  return result + 'concat=n=${numberOfClips}:v=1:a=1 [v] [a]';
}