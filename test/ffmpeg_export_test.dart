import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/controller/ffmpeg_build/project_exporter.dart';

class TestableProjectExporter extends ProjectExporter with Mock {

  TestableProjectExporter(project, ffmpegController)
    : super(project, ffmpegController);

  @override
  getTmpDirectory() => Directory.current.path + '/test/tmp';

  @override
  saveToGallery(String tmpPath){
    return File(tmpPath).copy(testableOutputPath());
  }

  testableOutputPath() => 'test/tmp/output.mp4';
}

class FlutterFFmpegMock extends Mock with FlutterFFmpeg {
  @override
  Future<int> executeWithArguments(List<String> arguments) async {   
    final process = await Process.start('ffmpeg', arguments, runInShell: true);
    return await process.exitCode;
  }
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
        AudioTrack(filePath: 'test/assets/audio1.mp3', bpm: 60, sourceDuration: 1000.0)
      ],
      outputResolution: {'w': 1920, 'h': 1080},
    );
  });

  tearDownAll(){
    Directory('test/tmp').delete();
  }

  test('Test export project',
    () async {
      final FlutterFFmpegMock ffmpeg = FlutterFFmpegMock();

      final projectExporter =
        TestableProjectExporter(defaultProject, ffmpeg);
      
      await projectExporter.run();

      expect(File(projectExporter.testableOutputPath()).existsSync(), true);
    },
    timeout: Timeout(Duration(seconds: 60))
  );
}