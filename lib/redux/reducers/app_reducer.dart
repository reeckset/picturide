import 'package:picturide/redux/reducers/history_reducer.dart';
import 'package:picturide/redux/state/app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    history: historyReducer(state.history, action),
  );
}