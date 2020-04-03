import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';
import 'package:picturide/redux/reducers/project_reducer.dart';
import 'package:picturide/redux/state/history_state.dart';

HistoryState historyReducer(HistoryState state, dynamic action) {

  if(action is UndoAction){
    if(state.undoActions.isEmpty) return state;
    return HistoryState(
      undoActions: [...state.undoActions]..removeLast(),
      project: projectReducer(state.project, state.undoActions.last),
      redoActions: [
        ...state.redoActions,
        state.undoActions.last.getUndoAction(state.project)
      ],
      savingStatus: SavingStatus.notSaved
    );
  }

  if(action is RedoAction){
    if(state.redoActions.isEmpty) return state;
    return HistoryState(
      undoActions: [
        ...state.undoActions,
        state.redoActions.last.getUndoAction(state.project)
      ],
      project: projectReducer(state.project, state.redoActions.last),
      redoActions: [...state.redoActions]..removeLast(),
      savingStatus: SavingStatus.notSaved
    );
  }

  if(action is SavedProjectAction){
    return HistoryState(
      undoActions: state.undoActions,
      project: state.project,
      redoActions: state.redoActions,
      savingStatus: SavingStatus.saved
    );
  }
  
  if(action is SavingProjectAction){
    return HistoryState(
      undoActions: state.undoActions,
      project: state.project,
      redoActions: state.redoActions,
      savingStatus: SavingStatus.saving
    );
  }

  if(action is SetActiveProjectAction){
    if(state.project != null
      && action.project.filepath == state.project.filepath
      && state.savingStatus == SavingStatus.saved){
      return state;
    }

    return HistoryState(
      undoActions: [],
      project: action.project,
      redoActions: [],
      savingStatus: SavingStatus.saved
    );
  }

  if(!(action is ProjectAction)) return state;
  return HistoryState(
    undoActions: [...state.undoActions, action.getUndoAction(state.project)],
    project: projectReducer(state.project, action),
    redoActions: [],
    savingStatus: SavingStatus.notSaved
  );
}