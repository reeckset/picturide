import 'package:flutter_test/flutter_test.dart';
import 'package:picturide/model/audio_track.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/actions/project_actions/clip_editing_actions.dart';
import 'package:picturide/redux/actions/project_actions/sound_editing_actions.dart';
import 'package:picturide/redux/reducers/app_reducer.dart';
import 'package:picturide/redux/state/app_state.dart';

void main() {

  AppState initialState;
  group('Redo/Undo of Project Actions',(){

    setUp(() {
      initialState = appReducer(
        AppState.create(), 
        SetActiveProjectAction(Project.create('project-path'))
      );
    });
    test('Add Clip', () {
      AppState addedClipState =
        appReducer(initialState, AddClipAction(Clip('path')));
      addedClipState = appReducer(addedClipState, AddClipAction(Clip('path')));
      addedClipState = appReducer(addedClipState, AddClipAction(Clip('path')));

      expect(addedClipState.history.project.clips.length, 3);

      final AppState undoAddedClipState =
        appReducer(addedClipState, UndoAction());

      expect(undoAddedClipState.history.project.clips.length, 2);
    });

    test('Remove Clip', () {
      AppState addedClipState =
        appReducer(initialState, AddClipAction(Clip('path')));
      addedClipState = appReducer(addedClipState, AddClipAction(Clip('del')));
      addedClipState = appReducer(addedClipState, AddClipAction(Clip('path')));

      final AppState removedClipState = 
        appReducer(addedClipState, RemoveClipAction(1));

      expect(removedClipState.history.project.clips.length, 2);

      final AppState undoState =
        appReducer(removedClipState, UndoAction());

      expect(undoState.history.project.clips.length, 3);
      expect(undoState.history.project.clips[1].filePath, 'del');
    });

    test('Add Audio', () {
      AppState addedAudioState =
        appReducer(initialState, AddAudioAction(AudioTrack(filePath: 'path')));
      addedAudioState = appReducer(
        addedAudioState, AddAudioAction(AudioTrack(filePath: 'path'))
      );
      addedAudioState = appReducer(
        addedAudioState, AddAudioAction(AudioTrack(filePath: 'path'))
      );

      expect(addedAudioState.history.project.audioTracks.length, 3);

      final AppState undoState =
        appReducer(addedAudioState, UndoAction());

      expect(undoState.history.project.audioTracks.length, 2);
    });

    test('Remove Audio', () {
      AppState addedAudioState =
        appReducer(initialState, AddAudioAction(AudioTrack(filePath: 'path')));
      addedAudioState = appReducer(
        addedAudioState, AddAudioAction(AudioTrack(filePath: 'del'))
      );
      addedAudioState = appReducer(
        addedAudioState, AddAudioAction(AudioTrack(filePath: 'path'))
      );

      final AppState removedAudioState = 
        appReducer(addedAudioState, RemoveAudioAction(1));

      expect(removedAudioState.history.project.audioTracks.length, 2);

      final AppState undoState =
        appReducer(removedAudioState, UndoAction());

      expect(undoState.history.project.audioTracks.length, 3);
      expect(undoState.history.project.audioTracks[1].filePath, 'del');
    });

    test('Increment clip duration', () {
      final AppState addedClipState =
        appReducer(initialState, AddClipAction(
          Clip('path', tempoDurationPower: 2)
        )
      );
      
      AppState incrementedState = addedClipState;
      for(int i = 0; i < 8; i++){
        incrementedState = 
          appReducer(incrementedState, IncrementClipTempoAction(0));
      }

      AppState undoState = incrementedState;

      for(int i = 0; i < 8; i++){
        undoState = 
          appReducer(undoState, UndoAction());
      }

      expect(undoState.history.project.clips[0].tempoDurationPower, 2);
    });
  });
}
