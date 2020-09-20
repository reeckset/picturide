import 'package:picturide/model/output_preferences.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

class SetOutputPreferencesAction implements ProjectAction {
  OutputPreferences outputPreferences;

  SetOutputPreferencesAction(this.outputPreferences);

  @override
  getUndoAction(Project previousState) => 
    SetOutputPreferencesAction(previousState.outputPreferences);

  @override
  Project applyToState(Project state) =>
    state..outputPreferences = outputPreferences;
  
}