import 'package:picturide/model/project.dart';

abstract class ProjectAction {
  ProjectAction getUndoAction(Project previousState);
  Project applyToState(Project state);
}