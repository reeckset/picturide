import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

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
    state.clips = [...state.clips];
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
    state.clips = [...state.clips];
    state.clips[clipIndex] = 
      Clip.fromClip(state.clips[clipIndex])..decrementTempoDuration();
    return state;
  }
}

class EditClipAction implements ProjectAction {
  int clipIndex;
  Clip newClip;
  EditClipAction(this.newClip, this.clipIndex);

  @override
  getUndoAction(Project previousState) => 
    EditClipAction(previousState.clips[clipIndex], this.clipIndex);

  @override
  Project applyToState(Project state) {
    state.clips = [...state.clips];
    state.clips[clipIndex] = newClip;
    return state;
  }
}

class MoveClipAction extends ProjectAction {
  int oldIndex, newIndex;
  MoveClipAction(this.oldIndex, this.newIndex);

  @override
  getUndoAction(Project previousState) => 
    MoveClipAction(newIndex, oldIndex);
  
  @override
  Project applyToState(Project state) {
    state.clips = [...state.clips];
    final clip = state.clips.removeAt(oldIndex);
    state.clips.insert(newIndex, clip);
    return state;
  }
}