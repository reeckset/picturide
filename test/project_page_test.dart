import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'utilities/utilities.dart';
import 'widget_mocks/project_page.dart';

void main() {

  setUp(() {
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
        size: const Size(1080, 1920)
    );
  });

  final testProject = Project.create('Name');

  createInitialAppState() =>
    AppState(history: HistoryState(
      project: testProject,
      undoActions: [], redoActions: [],
      savingStatus: SavingStatus.saved
    ));

  testWidgets('Editing Mode switch toggles between audio and video',
    (WidgetTester tester) async {

      final MockProjectPage projectPage = MockProjectPage();

      await tester.pumpWidget(
        makeTestableWidgetRedux(
          projectPage, 
          initialState: createInitialAppState()
        )
      );

      expect(find.text('Editing: video'), findsOneWidget);
      expect(find.byIcon(Icons.local_movies), findsOneWidget);
      expect(find.text('Editing: audio'), findsNothing);
      expect(find.byIcon(Icons.music_note), findsNothing);
      
      expect(
        find.byWidgetPredicate((Widget widget) => widget is Switch),
        findsOneWidget
      );

      
      await tester.tap(
        find.byWidgetPredicate((Widget widget) => widget is Switch)
      );
      await tester.pump();

      expect(find.text('Editing: video'), findsNothing);
      expect(find.byIcon(Icons.local_movies), findsNothing);
      expect(find.text('Editing: audio'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
  });

  testWidgets('Clips list adds selected clip',
    (WidgetTester tester) async {

    final MockProjectPage projectPage = MockProjectPage();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        projectPage, 
        initialState: createInitialAppState()
      )
    );

    expect(find.byWidgetPredicate(
      (Widget widget) => widget is ListView && widget.semanticChildCount > 0),
      findsNothing
    );

    // Tap the '+' icon 2 times and trigger a frame.
    for(int i = 0; i < 2; i++){
      await tester.tap(find.byIcon(Icons.local_movies));
    }
    await tester.pump();

    //There should be a listview with 2 files' paths
    expect(find.byWidgetPredicate(
      (Widget widget) => widget is ListView && widget.semanticChildCount == 2),
      findsOneWidget
    );
    expect(find.text(basename(File('mockVideoPath').path)), findsNWidgets(2));
  });

  testWidgets('Tracks list adds selected track',
    (WidgetTester tester) async {

    final MockProjectPage projectPage = MockProjectPage();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        projectPage, 
        initialState: createInitialAppState()
      )
    );

    await tester.tap(
      find.byWidgetPredicate((Widget widget) => widget is Switch)
    );
    await tester.pump();

    expect(find.byWidgetPredicate(
      (Widget widget) => widget is ListView && widget.semanticChildCount > 0),
      findsNothing
    );

    // Tap the '+' icon 2 times and trigger a frame.
    for(int i = 0; i < 2; i++){
      await tester.tap(find.byIcon(Icons.music_note));
    }
    await tester.pump();

    //There should be a listview with 2 files' paths
    expect(find.byWidgetPredicate(
      (Widget widget) => widget is ListView && widget.semanticChildCount == 2),
      findsOneWidget
    );
    expect(find.text(basename(File('mockAudioPath').path)), findsNWidgets(2));
  });
}
