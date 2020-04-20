import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:path/path.dart';
import 'package:picturide/model/audio_track.dart';

class AddAudioPage extends StatefulWidget {
  AddAudioPage({Key key}) : super(key: key);

  @override
  AddAudioPageState createState() => AddAudioPageState();
}

class AddAudioPageState extends State<AddAudioPage> {
  final IjkMediaController _controller = IjkMediaController();
  String filepath;
  int bpm = 0;
  int beatCount = 0;
  int firstTimestamp = 0;
  bool unsuccessfulFileSelection = false;

  getAudioFile() async => (await FilePicker.getFile(type: FileType.audio)).path;

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
    _controller.stop();
    Navigator.pop(context, AudioTrack(filePath: this.filepath, bpm: this.bpm));
  }

  @override
  void initState() {
    super.initState();
    getAudioFile().then((filepath){
      _controller.setNetworkDataSource(filepath, autoPlay: true);
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
        _controller.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Add Audio File')),
        body: this.filepath != null ? Column(children: [
              Container(
                height: 50,
                child: IjkPlayer(
                  mediaController: _controller,
                ),),
              Text(basename(filepath)),
              Container(
                padding: EdgeInsets.all(10.0),
                child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
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
              RaisedButton(
                child: Text('Add this song!'),
                onPressed: bpm == 0 ? null : () => _submit(context),
              )
        ]) : Text('Waiting for audio file...'),
      )
    );
  }
}