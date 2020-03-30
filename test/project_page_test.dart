import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'make_testable_widget.dart';
import 'widget_mocks/project_page.dart';

void main() {
  testWidgets('Clips list adds selected clip', (WidgetTester tester) async {

    final MockProjectPage projectPage = MockProjectPage();

    await tester.pumpWidget(makeTestableWidget(projectPage));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('15'), findsNothing);

    // Tap the '+' icon 15 times and trigger a frame.
    for(int i = 0; i < 15; i++){
      await tester.tap(find.byIcon(Icons.add));
    }
    await tester.pump();

    //counter should now be 15
    expect(find.text('0'), findsNothing);
    expect(find.text('15'), findsOneWidget);

    //There should be a listview with 15 files' paths
    expect(find.byWidgetPredicate(
      (Widget widget) => widget is ListView),
      findsOneWidget
    );
    expect(find.text(File('mockFilePath').path), findsNWidgets(15));
  });
}
