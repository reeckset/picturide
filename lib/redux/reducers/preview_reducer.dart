import 'package:picturide/redux/actions/preview_actions.dart';
import 'package:picturide/redux/state/preview_state.dart';

PreviewState previewReducer(PreviewState state, dynamic action) {

  if(action is UpdatePreviewCurrentTime){
    return PreviewState(
      currentTime: action.time
    );
  }

  return state;
}