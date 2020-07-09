import 'package:flutter_test/flutter_test.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/filter_streams/fit_to_resolution_filter_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/input_streams/source_file_stream.dart';
import 'package:picturide/controller/ffmpeg_build/ffmpeg_abstraction/output_streams/output_to_file_stream.dart';

void main() {
  test('Fit to resolution and export',
    () async {
      print(
        OutputToFileStream('outputdeteste.mp4',
          FitToResolutionFilterStream(
            SourceFileStream('inputdeteste.mp4'),
            1920,
            1080,
          )
        ).build()
      );
    },
  timeout: Timeout(Duration(seconds: 40)));
}