import 'package:flutter/services.dart';

//Mocked picked files will have path with format:
// filepath-[VIDEO|AUDIO|IMAGE|CUSTOM|ANY]
// depending on the requested file type
Future<dynamic> filePickerMockHandler(MethodCall methodCall) async {
  return 'filepath-'+methodCall.method;
}
