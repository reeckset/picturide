import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/actions/preview_actions.dart';
import 'package:picturide/redux/state/preview_state.dart';

PreviewState previewReducer(PreviewState state, dynamic action) {

  if(action is UpdatePreviewCurrentTime){
    state = PreviewState.fromPreviewState(state);
    state.currentTime = action.time;
  } else if(action is SetActiveProjectAction){
    return PreviewState.create();
  } else if(action is SelectClipAction){
    state = PreviewState.fromPreviewState(state);
    state.selectedClip = action.index;
  }

  return state;
}