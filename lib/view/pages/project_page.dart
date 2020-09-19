import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/model/project.dart';
import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/view/widgets/modals/ask_options.dart';
import 'package:picturide/view/widgets/project_page/editing_timelines.dart';
import 'package:picturide/view/widgets/project_page/editing_toolbar.dart';
import 'package:picturide/view/widgets/video_preview.dart';

enum EditingMode { audio, video }

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key}) : super(key: key);

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {

  _confirmWantsToLeave(context) async {
    if(StoreProvider.of<AppState>(context)
      .state.history.savingStatus == SavingStatus.saved){
      return true;
    }
    
    final int option = await askOptions(
      'You are leaving this project',
      'Do you want to save?',
      ['Cancel', 'No', 'Yes'],
      context
    );
    if(option == 0) return false;
    if(option == 2) {
      StoreProvider.of<AppState>(context)
        .dispatch(saveCurrentProjectActionCreator());
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _confirmWantsToLeave(context),
      child: StoreConnector<AppState, Project>(
          converter: (store) => store.state.history.project,
          distinct: true,
          builder: (context, Project project) =>
            _getPageContent(context, project)
        )
    );
  }

  _getPageContent(context, Project project){
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 10.0),
          child:
            project == null
            ? Text('Loading project...')
            : Column(children: [
                Container(
                  height: mediaQuery.size.width / project.getAspectRatio(),
                  child:
                    project.clips.isNotEmpty
                      ? VideoPreview(project)
                      : Center(child: Text('Add a video!')),
                ),
                EditingToolbar(),
                EditingTimelines(),
              ]),
        ),
      )
    );
  }

  
}