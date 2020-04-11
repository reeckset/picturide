import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

class AddClipAction implements ProjectAction {
  Clip clip;
  int index;
  AddClipAction(this.clip, {this.index});

  @override
  getUndoAction(Project previousState) => 
    RemoveClipAction(index != null ? index : previousState.clips.length);

  @override
  Project applyToState(Project state) {
    if(this.index != null){
      state.clips = [...state.clips]..insert(this.index, clip);
    }else{
      state.clips = [...state.clips, clip];
    }
    return state;
  }
}

class RemoveClipAction implements ProjectAction {
  int clipIndex;
  RemoveClipAction(this.clipIndex);

  @override
  getUndoAction(Project previousState) => 
    AddClipAction(previousState.clips[this.clipIndex], index: this.clipIndex);

  @override
  Project applyToState(Project state) {
    state.clips = [...state.clips]..removeAt(this.clipIndex);
    return state;
  }
}

class IncrementClipTempoAction implements ProjectAction {
  int clipIndex;
  IncrementClipTempoAction(this.clipIndex);

  @override
  getUndoAction(Project previousState) => 
    DecrementClipTempoAction(this.clipIndex);

  @override
  Project applyToState(Project state) {
    state.clips[clipIndex] = 
      Clip.fromClip(state.clips[clipIndex])..incrementTempoDuration();
    return state;
  }
}

class DecrementClipTempoAction implements ProjectAction {
  int clipIndex;
  DecrementClipTempoAction(this.clipIndex);

  @override
  getUndoAction(Project previousState) => 
    IncrementClipTempoAction(this.clipIndex);

  @override
  Project applyToState(Project state) {
    state.clips[clipIndex] = 
      Clip.fromClip(state.clips[clipIndex])..decrementTempoDuration();
    return state;
  }
}