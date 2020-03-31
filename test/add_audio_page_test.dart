import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'make_testable_widget.dart';
import 'widget_mocks/add_audio_page.dart';

void main() {
  testWidgets('BPM counter is accurate', (WidgetTester tester) async {

    final MockAddAudioPage addAudioPage = MockAddAudioPage();

    await tester.pumpWidget(makeTestableWidget(addAudioPage));
    await tester.pump(Duration(milliseconds: 50));

    // Verify that BPM starts at 0.
    expect(find.text('BPM: 0'), findsOneWidget);
    expect(find.text('mockAudioPath'), findsOneWidget);

    // Tap the button 2 times in 30bpm.
    await tester.tap(find.text('Tap to the tempo'));
    await tester.pump();
    sleep(const Duration(seconds:2));
    await tester.tap(find.text('Tap to the tempo'));
    await tester.pump();

    // Bpm should now be 240
    expect(find.text('BPM: 0'), findsNothing);
    expect(find.text('BPM: 30'), findsOneWidget);
  });
}
