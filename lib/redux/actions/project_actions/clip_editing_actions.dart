import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

class AddClipAction implements ProjectAction {
  Clip clip;
  AddClipAction(this.clip);

  @override
  getUndoAction(Project previousState) => 
    RemoveClipAction(previousState.clips.length);

  @override
  Project applyToState(Project state) {
    state.clips = [...state.clips, clip];
    return state;
  }
}

class RemoveClipAction implements ProjectAction {
  int clipIndex;
  RemoveClipAction(this.clipIndex);

  @override
  getUndoAction(Project previousState) => 
    AddClipAction(previousState.clips[this.clipIndex]);

  @override
  Project applyToState(Project state) {
    state.clips = [...state.clips]..removeAt(this.clipIndex);
    return state;
  }
}