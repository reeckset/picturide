import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/redux/state/preview_state.dart';
import 'utilities/navigator_pop_listener.dart';
import 'utilities/utilities.dart';
import 'widget_mocks/edit_clip_page.dart';

void main() {

  setUp(() {
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
      size: const Size(1080, 1920)
    );
  });

  final getSlider = () => find.byType(Slider)
      .evaluate().single.widget as Slider;

  createInitialAppState() =>
    AppState(history: HistoryState(
      project: Project.create('Name'),
      undoActions: [], redoActions: [],
      savingStatus: SavingStatus.saved,
    ), preview: PreviewState.create());

  Future<List<Clip>> getReturnedClips(tester, navigatorObserver) async {
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final capturedPopValue = await listenForPoppedValue(navigatorObserver);
    expect(capturedPopValue is List<Clip>, true);
    final List<Clip> result = capturedPopValue;
    return result;
  }
    
  testWidgets('Test edit clip set start', (WidgetTester tester) async {
    final navigatorObserver = MockNavigatorObserver();
    final Clip originalClip = Clip(filePath: 'testFilePath');

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );

    expect(find.text('Starting at: 0.0s'), findsOneWidget);

    await tester.tap(find.text('Set start'));
    await tester.pumpAndSettle();

    expect(find.text('Starting at: 15.1s'), findsOneWidget);

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips[0].filePath, 'testFilePath');
    expect(returnedClips[0].startTimestamp, 15.1);
  });

  testWidgets('Test tap "Go to clip start" button',
    (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      startTimestamp: 125.8
    );

    final MockIjkMediaController ijkControllerMock = MockIjkMediaController();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip, controller: ijkControllerMock),
        initialState: createInitialAppState()
      )
    );

    final goToStartBtn = find.text('Go to clip start');

    expect(find.text('Starting at: 125.8s'), findsOneWidget);
    expect(goToStartBtn, findsOneWidget);

    await tester.tap(goToStartBtn);
    await tester.pumpAndSettle();

    verify(ijkControllerMock.seekTo(125.8)).called(1);
  });

    testWidgets('Test tap fine scrub buttons', (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      startTimestamp: 10.0
    );

    final navigatorObserver = MockNavigatorObserver();
    final MockIjkMediaController ijkControllerMock = MockIjkMediaController();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip, controller: ijkControllerMock),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );

    expect(find.text('Starting at: 10.0s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    verify(ijkControllerMock.seekTo(9.9)).called(1);
    expect(find.text('Starting at: 9.9s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    verify(ijkControllerMock.seekTo(10.0)).called(1);
    expect(find.text('Starting at: 10.0s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    verify(ijkControllerMock.seekTo(10.1)).called(1);
    expect(find.text('Starting at: 10.1s'), findsOneWidget);

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips[0].filePath, 'testFilePath');
    expect(returnedClips[0].startTimestamp, 10.1);
  });

  testWidgets(
    'Test adding another clip from file',
    (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      startTimestamp: 10.0
    );

    final navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );

    expect(find.text('Starting at: 10.0s'), findsOneWidget);

    await tester.tap(find.text('Add another clip from this file'));
    await tester.pumpAndSettle();

    expect(find.text('Starting at: 10.0s'), findsNWidgets(2));

    await tester.tap(find.text('Add another clip from this file'));
    await tester.pumpAndSettle();

    expect(find.text('Starting at: 10.0s'), findsNWidgets(3));

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips.length, 3);
    for(Clip returnedClip in returnedClips) {
      expect(returnedClip.startTimestamp, 10.0);
      expect(returnedClip.filePath, 'testFilePath');
    }
  });

  testWidgets(
    'Test volume slider toggle',
    (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath'
    );

    final navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );


    expect(find.text('1.00x'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);

    final originalSliderValue = getSlider().value;

    /* volume is not linear.
     * 0.5 slider value should correspond to
     * less than 1.00x in a scale from 0 to 10 */ 
    expect(getSlider().value > 0.5, true); 

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('0.00x'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    expect(getSlider().value, 0); 

    await tester.tap(find.byIcon(Icons.volume_off));
    await tester.pumpAndSettle();

    expect(find.text('1.00x'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);
    expect(getSlider().value, originalSliderValue); 

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips.length, 1);
    for(Clip returnedClip in returnedClips) {
      expect(returnedClip.volume, 1.0);
      expect(returnedClip.filePath, 'testFilePath');
    }
  });

  testWidgets(
    'Test volume max',
    (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      volume: 10.0,
    );

    final navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );

    expect(find.text('10.00x'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsNothing);
 
    expect(getSlider().value, getSlider().max); 

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips.length, 1);
    for(Clip returnedClip in returnedClips) {
      expect(returnedClip.volume, 10.0);
      expect(returnedClip.filePath, 'testFilePath');
    }
  });

  testWidgets(
    'Test volume min',
    (WidgetTester tester) async {

    final Clip originalClip = Clip(
      filePath: 'testFilePath',
      volume: 10.0,
    );

    final navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      makeTestableWidgetRedux(
        TestableEditClipPage(originalClip),
        navigatorObserver: navigatorObserver,
        initialState: createInitialAppState()
      )
    );

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    expect(find.text('0.00x'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    expect(getSlider().value, 0);
    expect(getSlider().value, getSlider().min); 

    final returnedClips = await getReturnedClips(tester, navigatorObserver);
    expect(returnedClips.length, 1);
    for(Clip returnedClip in returnedClips) {
      expect(returnedClip.volume, 0.0);
      expect(returnedClip.filePath, 'testFilePath');
    }
  });
}