import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

class AddAudioAction implements ProjectAction {
  AudioTrack audioTrack;
  int index;
  AddAudioAction(this.audioTrack, {this.index});

  @override
  getUndoAction(Project previousState) => 
    RemoveAudioAction(index != null ? index : previousState.audioTracks.length);

  @override
  Project applyToState(Project state) {
    if(this.index != null){
      state.audioTracks = 
        [...state.audioTracks]
        ..insert(this.index, audioTrack);
    }else{
      state.audioTracks = [...state.audioTracks, audioTrack];
    }
    return state;
  }
}

class RemoveAudioAction implements ProjectAction {
  int audioTrackIndex;
  RemoveAudioAction(this.audioTrackIndex);

  @override
  getUndoAction(Project previousState) => 
    AddAudioAction(
      previousState.audioTracks[this.audioTrackIndex],
      index: this.audioTrackIndex
    );

  @override
  Project applyToState(Project state) {
    state.audioTracks = [...state.audioTracks]..removeAt(this.audioTrackIndex);
    return state;
  }
}