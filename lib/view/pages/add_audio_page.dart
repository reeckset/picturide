import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';

class AddAudioPage extends StatefulWidget {
  AddAudioPage({Key key}) : super(key: key);

  @override
  AddAudioPageState createState() => AddAudioPageState();
}

class AddAudioPageState extends State<AddAudioPage> {
  final BetterPlayerController _controller = BetterPlayerController(
    BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
  ));
  String filepath;
  int bpm = 0;
  int beatCount = 0;
  int firstTimestamp = 0;
  bool unsuccessfulFileSelection = false;

  getAudioFile() async => (await FilePicker.platform.pickFiles(type: FileType.audio)).files[0].path;

  _registerTap(){
    final beatCount = this.beatCount+1;
    final int currentTimestamp = DateTime.now().microsecondsSinceEpoch;
    if(firstTimestamp == 0){
      setState((){firstTimestamp = currentTimestamp;});
    } else {
      final int totalTimeElapsed = currentTimestamp - firstTimestamp;
      setState((){
        this.beatCount = beatCount;
        this.bpm = (6e7 * this.beatCount / totalTimeElapsed).round();
      });
    }
  }

  _resetBPM(){
    this.setState((){
      this.beatCount = 0;
      this.bpm = 0;
      this.firstTimestamp = 0;
    });
  }

  _submit(context){
    final double duration = _controller.betterPlayerDataSource
      .overriddenDuration.inMilliseconds / 1000.0;
    _controller.dispose();
    Navigator.pop(context, 
      AudioTrack(
        filePath: this.filepath,
        bpm: this.bpm,
        sourceDuration: duration
      ));
  }

  @override
  void initState() {
    super.initState();
    getAudioFile().then((filepath){
      _controller.setupDataSource(BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, filepath));
      this.setState((){ this.filepath = filepath; });
    }).catchError((_){
      this.setState((){
        this.unsuccessfulFileSelection = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(unsuccessfulFileSelection){
      Navigator.pop(context);
    }
    return WillPopScope(
      onWillPop: () async {
        _controller.dispose();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Add Audio File')),
        body: this.filepath != null ? Column(children: [
              Container(
                height: 50,
                child: BetterPlayer(
                  controller: _controller,
                ),),
              Text(basename(filepath)),
              Container(
                padding: EdgeInsets.all(10.0),
                child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: Text('Tap to the tempo'),
                        onPressed: _registerTap,
                      ),
                      Text('BPM: $bpm'),
                      IconButton(
                        icon: Icon(Icons.replay),
                        onPressed: _resetBPM,
                      )
                    ],
                  )
              ),
              ElevatedButton(
                child: Text('Add this song!'),
                onPressed: bpm == 0 ? null : () => _submit(context),
              )
        ]) : Text('Waiting for audio file...'),
      )
    );
  }
}