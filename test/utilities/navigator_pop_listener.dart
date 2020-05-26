
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'utilities.dart';

listenForPoppedValue(MockNavigatorObserver observer) async {
  final Route pushedRoute =
          verify(observer.didPush(captureAny, any))
              .captured
              .last;

      /// We declare a popResult variable and assign the result to it
      /// when the details route is popped.
     return await pushedRoute.popped;
}