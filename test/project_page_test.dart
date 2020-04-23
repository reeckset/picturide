import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/view/pages/project_page.dart';
import 'utilities/file_picker_mock_handler.dart';
import 'utilities/utilities.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Project Page Tests', () {
    setUp(() {
      WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
          size: const Size(1080, 1920)
      );

      const MethodChannel('miguelruivo.flutter.plugins.file_picker')
        .setMockMethodCallHandler(filePickerMockHandler);
    });

    final testProject = Project.create('Name');

    createInitialAppState() =>
      AppState(history: HistoryState(
        project: testProject,
        undoActions: [], redoActions: [],
        savingStatus: SavingStatus.saved
      ));

    testWidgets('Clips list adds selected clip',
      (WidgetTester tester) async {

      final ProjectPage projectPage = ProjectPage();
      final navigatorObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        makeTestableWidgetRedux(
          projectPage, 
          navigatorObserver: navigatorObserver,
          initialState: createInitialAppState()
        )
      );

      expect(find.byWidgetPredicate(
        (Widget widget) => widget is ListView && widget.semanticChildCount > 0),
        findsNothing
      );

      // Tap the '+' icon 2 times and trigger a frame.
      for(int i = 0; i < 2; i++){
        await tester.tap(find.byTooltip('Add Video'));
        await tester.pumpAndSettle();
        //get the Route of the EditClipPage and pop it with a new AudioTrack
        verify(navigatorObserver.didPush(captureAny, any))
          .captured.last.navigator.pop(
            Clip(filePath: 'filepath-VIDEO')
          );   
        await tester.pumpAndSettle();
      }
      await tester.pump();

      //There should be a listview with 2 files' paths
      expect(find.byWidgetPredicate(
        (widget) => widget is ListView && widget.semanticChildCount == 2),
        findsOneWidget
      );
      expect(find.text(basename('filepath-VIDEO')), findsNWidgets(2));
    });

    testWidgets('Tracks list adds selected track',
      (WidgetTester tester) async {

      final navigatorObserver = MockNavigatorObserver();
      final ProjectPage projectPage = ProjectPage();

      await tester.pumpWidget(
        makeTestableWidgetRedux(
          projectPage, 
          navigatorObserver: navigatorObserver,
          initialState: createInitialAppState()
        )
      ); 

      await tester.tap(find.byIcon(Icons.music_note));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate(
        (Widget widget) => widget is ListView && widget.semanticChildCount > 0),
        findsNothing
      );

      //Add two audio files
      for(int i = 0; i < 2; i++){
        // Tap the '+' icon
        await tester.tap(find.byTooltip('Add Audio'));
        await tester.pumpAndSettle();
        //get the Route of the AddAudioPage and pop it with a new AudioTrack
        verify(navigatorObserver.didPush(captureAny, any))
          .captured.last.navigator.pop(
            AudioTrack(filePath: 'filepath-AUDIO', bpm: 0)
          );   
        await tester.pumpAndSettle();
      }

      //There should be a listview with 2 files' paths
      expect(find.byWidgetPredicate(
        (widget) => widget is ListView && widget.semanticChildCount == 2),
        findsOneWidget
      );
      expect(find.text(basename('filepath-AUDIO')), findsNWidgets(2));
    });
  });
}
