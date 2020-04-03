import 'package:picturide/controller/project_storage.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

class UndoAction {}

class RedoAction {}

class SavedProjectAction {}
class SavingProjectAction {}

class SetActiveProjectAction {
  Project project;
  SetActiveProjectAction(this.project);
}

ThunkAction<AppState> saveCurrentProjectActionCreator() {
  return (Store<AppState> store) async {
    await saveProject(store.state.history.project);
    store.dispatch(SavedProjectAction());
  };
}

ThunkAction<AppState> setActiveProjectActionCreator(String path) {
  return (Store<AppState> store) async {
    final Project project = await getProject(path);
    store.dispatch(SetActiveProjectAction(project));
  };
}