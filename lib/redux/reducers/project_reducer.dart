import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

Project projectReducer(Project state, ProjectAction action) {
  if(state == null) return state;
  final Project newState = Project.fromProject(state);
  
  return action.applyToState(newState)..generateClipsTimeInfo();
}