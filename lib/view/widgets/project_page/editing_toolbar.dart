import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';

class EditingToolbar extends StatelessWidget {
  
  _save(context){
    StoreProvider.of<AppState>(context)
      .dispatch(saveCurrentProjectActionCreator());
  }

  _undo(context){
    StoreProvider.of<AppState>(context).dispatch(UndoAction());
  }

  _redo(context){
    StoreProvider.of<AppState>(context).dispatch(RedoAction());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSaveButton(context),
        _buildUndoButton(context),
        _buildRedoButton(context),
      ],
    );
  }

  Widget _buildSaveButton(context){
    return StoreConnector<AppState, SavingStatus>(
      converter: (store) => store.state.history.savingStatus,
      builder: (context, savingStatus) => 
        IconButton(
          icon: Icon(
            savingStatus == SavingStatus.saving
            ? Icons.timer
            : Icons.save
          ),
          onPressed:
            savingStatus == SavingStatus.saved
            ? null
            : () => _save(context),
        )
    );
  }

  Widget _buildUndoButton(context){
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.history.undoActions.isNotEmpty,
      builder: (context, isButtonActive) => 
        IconButton(
          icon: Icon(Icons.undo),
          onPressed:
            isButtonActive
            ? () => _undo(context)
            : null,
        )
    );
  }

  Widget _buildRedoButton(context){
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.history.redoActions.isNotEmpty,
      builder: (context, isButtonActive) => 
        IconButton(
          icon: Icon(Icons.redo),
          onPressed:
            isButtonActive
            ? () => _redo(context)
            : null,
        )
    );
  }
}