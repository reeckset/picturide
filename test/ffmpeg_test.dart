import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/controller/ffmpeg_build/project_previewer.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/controller/ffmpeg_build/project_exporter.dart';

import 'utilities/ffmpeg/ffmpeg_mock.dart';
import 'utilities/ffmpeg/video_file_tester.dart';

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

      (await VideoFileTester(projectExporter.testableOutputPath()).init())
        ..checkDuration(defaultProject.getDuration())
        ..checkDuration(13.33)
        ..checkAVDurationMatch()
        ..checkFrameRate(30)
        ..checkResolution(defaultProject.outputResolution);
    },
  timeout: Timeout(Duration(seconds: 40)));

  test('Previewer', () async {
    final FlutterFFmpegMock ffmpeg = FlutterFFmpegMock();

    final projectPreviewer =
      ProjectPreviewer(defaultProject, outputPath, ffmpeg);
    
    await projectPreviewer.run();

    (await VideoFileTester(outputPath).init())
      ..checkDuration(defaultProject.getDuration())
      ..checkDuration(13.33)
      ..checkAVDurationMatch()
      ..checkFrameRate(24)
      ..checkResolution(projectPreviewer.getOutputResolution());
    },
  timeout: Timeout(Duration(seconds: 20)));

  test('Previewer with start clip', () async {
    final FlutterFFmpegMock ffmpeg = FlutterFFmpegMock();

    final projectPreviewer =
      ProjectPreviewer(defaultProject, outputPath, ffmpeg, startClip: 3);
    
    await projectPreviewer.run();

    (await VideoFileTester(outputPath).init())
      ..checkDuration(
        defaultProject.getDuration()
        - defaultProject.getClipsTimeInfo()[3].startTime)
      ..checkAVDurationMatch()
      ..checkFrameRate(24)
      ..checkResolution(projectPreviewer.getOutputResolution());
    },
  timeout: Timeout(Duration(seconds: 20)));
}