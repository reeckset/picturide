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
  List<String> inputArgs = [];
  String filterComplexMapping = '';

  for(int i = 0; i < project.clips.length; i++){
    final Clip clip = project.clips[i];
    inputArgs.add('-i');
    inputArgs.add(clip.file.path);
    filterComplexMapping += _getClipFilterComplex(i, clip, project);
  }

  final String filterComplex =
    filterComplexMapping + _getFilterComplexMappingConcat(project.clips.length);

  final List<String> args = [
    ...inputArgs,
    '-filter_complex', '$filterComplex',
    '-map', '[v]', '-map', '[a]',
  ];
  print(args);
  return args;
}

_getClipFilterComplex(int i, Clip clip, Project project){
  return """[$i:v]
    scale=${project.outputResolution['w']}:${project.outputResolution['h']}
    :force_original_aspect_ratio=decrease,setsar=1
    [v$i];""";
}

String _getFilterComplexMappingConcat(int numberOfClips){
  String result = '';
  for(int i = 0; i < numberOfClips; i++){
    result += '[v$i][$i:a]';
  }
  return result + 'concat=n=${numberOfClips}:v=1:a=1 [v] [a]';
}