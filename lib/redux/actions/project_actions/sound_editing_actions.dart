import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

class AddAudioAction implements ProjectAction {
  AudioTrack audioTrack;
  AddAudioAction(this.audioTrack);

  @override
  getUndoAction(Project previousState) => 
    RemoveAudioAction(previousState.audioTracks.length);

  @override
  Project applyToState(Project state) {
    state.audioTracks = [...state.audioTracks, audioTrack];
    return state;
  }
}

class RemoveAudioAction implements ProjectAction {
  int audioTrackIndex;
  RemoveAudioAction(this.audioTrackIndex);

  @override
  getUndoAction(Project previousState) => 
    AddAudioAction(previousState.audioTracks[this.audioTrackIndex]);

  @override
  Project applyToState(Project state) {
    state.audioTracks = [...state.audioTracks]..removeAt(this.audioTrackIndex);
    return state;
  }
}