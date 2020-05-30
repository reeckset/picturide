import 'dart:convert';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/controller/ffmpeg_build/project_previewer.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/controller/ffmpeg_build/project_exporter.dart';

final String tmpDir = 'test/tmp';
final String outputPath = '$tmpDir/output.mp4';

class TestableProjectExporter extends ProjectExporter with Mock {

  TestableProjectExporter(project, ffmpegController)
    : super(project, ffmpegController);

  @override
  getTmpDirectory() => Directory.current.path + '/$tmpDir';

  @override
  saveToGallery(String tmpPath){
    return File(tmpPath).copy(testableOutputPath());
  }

  testableOutputPath() => outputPath;
}

class FlutterFFmpegMock extends Mock with FlutterFFmpeg {
  @override
  Future<int> executeWithArguments(List<String> arguments) async {   
    final process = await Process.start('ffmpeg', arguments, runInShell: true);
    return await process.exitCode;
  }
}

/**
 * Returns an array of maps (0 -> video stream, 1 -> audio stream)
 */
getVideoAndAudioInfoFromFile(filePath) async {
  final ProcessResult pr = await Process.run('ffprobe', [
    '-v','quiet','-print_format','json',
    '-show_format','-show_streams','-print_format','json',
    filePath]);
  
  final info = json.decode(pr.stdout)['streams'];
  info[0]['duration'] = double.parse(info[0]['duration']);
  info[1]['duration'] = double.parse(info[1]['duration']);
  return info;
}

expectValueEquivalence(a, b, tolerance) {
  expect((a-b).abs() <= tolerance, true);
}

checkExportedFile(path, project, {resolution, framerate}) async {
  expect(File(path).existsSync(), true);
  final outputInfo = await getVideoAndAudioInfoFromFile(
    path
  );
  final videoInfo = outputInfo[0];
  final audioInfo = outputInfo[1];
  final durationDiffTolerance = 0.2;
  if(resolution == null) resolution = project.outputResolution;

  expectValueEquivalence(
      videoInfo['duration'],
      project.getDuration(),
      durationDiffTolerance);
  expectValueEquivalence(
    videoInfo['duration'], 13.33, durationDiffTolerance);
  expectValueEquivalence(
      videoInfo['duration'], audioInfo['duration'], durationDiffTolerance
  );
  expect(videoInfo['width'], resolution['w']);
  expect(videoInfo['height'], resolution['h']);
  expect(videoInfo['r_frame_rate'], '$framerate/1');
}

void main() {
  Project defaultProject = Project.create('-');

  setUpAll((){
    Directory('test/tmp').create();

    defaultProject = Project(
      filepath: '-',
      clips: List.generate(5, (i) => Clip(
        filePath: 'test/assets/video1.mp4',
        tempoDurationPower: i % 5,
        startTimestamp: i.toDouble(),
        sourceDuration: 30.0,
      )),
      audioTracks: [
        AudioTrack(filePath: 'test/assets/audio1.mp3', bpm: 140, sourceDuration: 1000.0)
      ],
      outputResolution: {'w': 1920, 'h': 1080},
    );
  });

  tearDownAll((){
    Directory('test/tmp').delete(recursive: true);
  });

  test('Project export',
    () async {
      final FlutterFFmpegMock ffmpeg = FlutterFFmpegMock();

      final projectExporter =
        TestableProjectExporter(defaultProject, ffmpeg);
      
      await projectExporter.run();

      await checkExportedFile(
        projectExporter.testableOutputPath(),
        defaultProject,
        framerate: 30
      );
    },
    timeout: Timeout(Duration(seconds: 60))
  );

  test('Previewer', () async {
    final FlutterFFmpegMock ffmpeg = FlutterFFmpegMock();

    final projectPreviewer =
      ProjectPreviewer(defaultProject, outputPath, ffmpeg);
    
    await projectPreviewer.run();

    await checkExportedFile(
      outputPath,
      defaultProject,
      resolution: projectPreviewer.getOutputResolution(),
      framerate: 24
    );
  });
}