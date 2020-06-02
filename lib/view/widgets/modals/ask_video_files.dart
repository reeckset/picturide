import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<List<String>> askVideoFiles() async =>
  (await FilePicker.getMultiFilePath(type: FileType.video))
    .values.toList()..sort( // sort chronologically
      (path1, path2) => 
        File(path1).lastModifiedSync().compareTo(
          File(path2).lastModifiedSync()
        )
    );