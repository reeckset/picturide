import 'dart:io';
import 'dart:math';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturide/controller/ffmpeg_build/clip_ffmpeg_builder.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/clip_time_info.dart';
import 'package:picturide/model/project.dart';

const int previewFrameRate = 24;
const int maxClipsPerPreview = 20;

List<String> buildFFMPEGArgsPreview(Project project, String pipePath,
  {int startAtClip}){
  return [
    ...buildFFMPEGArgs(project,
      outputResolution: {'w':256, 'h':144},
      startAtClip: startAtClip,
      maxClips: maxClipsPerPreview),

    '-r', previewFrameRate.toString(), '-s', '256x144',
    '-f', 'matroska', '-c:a','aac', '-aac_coder', 'fast',
    '-preset', 'ultrafast', '-tune', 'zerolatency',
    '-y', pipePath
  ];
}

buildFFMPEGArgs(Project project, {outputResolution, startAtClip = 0, maxClips}){
  if(maxClips == null) maxClips = project.clips.length;
  if(outputResolution == null) outputResolution = project.outputResolution;
  final List<String> inputArgs = [];
  String filterComplexMapping = '';
  final lastClipIndex = min<int>(project.clips.length, startAtClip+maxClips)-1;
  final nClipsToRender = lastClipIndex - startAtClip + 1;
  final Map<int, ClipTimeInfo> clipTimeInfos = project.getClipsTimeInfo();

  for(int i = startAtClip; i <= lastClipIndex; i++){
    final Clip clip = project.clips[i];
    inputArgs.addAll(buildInputArgsForClip(clip, clipTimeInfos[i]));
    filterComplexMapping += getClipFilterComplex(
      i-startAtClip, clip, outputResolution: outputResolution) + ';';
  }

  inputArgs.add('-ss');
  inputArgs.add(clipTimeInfos[startAtClip].startTime.toString());
  inputArgs.add('-i');
  inputArgs.add(project.audioTracks[0].getFilePath());

  final String filterComplex =
    filterComplexMapping
    + _getFilterComplexMappingConcat(nClipsToRender, startAtClip)
    + ';[a][${nClipsToRender}:a]'
    + 'amix=duration=first,pan=stereo|c0<c0+c2|c1<c1+c3[ba]';

  final List<String> args = [
    ...inputArgs,
    '-filter_complex', '$filterComplex',
    '-map', '[v]', '-map', '[ba]',
  ];
  // for debugging: args.forEach((a) => a.split('\n').forEach((b)=>print(b)));
  return args;
}

String _getFilterComplexMappingConcat(int numberOfClips, startAtClip){
  String result = '';
  for(int i = 0; i < numberOfClips; i++){
    result += '[v$i][$i:a]';
  }
  return result + 'concat=n=${numberOfClips}:v=1:a=1 [v] [a]';
}

Future<String> exportffmpeg(Project project, FlutterFFmpeg ffmpeg) async {
  final String directory = (await getTemporaryDirectory()).path;
  final String currentTimestamp =
    DateTime.now().millisecondsSinceEpoch.toString();
  final String outputPath = '$directory/${currentTimestamp}.mp4';

  final clipsFfmpegArguments = _getIndividualExportClipsArgs(project);

  final Function outputArgs =
    (path) => ['-r', 30.toString(), '-f', 'mp4', '-y', path];

  final List<String> clipPaths = [];

  for(int i = 0; i < clipsFfmpegArguments.length; i++){
    final String clipOutputPath = '$directory/clip$i.mp4';
    await ffmpeg.executeWithArguments([
      ...clipsFfmpegArguments[i],
      ...outputArgs(clipOutputPath)
    ]);
    clipPaths.add(clipOutputPath);
  }

  await ffmpeg.executeWithArguments([
      '-f', 'concat', '-safe', '0', 
      '-i', await _makeClipsInputListFile(directory, clipPaths, project),
      '-i', project.audioTracks[0].getFilePath(),
      '-c:v', 'libx264', '-crf', '18',
      '-filter_complex',
      '[0:a][1:a]amix=duration=first,pan=stereo|c0<c0+c2|c1<c1+c3[a]',
      '-map', '0:v', '-map', '[a]',
      ...outputArgs(outputPath)
    ]);
  return outputPath;
}

_makeClipsInputListFile(
  String directory, List<String> clipPaths, Project project
)async {
  final Map<int, ClipTimeInfo> clipTimeInfos = project.getClipsTimeInfo();
  final String listPath = '$directory/encodedClips.txt';
  String concatDemuxerList = '';
  for(int i = 0; i < clipPaths.length; i++){
    concatDemuxerList += 
      """file '${clipPaths[i]}'
      duration ${clipTimeInfos[i].duration.toString()}
      outpoint ${clipTimeInfos[i].duration.toString()}\n""";
  }

  await File(listPath)
    .writeAsString(concatDemuxerList);
  return listPath;
}

_getIndividualExportClipsArgs(Project project){
  final List<Clip> clips = project.clips;
  final Map<int, ClipTimeInfo> clipTimeInfos = project.getClipsTimeInfo();

  final List<List<String>> result = [];

  for(int i = 0; i < clips.length; i++){
    result.add(
      _getExportClipArgs(clips[i], clipTimeInfos[i], project)
    );
  }
  return result;
}

List<String> _getExportClipArgs(
  Clip clip,
  ClipTimeInfo timeInfo,
  Project project){

  return [
    ...buildInputArgsForClip(clip, timeInfo),
    '-filter_complex', '''
    ${getClipFilterComplex(0, clip, outputResolution: project.outputResolution)}
    ''', '-map', '[v0]', '-map', '0:a',
  ];

}