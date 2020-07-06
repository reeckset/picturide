import 'package:picturide/controller/ffmpeg_build/ffmpeg_project_runner.dart';

class ProjectPreviewer extends FfmpegProjectRunner {

  final String outputPath;

  ProjectPreviewer(project, this.outputPath, ffmpegController, {startClip = 0})
    :super(project, ffmpegController, startClip: startClip);

  @override
  final int maxClips = 20;
  final int previewFrameRate = 24;

  @override
  Map<String, int> getOutputResolution() => {'w':256, 'h':144};

  @override
  run() async {
    final List<String> args = [
      ..._getInputArgs(),
      ..._getFilterArgs(),
      ..._getOutputArgs()
    ];

    // for debugging: args.forEach((a) => a.split('\n').forEach((b)=>print(b)));
    return ffmpegController.executeWithArguments(args);
  }

  List<String> _getInputArgs() => [
    ..._getClipInputArgs(),
    ..._getAudioTrackInputArgs(),
  ];

  List<String> _getClipInputArgs() {
    final List<String> args = List<String>();
    forEachClip((i, clip, timeInfo) => args.addAll(
      getClipInputArgs(clip, timeInfo)
    ));
    return args;
  }

  List<String> _getAudioTrackInputArgs() {
    return ['-ss', clipsTimeInfo[startClip].startTime.toString(),
        '-i', project.audioTracks[0].getFilePath()];
  }

  List<String> _getFilterArgs(){
    String filters = '';
    filters += _getClipFilters();
    filters += _getAudioTrackFilters();
    filters += _getConcatFilter();
    filters += _getAudioMixFilter();
    return ['-filter_complex', filters, '-map', '[cv]', '-map', '[am]'];
  }

  String _getClipFilters() {
    String filters = '';
    forEachClip((i, clip, timeInfo) =>
      filters += getClipFilter(i, clip) + ';'
    );
    return filters;
  }

  String _getAudioTrackFilters() {
    return '';
  }

  List<String> _getOutputArgs() => [
    '-r', previewFrameRate.toString(),
    '-s', '${this.outputResolution['w'].toString()}'
      + 'x${this.outputResolution['h'].toString()}',
    '-f', 'avi', '-c:a','aac', '-aac_coder', 'fast',
    '-preset', 'ultrafast',
    '-y', this.outputPath,
    '-async', '1', '-vsync', '1',
  ];

  String _getAudioMixFilter() {
    return '[ca][${_getAudioTrackFilterReference(0)}]'
    + 'amix=duration=first,pan=stereo|c0<c0+c2|c1<c1+c3[am]';
  }

  String _getAudioTrackFilterReference(int i) {
    return '${getNumberOfClips()+i}:a';
  }

  String _getConcatFilter(){
    String result = '';
    forEachClip((i, clip, timeInfo) {
      result += '[v$i][a$i]';
    });
    return result + 'concat=n=${getNumberOfClips()}:v=1:a=1[cv][ca];';
  }

}