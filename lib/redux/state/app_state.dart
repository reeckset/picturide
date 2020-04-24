import 'package:meta/meta.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/redux/state/preview_state.dart';

@immutable
class AppState {

  final HistoryState history;
  final PreviewState preview;

  factory AppState.create() {
    return AppState(
      history: HistoryState.create(),
      preview: PreviewState.create(),
    );
  }

  AppState({
    @required this.history,
    @required this.preview
  });
}