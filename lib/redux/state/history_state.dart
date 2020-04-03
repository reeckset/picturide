import 'package:meta/meta.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/project_actions/project_action.dart';

enum SavingStatus {saved, notSaved, saving}

@immutable
class HistoryState {

  final List<ProjectAction> undoActions, redoActions;
  final Project project;
  final SavingStatus savingStatus;

  factory HistoryState.create() {
    return HistoryState(
      undoActions: [],
      project: null,
      redoActions: [],
      savingStatus: SavingStatus.saved,
    );
  }

  HistoryState({
    @required this.project,
    @required this.undoActions,
    @required this.redoActions,
    @required this.savingStatus,
  });
}