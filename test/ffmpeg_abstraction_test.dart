import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/concatenate_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/fit_to_resolution_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/input_file.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/concat_input_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/source_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/add_output_properties_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_to_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/stream.dart';

import 'utilities/ffmpeg/ffmpeg_mock.dart';

final String tmpDir = 'test/tmp_ffmpeg_abstraction';

void main() { 

  setUpAll((){
    Directory(tmpDir).create();
    FFMPEGStream.flutterFFprobe = FlutterFFprobeMock();
    FFMPEGStream.forceTmpDirectory = tmpDir;
  });

  tearDownAll((){
    Directory(tmpDir).delete(recursive: true);
  });

  final compareFinalArguments = (actual, expected) {
    expect(actual.length, expected.length);
    for(int i = 0; i < actual.length; i++){
      expect(actual[i], expected[i]);
    }
  };

  test('Fit to resolution',
    () async {

      final List<String> args = await OutputToFileStream('outputdeteste.mp4',
        FitToResolutionFilterStream(
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.mp4'),
          ),
          1920,
          1080,
        )
      ).build();

      final expectedOutput = ['-i', 'test/assets/video1.mp4', '-filter_complex', '[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,setsar=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setpts=PTS-STARTPTS[0:v-fit1920x1080]', '-map', '[0:v-fit1920x1080]', '-map', '0:a', 'outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });
  
  test('Concatenate',
    () async {

      final List<String> args = await OutputToFileStream('outputdeteste.mp4',
        ConcatenateFilterStream([
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.mp4'),
          ),
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.mp4'),
          ),
        ])
      ).build();

      final expectedOutput = ['-i', 'test/assets/video1.mp4', '-i', 'test/assets/video1.mp4', '-filter_complex', '[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[0:v-1:v-concatenate][0:a-1:a-concatenate]', '-map', '[0:v-1:v-concatenate]', '-map', '[0:a-1:a-concatenate]', 'outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });

  test('Concatenate inception',
    () async {

      final List<String> args = await OutputToFileStream('$tmpDir/outputdeteste.mp4',
        ConcatenateFilterStream([
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.mp4'),
          ),
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.1.mp4'),
          ),
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.2.mp4'),
          ),
          await SourceFileStream.importAsync(
            InputFile('test/assets/video1.3.mp4'),
          ),
        ])
      ).build();

      final expectedOutput = ['-i', 'test/assets/video1.mp4', '-i', 'test/assets/video1.1.mp4', '-i', 'test/assets/video1.2.mp4', '-i', 'test/assets/video1.3.mp4', '-filter_complex', '[0:v][0:a][1:v][1:a][2:v][2:a][3:v][3:a]concat=n=4:v=1:a=1[0:v-1:v-2:v-3:v-concatenate][0:a-1:a-2:a-3:a-concatenate]', '-map', '[0:v-1:v-2:v-3:v-concatenate]', '-map', '[0:a-1:a-2:a-3:a-concatenate]', '$tmpDir/outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });

    test('Concatenate with concat demuxer',
    () async {

      final List<String> args = await OutputToFileStream('$tmpDir/outputdeteste.mp4',
        await ConcatInputStream.importAsync([
          InputFile('test/assets/video1.mp4',durationSeconds: 3),
          InputFile('test/assets/video1.1.mp4', durationSeconds: 4),
          InputFile('test/assets/video1.2.mp4',),
          InputFile('test/assets/video1.3.mp4',),
        ])
      ).build();

      final String demuxerListContent = File('$tmpDir/0-concat-list.txt').readAsStringSync();

      final expectedOutput = ['-f', 'concat', '-safe', '0', '-i', '$tmpDir/0-concat-list.txt', '$tmpDir/outputdeteste.mp4'];

      final expectedListContent = "file 'test/assets/video1.mp4'\nduration 3.0\noutpoint 3.0\nfile 'test/assets/video1.1.mp4'\nduration 4.0\noutpoint 4.0\nfile 'test/assets/video1.2.mp4'\nfile 'test/assets/video1.3.mp4'";

      compareFinalArguments(args, expectedOutput);
      expect(demuxerListContent, expectedListContent);
    });

    test('Output Properties',
      () async {

        final List<String> args = await OutputToFileStream('outputdeteste.mp4',
          AddOutputPropertiesStream([
            '-r', '24',
            '-s', '1280x720',
            '-f', 'avi', '-c:a','aac', '-aac_coder', 'fast',
            '-preset', 'ultrafast',
            '-async', '1', '-vsync', '1',
          ], FitToResolutionFilterStream(
            await SourceFileStream.importAsync(
              InputFile('test/assets/video1.mp4'),
            ),
            1920,
            1080,
          )
        ),replace:true).build();

        final expectedOutput = ['-i', 'test/assets/video1.mp4', '-filter_complex', '[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,setsar=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setpts=PTS-STARTPTS[0:v-fit1920x1080]', '-map', '[0:v-fit1920x1080]', '-map', '0:a', '-r', '24', '-s', '1280x720', '-f', 'avi', '-c:a', 'aac', '-aac_coder', 'fast', '-preset', 'ultrafast', '-async', '1', '-vsync', '1', '-y', 'outputdeteste.mp4'];

        compareFinalArguments(args, expectedOutput);
      }
    );
    

    

}