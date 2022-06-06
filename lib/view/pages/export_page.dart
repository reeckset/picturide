import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/controller/ffmpeg_build/project_exporter.dart';
import 'package:picturide/model/output_preferences.dart';
import 'package:picturide/redux/actions/history_actions.dart';
import 'package:picturide/redux/actions/project_actions/project_settings_actions.dart';
import 'package:picturide/redux/state/history_state.dart';
import 'package:picturide/view/widgets/modals/ask_confirm.dart';
import 'package:picturide/redux/state/app_state.dart';
import 'package:picturide/view/widgets/modals/ask_options.dart';
import 'package:picturide/view/widgets/modals/output_preferences_dialog.dart';

class ExportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {

  final FFmpegKit _flutterFFmpeg = FFmpegKit();
  double progress = 0;
  String exportingPhase = '';
  bool hasFinished = false;
  
  @override
  void initState() {
    super.initState();
    Future(() async {
      try {
        await _preExportOutputPreferencesCheck();
        await _preExportSaveCheck();
      } catch (e) {
        Navigator.of(context).pop();
        return;
      }
      
      ProjectExporter(_getProject(), _flutterFFmpeg,
        progressListener: _progressListener)
        .run()
        .then((_){ setState((){this.hasFinished = true;});})
        .catchError((_){});
    });
  }

  _preExportSaveCheck() async {
    if(StoreProvider.of<AppState>(context).state.history.savingStatus
        == SavingStatus.notSaved
    ){
      switch(await askOptions(
        'Save the project before exporting?',
        'Output preferences will only be saved if you save the project',
        ['Cancel', 'No', 'Yes'], context
      )){
        case 0: 
          throw Exception('User cancelled export on pre-export save');
        case 2:
          StoreProvider.of<AppState>(context).dispatch(
            saveCurrentProjectActionCreator()
          );
      }
    }
  }

  _preExportOutputPreferencesCheck() async {
    final OutputPreferences outputPreferences =
      await outputPreferencesDialog(_getProject(), context);
    if(outputPreferences == null){
      throw Exception('User cancelled export on output preferences selector');
    }
    if(outputPreferences != _getProject().outputPreferences){
      StoreProvider.of<AppState>(context).dispatch(
        SetOutputPreferencesAction(outputPreferences)
      );
    }
  }

  _progressListener(progressPercentage, exportingPhase) {
    setState(() {
      this.progress = progressPercentage;
      this.exportingPhase = exportingPhase;
    });
  }

  _getProject() => StoreProvider.of<AppState>(context).state.history.project;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(await askUserConfirm('Do you want to cancel the export?', context)){
          FFmpegKit.cancel();
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Export')),
        body: hasFinished
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Export finished!'),
                  ElevatedButton(
                    child: Text('Go back to project!'),
                    onPressed: ()=>Navigator.of(context).pop(),
                  ),
                ]
              ),
          )
          : _showProgress()
      )
    );
  }

  _showProgress(){
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(this.exportingPhase),
        ),
      ]
    );
  }

}