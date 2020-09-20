import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/concatenate_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/mix_audio_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/source_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/add_output_properties_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_to_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';
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
    final FFMPEGStream filters = 
      MixAudioFilterStream([
        await _getClipsStream(),
        await getAudioTracksStream()
      ]);

    final FFMPEGStream output = OutputToFileStream(
      this.outputPath,
      AddOutputPropertiesStream(
        _getOutputArgs(),
        filters,
      ),
      replace: true);

    final args = await output.build();

    // for debugging: args.forEach((a) => a.split('\n').forEach((b)=>print(b)));
    return ffmpegController.executeWithArguments(args);
  }

  _getClipsStream() async {
    final result = await mapActiveClipsAsync<FFMPEGStream>(
      (i, clip, timeInfo) => getClipStream(clip, timeInfo)
    );

    if(result.length == 1) return result[0];
    return ConcatenateFilterStream(result);
  }

  List<String> _getOutputArgs() => [
    '-r', previewFrameRate.toString(),
    '-s', '${this.outputResolution['w']}'
      + 'x${this.outputResolution['h']}',
    '-f', 'avi', '-c:a','aac', '-aac_coder', 'fast',
    '-preset', 'ultrafast',
    '-async', '1', '-vsync', '1',
  ];
}