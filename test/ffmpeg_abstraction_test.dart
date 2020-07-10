import 'dart:convert';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/concatenate_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/fit_to_resolution_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/source_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_to_file_stream.dart';

import 'utilities/ffmpeg/ffmpeg_mock.dart';

class FlutterFFprobeMock extends FlutterFFprobe {
  @override
  getMediaInformation(String file) async {
    final process = await Process.run('ffprobe',
      ['-v','quiet',
      '-print_format','json',
      '-show_format','-show_streams',
      '-print_format','json',file], runInShell: true);
    final Map<String, dynamic> ffprobeResult = json.decode(process.stdout);
    ffprobeResult['streams'].forEach(
      (stream) => stream['type'] = stream['codec_type']
    );
    return ffprobeResult;
  }
}

void main() { 

  final compareFinalArguments = (actual, expected) {
    expect(actual.length, expected.length);
    for(int i = 0; i < actual.length; i++){
      expect(actual[i], expected[i]);
    }
  };

  test('Fit to resolution',
    () async {

      final List<String> args = OutputToFileStream('outputdeteste.mp4',
        FitToResolutionFilterStream(
          await SourceFileStream.importAsync(
            'test/assets/video1.mp4',
            probeClient: FlutterFFprobeMock()
          ),
          1920,
          1080,
        )
      ).build();

      final expectedOutput = ['-ss', '0', '-i', 'test/assets/video1.mp4', '-filter_complex', '[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,setsar=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setpts=PTS-STARTPTS[0:v-fit1920x1080]', '-map', '[0:v-fit1920x1080]', '-map', '[0:a]', 'outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });
  
  test('Concatenate',
    () async {

      final List<String> args = OutputToFileStream('outputdeteste.mp4',
        ConcatenateFilterStream([
          await SourceFileStream.importAsync(
            'test/assets/video1.mp4',
            probeClient: FlutterFFprobeMock()
          ),
          await SourceFileStream.importAsync(
            'test/assets/video1.mp4',
            probeClient: FlutterFFprobeMock()
          ),
        ])
      ).build();

      final expectedOutput = ['-ss', '0', '-i', 'test/assets/video1.mp4', '-ss', '0', '-i', 'test/assets/video1.mp4', '-filter_complex', '[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[0:v-1:v-concatenate][0:a-1:a-concatenate]', '-map', '[0:v-1:v-concatenate]', '-map', '[0:a-1:a-concatenate]', 'outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });

  test('Concatenate inception',
    () async {

      final List<String> args = OutputToFileStream('test/assets/outputdeteste.mp4',
        ConcatenateFilterStream([
          await SourceFileStream.importAsync(
            'test/assets/video1.mp4',
            probeClient: FlutterFFprobeMock()
          ),
          await SourceFileStream.importAsync(
            'test/assets/video1.1.mp4',
            probeClient: FlutterFFprobeMock()
          ),
          await SourceFileStream.importAsync(
            'test/assets/video1.2.mp4',
            probeClient: FlutterFFprobeMock()
          ),
          await SourceFileStream.importAsync(
            'test/assets/video1.3.mp4',
            probeClient: FlutterFFprobeMock()
          ),
        ])
      ).build();

      final expectedOutput = ['-ss', '0', '-i', 'test/assets/video1.mp4', '-ss', '0', '-i', 'test/assets/video1.1.mp4', '-ss', '0', '-i', 'test/assets/video1.2.mp4', '-ss', '0', '-i', 'test/assets/video1.3.mp4', '-filter_complex', '[0:v][0:a][1:v][1:a][2:v][2:a][3:v][3:a]concat=n=4:v=1:a=1[0:v-1:v-2:v-3:v-concatenate][0:a-1:a-2:a-3:a-concatenate]', '-map', '[0:v-1:v-2:v-3:v-concatenate]', '-map', '[0:a-1:a-2:a-3:a-concatenate]', 'test/assets/outputdeteste.mp4'];

      compareFinalArguments(args, expectedOutput);
    });
}