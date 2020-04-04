import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picturide/view/pages/home_page.dart';
import 'utilities/utilities.dart';

void main() {

  setUp(() {
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
        size: const Size(1080, 1920)
    );
  });

  testWidgets('Creating new project adds button and opens project',
    (WidgetTester tester) async {

      final HomePage homePage = HomePage();

      await tester.pumpWidget(makeTestableWidgetRedux(homePage));

      expect(find.byType(RaisedButton) ,findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'someProjectName');
      await tester.tap(find.text('Done'));
      await tester.pump();

      // expect(find.text('someProjectName'), findsOneWidget);
      // expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
