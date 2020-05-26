import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/redux/state/preview_state.dart';
import 'utilities/utilities.dart';
import 'widget_mocks/edit_clip_page.dart';

void main() {

  setUp(() {
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
      size: const Size(1080, 1920)
    );
  });

  createInitialAppState() =>
    AppState(history: HistoryState(
      project: Project.create('Name'),
      undoActions: [], redoActions: [],
      savingStatus: SavingStatus.saved,
    ), preview: PreviewState.create());
    
  testWidgets('Test edit clip set start', (WidgetTester tester) async {

    final Clip originalClip = Clip(filePath: 'testFilePath');

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        initialState: createInitialAppState()
      )
    );

    expect(find.text('Starting at: 0.0s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shutter_speed));
    await tester.pumpAndSettle();

    expect(find.text('Starting at: 15.1s'), findsOneWidget);
  });

  testWidgets('Test tap "starting at" button', (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      startTimestamp: 15.1
    );

    final MockIjkMediaController ijkControllerMock = MockIjkMediaController();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip, controller: ijkControllerMock),
        initialState: createInitialAppState()
      )
    );

    final startingAtBtn = find.text('Starting at: 15.1s');

    expect(startingAtBtn, findsOneWidget);

    await tester.tap(startingAtBtn);
    await tester.pumpAndSettle();

    verify(ijkControllerMock.seekTo(15.1)).called(1);

  });
}