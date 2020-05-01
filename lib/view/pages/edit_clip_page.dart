import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/widgets/edit_clip.dart';
import 'package:picturide/redux/state/app_state.dart';

class EditClipPage extends StatefulWidget {
  final Clip originalClip;
  EditClipPage(this.originalClip, {Key key}) : super(key: key);

  @override
  EditClipPageState createState() => EditClipPageState();
}

class EditClipPageState extends State<EditClipPage> {
  final IjkMediaController _controller = IjkMediaController();
  List<Clip> clipsToAdd = [];

  _submit(context){
    _controller.getVideoInfo().then((VideoInfo fileInfo){
      _controller.stop();
      Navigator.pop(context, clipsToAdd);
    });
  }

  _addClip(){
    this.setState((){
      this.clipsToAdd.add(widget.originalClip);
    });
  }

  _onClipChange(newClip, index){
    this.setState((){
      this.clipsToAdd[index] = newClip;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.setNetworkDataSource(
      widget.originalClip.filePath, autoPlay: true);
    _addClip();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        _controller.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(
            'Clip Editing'
        )),
        body: Column(children: [
              _separatorText(basename(
                widget.originalClip.filePath
                )),
              Container(
                height:  mediaQuery.size.width / StoreProvider
                  .of<AppState>(context).state.history.project.getAspectRatio(),
                child: IjkPlayer(
                  mediaController: _controller,
                ),),
              _separatorText('Clips:'),
              Expanded(
                child: ListView(
                  children: [...clipsToAdd.asMap().entries.map(
                    (entry) => EditClip(
                      entry.value, _controller,
                      onChange: (newClip) => _onClipChange(newClip, entry.key)
                    )
                  ).toList(),
                  FlatButton(
                    child: Text('Add another clip from this file'),
                    onPressed: _addClip,),
                  ],
                ),
              ),
              RaisedButton(
                child: Text('Done'),
                onPressed: () => _submit(context),
              )
        ]),
      )
    );
  }
  
  _separatorText(string){
    return Padding(padding: EdgeInsets.all(5.0),
      child: Text(
        string,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0)
    ),);
  }
}