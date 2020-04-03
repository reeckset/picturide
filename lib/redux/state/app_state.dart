import 'package:meta/meta.dart';
import 'package:picturide/redux/state/history_state.dart';

@immutable
class AppState {

  final HistoryState history;

  factory AppState.create() {
    return AppState(
      history: HistoryState.create()
    );
  }

  AppState({
    @required this.history
  });
}