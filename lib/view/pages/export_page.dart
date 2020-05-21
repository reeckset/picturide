import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:picturide/controller/ffmpeg_build/project_exporter.dart';
import 'package:picturide/view/widgets/ask_confirm.dart';
import 'package:picturide/redux/state/app_state.dart';

class ExportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
  double progress = 0.0;
  int frameNumber = 0;
  bool hasFinished = false;
  
  @override
  void initState() {
    super.initState();
    Future(() async {
      _flutterFFmpegConfig.enableStatisticsCallback(
        (int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps){
        this.setState((){
          this.progress = videoFrameNumber/_getTotalNumberOfFrames().toDouble();
          this.frameNumber = videoFrameNumber;
        });
      });
      ProjectExporter(_getProject(), _flutterFFmpeg).run()
        .then((_){ setState((){this.hasFinished = true;});})
        .catchError((_){});
    });
  }

  _getTotalNumberOfFrames() => (_getProject().getDuration()*30).toInt();

  _getProject() => StoreProvider.of<AppState>(context).state.history.project;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(await askUserConfirm('Do you want to cancel the export?', context)){
          _flutterFFmpeg.cancel();
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
                  RaisedButton(
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
          child: Text('Frame $frameNumber of ${_getTotalNumberOfFrames()}'),
        ),
      ]
    );
  }

}